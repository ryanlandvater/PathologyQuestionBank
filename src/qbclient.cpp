//
//  qbclient.cpp
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.
#define _WIN32_WINNT_WIN10                  0x0A00 // Windows 10

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFileInfo>
#include <QImage>
#include <QDataStream>
#include <QBuffer>
#include <QByteArray>

#include <fstream>
#include <boost/shared_ptr.hpp>

#include "qbclient.h"
#include "qbwebsocketsession.h"
#include "qbimageprovider.h"

#include "QB_jsonNodes.hpp"

QBClient::QBClient(QQmlApplicationEngine* engine,
                   QBWebSocketSession* socket,
                   bool debug,
                   QObject* parent) :
    QObject(parent),
    _engine(engine),
    _socket(*socket),
    _imageDrawer(new QBImageProvider(this)),
    _persist(QSettings::IniFormat,
             QSettings::UserScope,"MichiganPathology",
             "PathologyQbank",this),
    _state(login),
    _keepLogin(false),
    _debug(debug),
    _connected(false),
    _notification(QString()),
    _screenDPI(1.0)
{
    if (engine) {
        // Expose QBClient / client controller (this) to QML
        engine->rootContext()->setContextProperty("QBClient",&(*this));

        // Expose the image drawer to QML
        engine->addImageProvider(QLatin1String("QBImageDraw"),_imageDrawer);
    }

    if (socket) {
        socket->setClient(this);
    }
}

QBClient::~QBClient()
{
    if (_imageDrawer) {
        // Deletion of the image provider is done by the engine
        // Remove reference before deletion.
        _imageDrawer = nullptr;
        _engine->removeImageProvider(QLatin1String("QBImageDraw"));
    }
    _sessionMGMT.notify_all();
    std::unique_lock<std::mutex> session_lock(_sessionMGMT_MTX);
}

void QBClient::connectionChanged()
{
    if (_socket.isConnected()) {
        _connected = true;
        if (_session.active)
            resumeSession();
        else setState(login);
    } else _connected = false;
    emit connectedChanged();
}

QString QBClient::state() const
{
    switch (_state) {
    case login:
        return "login";
    case dashboard:
        return "dashboard";
    case questionEditor:
        return "questionEditor";
    case questionAnalysis:
        return "questionAnalysis";
    case testView:
        return "test";
    case scoreView:
        return "score";
    case sharedTestView:
        return "sharedTestEditor";
#ifdef WIN32
    default:
        return "NULL";
#endif
    }
}

QString  QBClient::notify()             const {return _notification;}
bool QBClient::connected()              const {return _connected;}
bool QBClient::keepLogin()              const {return _keepLogin;}
bool QBClient::outstandingSearch()      const {return _outstandingSearch;}
QVariantMap QBClient::user()            const {return _user;}
QVariantMap QBClient::settings()        const {return _settings;}
QVariantMap QBClient::statistics()      const {
    if(_user.contains(__STATISTICS))
        return _user[__STATISTICS].toMap();
    return QVariantMap();
}
QVariantList QBClient::statsTopics()    const {
    if(statistics().contains(__TOPICS))
        return statistics()[__TOPICS].toList();
    return QVariantList();}
QVariantMap QBClient::test()            const {return _test;}
QVariantMap QBClient::score()           const {return _score;}
QVariantMap QBClient::sharedTest()      const {return _sharedTestEditor;}
QVariantList QBClient::scoreTopics()    const {
    if (_score.contains(__TOPICS))
        return _score[__TOPICS].toList();
    return QVariantList();}
QVariantList QBClient::incompleteTests()const {return _incompleteTests;}
QVariantList QBClient::completeTests()  const {return _completeTests;}
QVariantList QBClient::sharedTests()    const {return _sharedTests;}
QVariantMap QBClient::question()        const {return _question;}
QList<QVariantMap> QBClient::images()   const {return _images;}
QVariantList QBClient::incomplete()     const {return  _incomplete;}

bool QBClient::publishable() const
{
    if (!_question.contains(__QID))
        return false;

    if (_question.contains(__QUESTIONTXT))
        if (_question[__QUESTIONTXT].toString().length() > 4)
            if (_question.contains(__CORRECTANSWER))
                if (_question[__CORRECTANSWER] != "0")
                    if (_question.contains(__TOPICS))
                        if (qvariant_cast<QStringList>(_question[__TOPICS]).size() > 0)
                            return true;

    return false;
}
QVariantList QBClient::published()      const {return _published;}
QVariantList QBClient::searchResults()  const {return _searchResults;}
QVariantList QBClient::choices() const
{
    if (_question.contains(__CHOICES)) {
        return _question[__CHOICES].toList();
    }
    return QList<QVariant>();
}

bool QBClient::locked() const
{
    if (_question.contains(__SUBMITTED))
        return _question[__SUBMITTED].toBool();
    return false;

}

bool QBClient::marked() const
{
    if (_question.contains(__MARKED))
        return _question[__MARKED].toBool();
    return false;
}

void QBClient::attemptLogin(QString username, QString password)
{
    QJsonObject request;
    QJsonObject credentials;

    credentials[__USERNAME] = username;
    credentials[__PASSWORD] = password;

    request[__REQUEST]      = __LOGINREQUEST;
    request[__CREDENTIALS]  = credentials;

    transmitRequest(request);

    if (_keepLogin) _persist.setValue(__USERNAME,username);
}

