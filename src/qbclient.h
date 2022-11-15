//
//  qbclient.h
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

#ifndef QBCLIENT_H
#define QBCLIENT_H

#include <QObject>
#include <QFile>
#include <QVariantMap>
#include <QJsonObject>
#include <QSettings>
#include <optional>
#include <mutex>
#include <condition_variable>

#include "QBBuffer_generated.h"

#ifdef WIN64
#define BIN_PROTOCOL false
#else
#define BIN_PROTOCOL false
#endif

class   QQmlApplicationEngine;
class   QBWebSocketSession;
class   QBImageProvider;

struct  QBSession {
    QString     session_id;
    long        expiration;
    bool active = false;
};

class QBClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString notify             READ notify       NOTIFY notifyChanged)
    Q_PROPERTY(QString state              READ state        NOTIFY stateChanged)
    Q_PROPERTY(bool connected             READ connected    NOTIFY connectedChanged)
    Q_PROPERTY(QVariantMap user           READ user         NOTIFY userChanged)
    Q_PROPERTY(QVariantMap settings       READ settings     NOTIFY settingsChanged)
    Q_PROPERTY(QVariantMap statistics     READ statistics   NOTIFY statisticsChanged)
    Q_PROPERTY(QVariantList statsTopics   READ statsTopics  NOTIFY statsTopicsChanged)
    Q_PROPERTY(QVariantMap test           READ test         NOTIFY testChanged)
    Q_PROPERTY(QVariantMap score          READ score        NOTIFY scoreChanged)
    Q_PROPERTY(QVariantMap sharedTest     READ sharedTest   NOTIFY sharedTestChanged)
    Q_PROPERTY(QVariantList scoreTopics   READ scoreTopics  NOTIFY scoreTopicsChanged)
    Q_PROPERTY(QVariantList incompleteTests READ incompleteTests NOTIFY incompleteTestsChanged)
    Q_PROPERTY(QVariantList completeTests READ completeTests NOTIFY completeTestsChanged)
    Q_PROPERTY(QVariantList sharedTests   READ sharedTests  NOTIFY sharedTestsChanged)
    Q_PROPERTY(QVariantMap question       READ question     NOTIFY questionChanged)
    Q_PROPERTY(QList<QVariantMap> images  READ images       NOTIFY imagesChanged)
    Q_PROPERTY(QVariantList choices       READ choices      NOTIFY choicesChanged)
    Q_PROPERTY(bool locked                READ locked       NOTIFY lockedChanged)
    Q_PROPERTY(bool marked                READ marked       NOTIFY markedChanged)
    Q_PROPERTY(QVariantList incomplete    READ incomplete   NOTIFY incompleteChanged)
    Q_PROPERTY(bool publishable           READ publishable  NOTIFY publishableChanged)
    Q_PROPERTY(QVariantList published     READ published    NOTIFY publishedChanged)
    Q_PROPERTY(qreal screenDPI READ screenDPI WRITE setScreenDPI NOTIFY screenDPIChanged)
    Q_PROPERTY(bool keepLogin  READ keepLogin WRITE setKeepLogin NOTIFY keepLoginChanged)
    Q_PROPERTY(bool oustandingSearch      READ outstandingSearch NOTIFY outstandingSearchChanged)
    Q_PROPERTY(QVariantList searchResults READ searchResults NOTIFY searchResultsChanged)


    enum states {
        login,
        dashboard,
        questionEditor,
        questionAnalysis,
        testView,
        scoreView,
        sharedTestView
    };
    QQmlApplicationEngine*  _engine;
    QBWebSocketSession&     _socket;
    QBImageProvider*        _imageDrawer;
    QBSession               _session;
    QSettings               _persist;
    std::condition_variable _sessionMGMT;
    std::mutex              _sessionMGMT_MTX;
    states                  _state;
    bool                    _keepLogin;
    bool                    _debug;
    bool                    _connected;
    bool                    _outstandingSearch;

    QString                 _notification;
    QVariantMap             _settings;
    QVariantMap             _user;
    QVariantMap             _test;
    QVariantMap             _score;
    QVariantMap             _sharedTestEditor;
    QVariantList            _incompleteTests;
    QVariantList            _completeTests;
    QVariantList            _sharedTests;
    QVariantList            _searchResults;
    QVariantMap             _question;
    QList<QVariantMap>      _images;
    QVariantList            _incomplete;
    QVariantList            _published;

    qreal                   _screenDPI;