void QBClient::attemptResume()
{
    // If a prior login was saved,
    if (_persist.value(__SESSION) != QVariant() &&
            _persist.value(__UID) != QVariant() &&
            _persist.value(__EXPIRATION) != QVariant()) {

        // Set set this to save prior logins too,
        // assign it,
        _keepLogin = true;
        _user[__UID]        = _persist.value(__UID).toString();
        _session.session_id = _persist.value(__SESSION).toString();
        _session.expiration = _persist.value(__EXPIRATION).toString().toLong()/1000;

        // And resume the sessison
        resumeSession();
    }
}

void QBClient::updatePassword(QString &PAS, QString &NEW)
{
    if (!_user.contains(__UID)) return;

    QJsonObject request;

    request[__REQUEST]  = __UPDATEPASS;
    request[__UID]      = _user[__UID].toString();
    request[__PASSWORD] = PAS;
    request[__UPDATED]  = NEW;

    transmitRequest(request);
}

void QBClient::logout()
{
    QJsonObject request;

    request[__REQUEST]      = __LOGOUTREQUEST;

    transmitRequest(request);

    _persist.setValue(__SESSION,QVariant());
    _persist.setValue(__UID,QVariant());

    setState(login);
}

void QBClient::createQuestion()
{
    QJsonObject request;
    QJsonObject credentials;

    credentials[__UID] = _user[__UID].toString();

    request[__REQUEST]      = __NEWQUESTION;
    request[__CREDENTIALS]  = credentials;

    transmitRequest(request);
}

void QBClient::createSharedTest()
{
    QJsonObject request;
    QJsonObject credentials;

    request[__REQUEST]      = __NEWSHARED;
    request[__CREDENTIALS]  = _user[__UID].toString();

    transmitRequest(request);
}

void QBClient::updateQuestion(const QString& field, const QString& updatedText)
{
    QJsonObject request;
    QJsonObject update;

    // Make sure we have an open question to update
    if (!_question.contains(__QID)) return;

    // Retrieve that question's QID
    request[__QID] = _question[__QID].toString();

    if(_question.contains(field))
        if (_question[field].toString() == updatedText)
            return;

    // Add the updated text to the right feature
    if (field == __QUESTIONNAME) {
        update[__QUESTIONNAME]      = updatedText;
        _question[__QUESTIONNAME]   = updatedText;
    } else if (field == __CLINICALHX) {
        update[__CLINICALHX]        = updatedText;
        _question[__CLINICALHX]     = updatedText;
    } else if (field == __QUESTIONTXT) {
        update[__QUESTIONTXT]       = updatedText;
        _question[__QUESTIONTXT]    = updatedText;
    } else if (field == __EXPLAINATION) {
        update[__EXPLAINATION]      = updatedText;
        _question[__EXPLAINATION]    = updatedText;
    } else if (field == __CORRECTANSWER) {
        update[__CORRECTANSWER]     = updatedText;
        _question[__CORRECTANSWER]  = updatedText;
    } else if (field == __TOPICS) {
        update[__TOPICS]            = updatedText;
        _question[__TOPICS]         = updatedText;
    }

    // Don't update anything if it is incorrectly labeled.
    else
        return;

    // Generate the request
    request[__REQUEST]      = __EDITFIELD;
    request[__EDITFIELD] = update;

    transmitRequest(request);
    emit questionChanged();
    emit publishableChanged();
    emit lockedChanged();
    emit markedChanged();
}

void QBClient::editQuestion(const QString &QID)
{
    QJsonObject request;

    // Package that question's QID and label the request
    request[__QID]      = QID;
    request[__REQUEST]  = __EDITQUESTION;

    // Transmit it to the server
    transmitRequest(request);
}

void QBClient::editSharedTest(const QString &STID)
{
    QJsonObject request;

    //Package the shared test ID (STID)
    request[__STID]     = STID;
    request[__REQUEST]  = __EDITSHARED;

    // Transmit it to the server
    transmitRequest(request);
}

void QBClient::uploadImage(const QString &filePath)
{
    // Make sure we have an open question for which to add an image
    if (!_question.contains(__QID))
        return;

    QFileInfo fileInfo(filePath);
    // Do not accecpt images > 16 MB. That's too large.
    if (fileInfo.size() > 16777216) return;

    // Load the image into a raw byte array
//    QImage image(QUrl(filePath).toLocalFile());
//    QDataStream datastream;
//    datastream << image.; datastream >> byteArray;

//    QByteArray byteArray;
//    QBuffer img_buf(&byteArray);
//    img_buf.open(QIODevice::WriteOnly);
//    image.save(&img_buf,"PNG");

    // Save the a reference to the byte array to the QBFile
//    serializer._dataSize = static_cast<uint64_t>(byteArray.length());
//    serializer._data = reinterpret_cast<const uint8_t*>(byteArray.constData());

    // Create input file stream (fstream with input flag)
    std::ifstream image_file;

    // Open the provided path
    image_file.open(QUrl(filePath).toLocalFile().toStdString(),
               std::ifstream::binary | std::ifstream::in);

    // Ensure the file is open for reading. If not, return with error message
    if (!image_file.is_open()) {
        std::cerr << "Failed to open image. Path is incomplete" << std::endl;
        setNotification("Failed to open the file path: "+ filePath);
        return;
    } std::string image_buff((std::istreambuf_iterator<char>(image_file)),
                             std::istreambuf_iterator<char>());

    // Generate the QBBuffer Flatbuffer Builder
    flatbuffers::FlatBufferBuilder imageBuilder;

    // Generate the metadata object
    auto question_id    = imageBuilder.CreateString(_question[__QID].toString().toStdString());
    auto filename       = imageBuilder.CreateString(fileInfo.fileName().toStdString());

    ImageMetadataBuilder metadataBuilder(imageBuilder);
    metadataBuilder.add_question_ID(question_id);
    metadataBuilder.add_filename(filename);
    auto metaData = metadataBuilder.Finish();

    // Read the file into a buffer
    auto data = imageBuilder.CreateVector(reinterpret_cast<const int8_t*>(image_buff.data()), image_buff.size());

    // Build the image buffer object
    const auto imageBuffer    = CreateQBBuffer(imageBuilder,
                                         image_buff.size(),
                                         BufferType_image,
                                         Metadata_image_metadata,
                                         metaData.Union(),
                                         data);
    imageBuilder.Finish(imageBuffer);

    auto Var = flatbuffers::Verifier(imageBuilder.GetBufferPointer(),imageBuilder.GetSize());
    if (!VerifyQBBufferBuffer(Var)) {
        std::cerr << "Buffer object failed verification." << std::endl;
        setNotification("Failed to package the image file. It may be a corrupted file.");
        return;
    }

    // It passed QC. Let's transmit it to the server.
    transmitBinObject(imageBuilder);

    // Close file when completed.
    image_file.close();
}

void QBClient::removeImage(const QString &ImageID)
{
    switch (_state) {
    case questionEditor:
    case questionAnalysis:
        break;
    default:
        return;
    }

    if (!_question.contains(__QID)) return;

    QJsonObject request;

    request[__REQUEST]  = __REMOVEIMAGE;
    request[__QID]      = _question[__QID].toString();
    request[__IMGID]    = ImageID;

    transmitRequest(request);

    // Now remove it locally
    QList<QVariantMap> buffer;
    for (auto&& image : _images)
        if (image[__IMGID].toString() != ImageID)
            buffer.append(image);
    _images = buffer;
    _imageDrawer->removeImage(ImageID);
    emit imagesChanged();
}

void QBClient::addAnswerChoice()
{
    QJsonObject request;

    request[__REQUEST]  = __NEWCHOICE;
    request[__QID]      = _question[__QID].toString();

    transmitRequest(request);
}

void QBClient::updateChoice(const QString &CID, const QString& field, const QString &updatedText)
{

    // Make sure we have an open question to update
    if (!_question.contains(__QID))
        return;

    // Retrieve that question's QID
    auto choices = _question[__CHOICES].toList();
    for (auto &element : choices) {

        // Map the choice subarray
        QVariantMap choice = qvariant_cast<QVariantMap>(element);
        if (choice[__CID] == CID) {

            QJsonObject request;
            QJsonObject update;

            // Provide the questionID
            request[__QID] = _question[__QID].toString();
            // Provide the choice ID
            request[__CID] = CID;

            // Add the updated text to the right feature
            if (field == __CHOICETEXT){
                update[__CHOICETEXT]    = updatedText;
                choice[__CHOICETEXT]    = updatedText;
            } else if (field == __CHOICEEXP) {
                update[__CHOICEEXP]     = updatedText;
                choice[__CHOICEEXP]     = updatedText;
            }

            // Don't update anything if it is incorrectly labeled.
            else
                return;

            // Generate the request
            request[__REQUEST]      = __EDITCHOICE;
            request[__EDITCHOICE]   = update;

            transmitRequest(request);

            element = choice;
            _question[__CHOICES] = choices;
        }
    }

}

void QBClient::removeChoice(const QString &CID)
{
    // Must have a question open to modify the choices
    if (!_question.contains(__QID))
        return;

    // Instantiate the request
    QJsonObject request;

    // Generate the request
    request[__REQUEST] = __REMOVECHOICE;
    request[__QID] = _question[__QID].toString();
    request[__CID] = CID;

    // Transmit it to the server
    transmitRequest(request);

    // Remove it from the question
    if (!_question.contains(__CHOICES)) return;
    auto choices = _question[__CHOICES].toList();
    QVariantList update;
    for (auto&& choice : choices)
        if (choice.toMap()[__CID] != CID)
            update.append(choice);
    _question[__CHOICES] = update;
    emit choicesChanged();
}

void QBClient::assignAnswer(const QString &CID)
{
    updateQuestion(__CORRECTANSWER,CID);
}

bool QBClient::containsTags(const QString &tag)
{
    if (!_question.contains(__TOPICS))
        return false;
    qvariant_cast<QVariantList>(_question[__TOPICS]).contains(tag);
    if (qvariant_cast<QVariantList>(_question[__TOPICS]).contains(tag))
        return true;
    return false;
}