public:
    explicit QBClient(QQmlApplicationEngine* engine,
                      QBWebSocketSession* socket,
                      bool debug = false,
                      QObject* parent = nullptr);
    ~QBClient();

    // Check connection status
    void connectionChanged();

    // Getter methods
    QString             notify()        const;
    QString             state()         const;
    bool                connected()     const;
    bool                keepLogin()     const;
    bool                outstandingSearch() const;
    QVariantMap         user()          const;
    QVariantMap         settings()      const;
    QVariantMap         statistics()    const;
    QVariantList        statsTopics()   const;
    QVariantMap         test()          const;
    QVariantMap         score()         const;
    QVariantMap         sharedTest()    const;
    QVariantList        scoreTopics()   const;
    QVariantList        incompleteTests() const;
    QVariantList        completeTests() const;
    QVariantList        sharedTests()   const;
    QVariantMap         question()      const;
    QList<QVariantMap>  images()        const;
    QVariantList        choices()       const;
    bool                locked()        const;
    bool                marked()        const;
    QVariantList        incomplete()    const;
    bool                publishable()   const;
    QVariantList        published()     const;
    QVariantList        searchResults() const;

    // QML invokable methods
    Q_INVOKABLE void attemptLogin       (QString usrname,
                                         QString pswrd);
                void attemptResume      ();
    Q_INVOKABLE void updatePassword     (QString& PAS,
                                         QString& NEW);
    Q_INVOKABLE void logout             ();

    // Editor Methods
    Q_INVOKABLE void createQuestion     ();
    Q_INVOKABLE void createSharedTest   ();
    Q_INVOKABLE void updateQuestion     (const QString& field,
                                         const QString& updatedText);
    Q_INVOKABLE void editQuestion       (const QString& QID);
    Q_INVOKABLE void editSharedTest     (const QString& STID);
    Q_INVOKABLE void uploadImage        (const QString& filePath);
    Q_INVOKABLE void removeImage        (const QString& ImageID);
    Q_INVOKABLE void addAnswerChoice    ();
    Q_INVOKABLE void updateChoice       (const QString& CID,
                                         const QString& field,
                                         const QString& updatedText);
    Q_INVOKABLE void removeChoice       (const QString& CID);
    Q_INVOKABLE void assignAnswer       (const QString& CID);
    Q_INVOKABLE bool containsTags       (const QString& tag);
    Q_INVOKABLE void assignTag          (const QString& field,
                                         const QString& tag, bool);
    Q_INVOKABLE void publishQuestion    (const QString& confirmQID);
    Q_INVOKABLE void deleteQuestion     (const QString& confirmQID);
    Q_INVOKABLE void updateSharedTest   (const QString& field,
                                         const QString& update);
    Q_INVOKABLE void closeEditor        ();


    // Analysis methods
    Q_INVOKABLE void analyzeQuestion    (const QString& QID);

    // Test Generator Methods
    Q_INVOKABLE void generateTest       (const QString& status,
                                         const QStringList& tags,
                                         const int number,
                                         const bool jmode);
    Q_INVOKABLE void resumeTest         (const QString& TID);
    Q_INVOKABLE void questionAt         (const int index);
    Q_INVOKABLE void pauseTest          ();
    Q_INVOKABLE void selectAnswer       (const QString& CID);
    Q_INVOKABLE void submitAnswer       ();
    Q_INVOKABLE void toggleMarked       (const int curIndex);
    Q_INVOKABLE void submitTest         ();

    // Searching
    Q_INVOKABLE void search             (const QString& criterion,
                                         const QString& term);
    Q_INVOKABLE void clearSearch        ();

    // SetScreen DPI
    qreal screenDPI() const;
    void setScreenDPI(const qreal &screenDPI);
    void setKeepLogin(const bool& status);

signals:
    void keepLoginChanged();
    void notifyChanged();
    void stateChanged();
    void connectedChanged();
    void outstandingSearchChanged();
    void incompleteTestsChanged();
    void completeTestsChanged();
    void sharedTestsChanged();
    void settingsChanged();
    void statisticsChanged();
    void statsTopicsChanged();
    void testChanged();
    void scoreChanged();
    void sharedTestChanged();
    void scoreTopicsChanged();
    void userChanged();
    void questionChanged();
    void imagesChanged();
    void choicesChanged();
    void lockedChanged();
    void markedChanged();
    void incompleteChanged();
    void publishableChanged();
    void publishedChanged();
    void screenDPIChanged();
    void searchResultsChanged();

public slots:
    void onResponseReturned (const QString&);
    void onObjectReturned   (const void *bytes,
                             const size_t size);

private:
    void resumeSession      ();
    void transmitRequest    (const QJsonObject& obj) const;
    void transmitBinObject  (flatbuffers::FlatBufferBuilder& object) const;

    // Setter methods. These are private.
    void setNotification(const QString& notification);
    void setState       (const states &state);
    void setUser        (const QVariantMap& user);
    void setSession     (const QJsonObject& session);
    void setStatistics  (const QVariantMap& statistics);
    void setTest        (const QJsonObject& test);
    void setIncompTests (const QVariantList& incompleteTest);
    void setCompTests   (const QVariantList& finishedTests);
    void viewQuestion   (const QVariantMap& question);
    void setSettings    (const QVariantMap& settings);
    void setIncomplete  (const QVariantList& list);
    void setPublished   (const QVariantList& list);
    void setSharedTests (const QVariantList& list);
    void editQuestion   (const QVariantMap& question);
    void addImage       (const QVariantMap& metadata,
                         const QByteArray& byteArray);
    void addChoice      (const QVariantMap& choiceID);
    void analyzeQuestion(const QVariantMap& question);
    void editSharedTest (const QVariantMap& sharedTest);
    void updateSelection(const QVariantMap& choice);
    void viewScore      (const QVariantMap& performance);
    void setSearchRes   (const QVariantList& searchResults);

    void closeQuestion  ();
    void closeShared    ();
    void closeTest      ();
};

#endif // QBCLIENT_H