void QBClient::assignTag(const QString& field, const QString &tag, bool assigned)
{
    // Cannot update if a question isn't open.
    if (!_question.contains(__QID))
        return;

    // Update the tags
    QVariantList tags;
    if (_question.contains(field))
        tags = qvariant_cast<QVariantList>(_question[field]);

    // Check if the tag is assigned and toggle it
    if (!assigned) {
        if (!tags.contains(tag))
            tags.append(tag);
        else return;
    } else
        if (tags.contains(tag))
            tags.removeAll(tag);

    // Convert the variant list json document
    QJsonObject request;
    QJsonObject update;

    request[__QID] = _question[__QID].toString();

    // Add the updated array to the request
    if (field == __TOPICS) {
        update[__TOPICS] = QJsonArray::fromVariantList(tags);
        _question[__TOPICS] = tags;
    }

    // Generate the request
    request[__REQUEST]      = __EDITARRAY;
    request[__EDITARRAY]    = update;

    transmitRequest(request);

    emit publishableChanged();
    emit questionChanged();
}

void QBClient::publishQuestion(const QString &confirmQID)
{
    QJsonObject request;

    // Make sure we have an open question to update
    if (!_question.contains(__QID))
        return;

    // Confirm that the open quesiton is correct
    if (confirmQID != _question[__QID])
        return;

    // Generate the request
    request[__REQUEST]  = __PUBLISH;
    request[__QID]  = _question[__QID].toString();

    // Send the request
    transmitRequest(request);

    // And close the editor
    closeEditor();
}

void QBClient::deleteQuestion(const QString &confirmQID)
{
    QJsonObject request;

    // Make sure we have an open question to update
    if (!_question.contains(__QID)) return;

    // Confirm that the open quesiton is correct
    if (confirmQID != _question[__QID])
        return;

    // Generate the request
    request[__REQUEST]  = __DELETE;
    request[__QID]  = _question[__QID].toString();

    // Send the delete request
    transmitRequest(request);

    // Close the editor
    closeEditor();
}

void QBClient::updateSharedTest(const QString &field,
                                const QString &updatedText)
{
    QJsonObject request;
    QJsonObject update;

    // Make sure we have an open shared test to update
    if(!_sharedTestEditor.contains(__STID)) return;

    // Retrieve the test's SID
    request[__STID] = _sharedTestEditor[__STID].toString();

    if(_sharedTestEditor.contains(field))
        if (_sharedTestEditor[field].toString() == updatedText)
            return;

    // Add the updated text to the right feature
    if (field == __TESTNAME) {
        update[__TESTNAME]              = updatedText;
        _sharedTestEditor[__TESTNAME]   = updatedText;
    } else if (field == __ADDQUESTION) {
        update[__ADDQUESTION]           = updatedText;
    } else if (field == __RMQUESTION) {
        update[__RMQUESTION]            = updatedText;
    } else if (field == __ADDUSER) {
        update[__ADDUSER]               = updatedText;
    } else if (field == __RMUSER) {
        update[__RMUSER]                = updatedText;
    } else if (field == __RMST) {
        update[__RMST]                  = updatedText;
    }

    // Don't update anything if it is incorrectly labeled.
    else return;

    // Generate the request
    request[__REQUEST]      = __UPDATESHARED;
    request[__UPDATESHARED] = update;

    transmitRequest(request);

    // Go back to the dashboard if request was to delete
    if (field == __RMST)
        setState(dashboard);
}

void QBClient::closeEditor()
{
    // Close the local questions
    closeQuestion();
    closeShared();

    // Ask for updated lists from the server
    // This INCLUDES shared tests (not just Qs)
    QJsonObject request;
    request[__REQUEST]  = __QUESTIONS;
    request[__SKIP]     = 0;
    transmitRequest(request);

    // Switch the UX state
    if (_user.contains(__UID)) {
        setState(dashboard);
        return;
    } else {
        _user.clear();
        setState(login);
    }
}

void QBClient::analyzeQuestion(const QString &QID)
{
    QJsonObject request;

    // Package that question's QID and label the request
    request[__QID]      = QID;
    request[__REQUEST]  = __ANALYZEQUESTION;

    // Transmit it to the server
    transmitRequest(request);
}

void QBClient::generateTest(const QString &status, const QStringList &tags, const int number, const bool jmode)
{
    if (!status.length() || !tags.length() || number == 0)
        return;

    QJsonObject request;
    QJsonObject test;

    test[__STATUS] = status;
    test[__TOPICS] = QJsonArray::fromStringList(tags);
    test[__NUMBER] = number;
    test[__JMODE]  = jmode;

    request[__REQUEST]      = __TESTREQUEST;
    request[__TESTREQUEST]  = test;

    transmitRequest(request);
}

void QBClient::resumeTest(const QString &TID)
{
    QJsonObject request;

    request[__REQUEST]  = __RESUMETEST;
    request[__TID] = TID;

    transmitRequest(request);
}

void QBClient::questionAt(const int index)
{
    // If the test is not open,
    if (!_test.contains(__QUESTIONS))
        return;

    // If the index is out of bounds (shouldn't be)
    if (index >= _test[__QUESTIONS].toList().size())
        return;

    QVariantMap question = _test[__QUESTIONS].toList().at(index).toMap();
    if (!question.contains(__QID)) return;

    // Close the current question
    closeQuestion();

    // Generate the JSON request
    QJsonObject request;

    // Send a question request to generate the view
    request[__REQUEST] = __VIEWQUESTION;
    request[__VIEWQUESTION] = question[__QID].toString();

    // Transmit the request
    transmitRequest(request);
}

void QBClient::pauseTest()
{
    // Generate the JSON request
    QJsonObject request;

    // Request pause test and provide the TestID
    request[__REQUEST]  = __PAUSETEST;
    request[__TID]      = _test[__TID].toString();

    // Transmit the request
    transmitRequest(request);

    if (_user.contains(__UID)) {
        closeQuestion();
        closeTest();
        setState(dashboard);
    } else {
        _user.clear();
        closeQuestion();
        closeTest();
        setState(login);
    }
}

void QBClient::selectAnswer(const QString &CID)
{
    if (!_question.contains(__QID))
        return;
    if (!_test.contains(__TID) ||
        !_test.contains(__QUESTIONS))
        return;

    // Generate the JSON request
    QJsonObject request;

    // Request pause test and provide the TestID
    request[__REQUEST]  = __SELECTCHOICE;
    request[__TID]      = _test[__TID].toString();
    request[__QID]      = _question[__QID].toString();
    request[__CID]      = CID;

    // Transmit the request
    transmitRequest(request);
}

void QBClient::submitAnswer()
{
    if (!_question.contains(__QID)) return;
    if (!_test.contains(__TID))     return;

    // Generate the JSON request
    QJsonObject request;

    // Request pause test and provide the TestID
    request[__REQUEST]  = __SUBMITCHOICE;
    request[__TID]      = _test[__TID].toString();
    request[__QID]      = _question[__QID].toString();

    // Transmit the request
    transmitRequest(request);
}

void QBClient::toggleMarked(const int curIndex)
{
    if (!_question.contains(__QID)) return;
    if (!_test.contains(__TID))     return;

    // Ensure we are toggling the correct one.
    // THIS IS BASICALLY UNNECESSARY. Just an extra check
    if (_question[__QID] !=
            _test[__QUESTIONS].toList().at(curIndex).toMap()[__QID].toString())
        return;

    // Generate JSON request
    QJsonObject request;

    // Request toggle marked flag
    request[__REQUEST]  = __MARKED;
    request[__TID]      = _test[__TID].toString();
    request[__QID]      = _question[__QID].toString();

    // Transmit the request
    transmitRequest(request);

//    // If no marked flag, make it.
//    if(!_question.contains(__MARKED)){
//        _question[__MARKED] = true;
//        return;
//    } // Else toggle the marked flag
//    _question[__MARKED] = !_question[__MARKED].toBool();
}

void QBClient::submitTest()
{
    // Ensure a test is open
    if (!_test.contains(__TID)) return;

    // Generate the JSON request
    QJsonObject request;
    request[__REQUEST]  = __SUBMITTEST;
    request[__TID]      = _test[__TID].toString();

    // Request submit test
    transmitRequest(request);
}

void QBClient::search(const QString &criterion, const QString &term)
{
    if (!criterion.length()) {
        std::cerr << "There is NO search criteria" << std::endl;
        return; }

    // Generate the JSON request
    QJsonObject request;
    request[__REQUEST]      = __SEARCH;
    request[__CRITERION]    = criterion;
    request[__SEARCHTERMS]  = term;

    // Request the search
    transmitRequest(request);
}

void QBClient::clearSearch()
{
    _searchResults.clear();
}

qreal QBClient::screenDPI() const
{
    return _screenDPI;
}

void QBClient::setScreenDPI(const qreal &screenDPI)
{
    _screenDPI = screenDPI;
}

void QBClient::setKeepLogin(const bool &status)
{
    _keepLogin = status;
    if (!status) {
        _persist.setValue(__SESSION,QVariant());
        _persist.setValue(__UID,QVariant());
    }
}

void QBClient::onResponseReturned(const QString & json_string)
{
    QJsonObject r_ = QJsonDocument::fromJson(json_string.toUtf8()).object();
    if (!r_.contains(__RESPONSE) || !r_[__RESPONSE].isString())
        return;

    QString responseType = r_[__RESPONSE].toString();
    if (responseType == __NOTIFICATION) {
        if (r_.contains(__NOTIFICATION))
            setNotification(r_[__NOTIFICATION].toString());
        return;
    }
    if (responseType == __LOGINREQUEST) {
        if (r_.contains(__CREDENTIALS))
            setUser(r_[__CREDENTIALS].toObject().toVariantMap());
        return;
    }
    if (responseType == __SESSION) {
        if (r_.contains(__SESSION))
            setSession(r_[__SESSION].toObject());
        if (r_.contains(__SETTINGS))
            setSettings(r_[__SETTINGS].toObject().toVariantMap());
        return;
    }
    if (responseType == __STATISTICS) {
        if (r_.contains(__STATISTICS))
            setStatistics(r_[__STATISTICS].toObject().toVariantMap());
        return;
    }
    if (responseType == __USERTESTS) {
        if (r_.contains(__INCOMPTESTS))
            setIncompTests(r_[__INCOMPTESTS].toArray().toVariantList());
        if (r_.contains(__FINISHEDTESTS))
            setCompTests(r_[__FINISHEDTESTS].toArray().toVariantList());
        return;
    }
    if (responseType == __SHAREDTESTS) {
        if (r_.contains(__SHAREDTESTS))
            setSharedTests(r_[__SHAREDTESTS].toArray().toVariantList());
        return;
    }
    if (responseType == __CURRENTTEST) {
        if (r_.contains(__CURRENTTEST))
            setTest(r_[__CURRENTTEST].toObject());
    }
    if (responseType == __QUESTIONS) {
        if (r_.contains(__INCOMPLETE))
            setIncomplete(r_[__INCOMPLETE].toArray().toVariantList());
        else if (r_.contains(__PUBLISHED))
            setPublished(r_[__PUBLISHED].toArray().toVariantList());
    }
    if (responseType == __EDITQUESTION)
        if (r_.contains(__QUESTIONFIELD)) {
            editQuestion(r_[__QUESTIONFIELD].toObject().toVariantMap());
            return;
        }
    if (responseType == __NEWCHOICE)
        if (r_.contains(__NEWCHOICE)) {
            addChoice(r_[__NEWCHOICE].toObject().toVariantMap());
            return;
        }
    if (responseType == __VIEWQUESTION)
        if (r_.contains(__VIEWQUESTION)) {
            viewQuestion(r_[__VIEWQUESTION].toObject().toVariantMap());
            return;
        }
    if (responseType == __CHOICECHANGED)
        if (r_.contains(__CHOICECHANGED)) {
            updateSelection(r_[__CHOICECHANGED].toObject().toVariantMap());
            return;
        }
    if (responseType == __PAUSETEST) {
        pauseTest();
        return;
    }
    if (responseType == __PERFORMANCE)
        if (r_.contains(__PERFORMANCE)) {
            viewScore(r_[__PERFORMANCE].toObject().toVariantMap());
            return;
        }
    if (responseType == __ANALYZEQUESTION)
        if (r_.contains(__QUESTIONFIELD))
            analyzeQuestion(r_[__QUESTIONFIELD].toObject().toVariantMap());

    if (responseType == __EDITSHARED)
        if (r_.contains(__SHAREDTEST))
            editSharedTest(r_[__SHAREDTEST].toObject().toVariantMap());

    if (responseType == __SEARCHRESULTS)
        if (r_.contains(__SEARCHRESULTS))
            setSearchRes(r_[__SEARCHRESULTS].toArray().toVariantList());

    if (responseType == __LOGOUT) {
        // Clear everything before logging out. Security risk.
        _user.clear();
        _question.clear();
        setState(login);
    }
}

void QBClient::onObjectReturned(const void *bytes, const size_t size)
{
    // Use the flatbuffer namespace
    using namespace flatbuffers;

    {// Generate a verifier object and ensure integrity
    auto Var = Verifier(reinterpret_cast<const uint8_t*>(bytes),size);
    if (!VerifyQBBufferBuffer(Var)) {
        std::cerr << "Buffer object failed verification." << std::endl;
        return;
    }
    }

    // Access the serialized data
    auto buffer = GetQBBuffer(bytes);

    // Switch to deal with different data types
    switch (buffer->buffer_type()) {
    case BufferType_image:{
        QVariantMap image_metadata;
        auto meta_ = buffer->metadata_as_image_metadata();
        if (meta_->filename())
            image_metadata[__FILENAME] = QString::fromStdString(meta_->filename()->str());
        if (meta_->image_ID())
            image_metadata[__IMGID] = QString::fromStdString(meta_->image_ID()->str());

        // There MUST be a question ID else we do not know if it goes with the current Q
        if (meta_->question_ID())
            image_metadata[__QID] = QString::fromStdString(meta_->question_ID()->str());
        else return;

        if (!buffer->data()) return;
        auto data_ = buffer->data();
        QByteArray raw_bytes(reinterpret_cast<const char*>(data_->Data()),
                             static_cast<int>(data_->size()));
        addImage(image_metadata,raw_bytes);
    } return;
    }

}

void QBClient::resumeSession()
{
    // Return to the login screen if:
    // no user, the sessionID is blank,
    // the token has expired
    if (!_user.contains(__UID) ||
        !_session.session_id.length() ||
        _session.expiration < QDateTime::currentDateTime().toMSecsSinceEpoch()) {
        setState(login);
        return;
    }

    // Log back in with a session token
    QJsonObject request;
    request[__REQUEST] = __SESSION;
    request[__UID] = _user[__UID].toString();
    request[__SID] = _session.session_id;
    transmitRequest(request);
}

void QBClient::transmitRequest(const QJsonObject &obj) const {
    if (obj.contains(__REQUEST) && obj[__REQUEST].isString())
        _socket.sendRequest(QJsonDocument(obj).toJson(QJsonDocument::Compact).toStdString());
}

void QBClient::transmitBinObject(flatbuffers::FlatBufferBuilder& object) const {
    // Instantiate the outgoing string stream and tag it with request tag
    std::ostringstream serialized_(std::ios::binary | std::ios::trunc);

    // Recast the byte stream to allow for string
    const auto ptr  = reinterpret_cast<const char*>(object.GetBufferPointer());
    const auto size = object.GetSize();

    // Wrap a stringified version of the serialized buffer object
    boost::shared_ptr<const std::string> response(new std::string(ptr,size));

    // Generate and transmit the output string;
    // TODO: it would be best to make this a shared_ptr<std::string>
    _socket.sendObject(response);
}

void QBClient::setNotification(const QString &notification)
{
    // Clear out the prior
    _notification.clear();

    // Set the notification
    _notification = notification;

    // Inform QML engine.
    emit notifyChanged();
}

void QBClient::
setState(const states &state)
{
    // Initialize a request object
    // in the event a request is needed
    QJsonObject request;

    _state = state;
    switch (state) {
    case login:
        _user.clear();
        _test.clear();
        _incompleteTests.clear();
        _completeTests.clear();
        _sharedTestEditor.clear();
        _question.clear();
        _images.clear();
        _imageDrawer->clear();
        _incomplete.clear();
        _published.clear();
        _sharedTests.clear();
        _user[__USERNAME] = _persist.value(__USERNAME);
        break;
    case dashboard:
        if (!_user.contains(__UID))
            _state = login;
        _question.clear();
        if (_test.contains(__TID))
            _state = testView;
        break;
    case questionEditor:
        // Clear any outstanding buffers
        _test.clear();
        _images.clear();
        _imageDrawer->clear();
        break;
    case questionAnalysis:
        // Clear any outstanding buffers
        _test.clear();
        _images.clear();
        _imageDrawer->clear();
        break;
    case testView:
        if (!_test.contains(__TID)) {
            _state = dashboard;
        } _question.clear();
        break;
    case scoreView:
        // Clear any outstanding buffers
        _question.clear();
        _images.clear();
        _imageDrawer->clear();
        break;
    case sharedTestView:
        break;
    }
    emit stateChanged();
}

void QBClient::setUser(const QVariantMap &user)
{
    // Asign the user
    _user = user;
    emit userChanged();

    // Change from login screen to user dash

    setState(dashboard);
}

void QBClient::setSession(const QJsonObject &session)
{
    // Assign the session token
    if (session.contains(__SID)) {
        _session.session_id = session[__SID].toString();
        _session.active     = true;
        _session.expiration = session[__EXPIRATION].toString().toLong()/1000;
    }

    if (_keepLogin) {
        _persist.setValue(__UID, _user[__UID].toString());
        _persist.setValue(__SESSION,  QVariant(_session.session_id));
        _persist.setValue(__EXPIRATION, session[__EXPIRATION].toString());
    }

    // Create a renewal thread that renews the session token before expiration
    std::thread([&]{
        // Renew every 10 minutes, before the token expiration.
        std::unique_lock<std::mutex> sessionlocker(_sessionMGMT_MTX);
//        _sessionMGMT.wait_until(sessionlocker,std::chrono::system_clock::now()+std::chrono::seconds(10));
        _sessionMGMT.wait_until(sessionlocker,std::chrono::system_clock::now()+std::chrono::minutes(10));

        // Okay request a new token.
        QJsonObject request;
        request[__REQUEST] = __NEWSESSION;
        transmitRequest(request); // THIS MIGHT NOT BE THREAD SAFE!!!!!!!!!

    // And then detatch this thread to wait in the background
    }).detach();

    // And resume the state if this is a reconnection
//    switch (_state) {
//    case login:
//    case dashboard:
//        return;
//    case questionEditor:
//        if (_question.contains(__QID))
//            editQuestion(_question[__QID].toString());
//        return;
//    case testView:
//        if (_test.contains(__TID))
//            resumeTest(_test[__TID].toString());
//        return;
//    case scoreView:
//        if (_score.contains(__TID))
//            viewScore()
//        return;
//    }
}

void QBClient::setStatistics(const QVariantMap &statistics)
{
    // Assign the statistics
    _user[__STATISTICS] = statistics;

    // Signal they have changed
    emit statisticsChanged();
    emit statsTopicsChanged();
}

void QBClient::setTest(const QJsonObject &test)
{
    // Assign the test object
    _test = test.toVariantMap();
    emit testChanged();

    // If a question isn't already open,
    // request the first question
    if (!_question.contains(__QID))
        questionAt(0);

    // Change to the test view
    if (_state != testView)
        setState(testView);
}

void QBClient::setIncompTests(const QVariantList &incompleteTests)
{
    _incompleteTests = incompleteTests;
    emit incompleteTestsChanged();
}

void QBClient::setCompTests(const QVariantList &finishedTests)
{
    _completeTests = finishedTests;
    emit completeTestsChanged();
}

void QBClient::viewQuestion(const QVariantMap &question)
{
    // Only view the question in the testview context
    if (_state != testView)
        return;

    // Assign the question; no need to change state
    _question = question;

    // Iterate through questions in the test
    if (_test.contains(__QUESTIONS)) {
        const auto& questionList = _test[__QUESTIONS].toList();
        for (auto&& q_ : questionList) {
            const auto& test_Q = q_.toMap();
            if (test_Q.contains(__QID))
                if (question[__QID].toString() == test_Q[__QID].toString()) {
                    if (test_Q.contains(__SELECTION))
                        _question[__SELECTION] = test_Q[__SELECTION];
                    if (test_Q.contains(__SUBMITTED))
                        _question[__SUBMITTED] = test_Q[__SUBMITTED];
                    if (test_Q.contains(__MARKED))
                        _question[__MARKED] = test_Q[__MARKED].toBool();
                }
        }
    }

    emit questionChanged();
    emit publishableChanged();
    emit choicesChanged();
    emit lockedChanged();
    emit markedChanged();
}

void QBClient::setSettings(const QVariantMap &settings)
{
    //Assign the settings
    _settings = settings;

    //And notify of update
    emit settingsChanged();
}

void QBClient::setIncomplete (const QVariantList &list)
{
    _incomplete = list;
    emit incompleteChanged();
}

void QBClient::setPublished (const QVariantList &list)
{
    _published = list;
    emit publishedChanged();
}

void QBClient::setSharedTests (const QVariantList &list) {
    _sharedTests = list;
    emit sharedTestsChanged();
}

void QBClient::editQuestion(const QVariantMap &question)
{
    // Make sure the user is authorized to edit the question
    // The server application does this as well, but a little redudancy never hurts
    // TODO: I need to add collaborator checking as well...
    if (!_user.contains(__UID)) return;
    if (question[__AUTHOR] != _user[__UID])
        return;

    // If there is anything within this buffer, clear it
    _question.clear();

    // Assign the question
    _question = question;

    emit questionChanged();
    emit publishableChanged();

    // Change from the Dashboard to the edit question screen
    setState(questionEditor);
}

void QBClient::addImage(const QVariantMap &metadata, const QByteArray& byteArray)
{
    // Load the image
    QImage image;
    image.loadFromData(byteArray);

    // Check that this image is for the current question
    if (metadata[__QID] != _question[__QID]) return;

    // Add the image to the image repository / drawer for QML access
    _imageDrawer->addImage(metadata[__IMGID].toString(), image);

    // Insert the image id to the list of images
    _images.append(metadata);

    // Inform the GUI engine that an image has been added
    emit imagesChanged();
}

void QBClient::addChoice(const QVariantMap &choiceID)
{
    // Return if a question isn't open
    if(!_question.contains(__QID))
        return;

    // Or if the open question does not match the new choice
    if(_question[__QID] != choiceID[__QID])
        return;

    // Create a variant list to append.
    if(!_question.contains(__CHOICES))
        _question[__CHOICES] = QList<QVariant>();

    // Update the choices list with the new CID
    auto choices = _question[__CHOICES].toList();
    choices.append(qvariant_cast<QVariant>(choiceID));
    _question[__CHOICES] = choices;

    emit choicesChanged();
}

void QBClient::analyzeQuestion(const QVariantMap& question)
{
    // Ensure this is the correct author. It is done on the server
    // side application as well but redundancy never hurts.
    if (!_user.contains(__UID)) return;
    if (question[__AUTHOR] != _user[__UID]) return;

    // If there is anyting within the question buffer, clear it,
    _question.clear();

    // Load this into the question buffer.
    _question = question;

    emit questionChanged();
    emit publishableChanged();

    // Switch the state to analysis
    setState(questionAnalysis);
}

void QBClient::editSharedTest(const QVariantMap &sharedTest)
{
    // Ensure the user is logged in and the author to this test
    if (!_user.contains(__UID)) return;
    if (sharedTest[__AUTHOR] != _user[__UID]) return;

    // If there is a shared test already here, clear it
    _sharedTestEditor.clear();

    // Load this shared test into the editor
    _sharedTestEditor = sharedTest;

    emit sharedTestChanged();

    // Switch the state to the shared test editor
    setState(sharedTestView);
}

void QBClient::updateSelection(const QVariantMap& choice) {
    // Ensure the choice contains the proper entries,
    // and that a test contains questions

    // Unlike QBClient::addChoice, this is not meant to
    // create a list if one does not exist.
    if (!choice.contains(__QID) ||
            !choice.contains(__SELECTION) ||
            !_test.contains(__QUESTIONS))
        return;

    // Iterate through questions to find the right one. Perhaps use a lookup / hash in the future
    auto questionList = _test[__QUESTIONS].toList();
    for (auto&& q_ : questionList) {
        auto question = q_.toMap();
        if (question.contains(__QID))
            // If the choice references this question, update the question
            if (question[__QID].toString() == choice[__QID].toString()) {
                question[__SELECTION] = choice[__SELECTION].toString();
                question[__SUBMITTED] = choice[__SUBMITTED].toString();
                question[__MARKED]    = choice[__MARKED].toString();

                // Copy-construct the question, as references are not allowed...it's stupid.
                q_ = question;
                _test[__QUESTIONS] = questionList;


                // Now for real time update...
                // If the open question,  and is this question, update it as well
                if (_question.contains(__QID))
                    if (_question[__QID].toString() == choice[__QID].toString()) {
                        _question[__SELECTION] = choice[__SELECTION].toString();

                        // If locked status changed.
                        if (_question[__SUBMITTED] != choice[__SUBMITTED].toBool()) {
                            _question[__SUBMITTED] = choice[__SUBMITTED].toBool();
                            emit lockedChanged();
                        }

                        // Some quesitons do not have this flag.
                        if (!_question.contains(__MARKED))
                            _question[__MARKED] = false;
                        // Check if it has changed.
                        if (_question[__MARKED] != choice[__MARKED].toBool()) {
                            _question[__MARKED] = choice[__MARKED].toBool();
                            emit markedChanged();
                        }

                        // And inform the UI that the question has changed
                        emit questionChanged();
                    }

                return;
            }
    }

}

void QBClient::viewScore(const QVariantMap &performance)
{
    // Set the performance
    _score = performance;

    // Emit the state change and set it.
    emit scoreChanged();
    setState(scoreView);
}

void QBClient::setSearchRes(const QVariantList &searchResults)
{
    _searchResults = searchResults;
    emit searchResultsChanged();
}

void QBClient::closeQuestion()
{
    _imageDrawer->clear();
    _question.clear();
    _images.clear();
}

void QBClient::closeShared()
{
    _sharedTestEditor.clear();
}

void QBClient::closeTest()
{
    _test.clear();
    closeQuestion();
}
