//
//  main.cpp
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. Please review LICENCE agreement.

#define _WIN32_WINNT_WIN10                  0x0A00 // Windows 10
#include <QtWidgets/QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QXmlStreamReader>
#include <QQmlContext>

#include "qbwebsocketsession.h"
#include "qbclient.h"

//#define DEBUG                   // UNCOMMENT FOR DEBUG BUILD (local server)
// Define application properties
struct properties {
    int majorVersion            = VERSION_MAJOR;
    int minorVersion            = VERSION_MINOR;
    int build                   = VERSION_BUILD;
    bool debug                  = false;
#ifdef DEBUG
    std::string IP              = "127.0.0.1";
    std::string port            = "8080";
    QString ApplicationName     = "Question Bank DEBUG BUILD";
#else
    const std::string IP        = "3.96.6.244";
    const std::string port      = "1239";
    const QString AppName       = "Michigan Pathology Question Bank";
#endif
    QString OrganizationName    = "Michigan Medicine Pathology";
    QString OrganizationDomain  = "pathology.med.umich.edu";
} properties;

// BEGINING MAIN ~~~~~~~~~~~~~
int main(int argc, char *argv[])
{
    /*~~~~~~~~~~~~~~~ GENERATE GUI engine ~~~~~~~~~~~~~~~~~~~~*/
    // Enable highDPI scaling for high res screens
    QCoreApplication::setOrganizationName  (properties.OrganizationName);
    QCoreApplication::setOrganizationDomain(properties.OrganizationDomain);
    QCoreApplication::setApplicationName   (properties.AppName);
    QCoreApplication::setAttribute         (Qt::AA_EnableHighDpiScaling);

    // Create and instantiate the application
    QApplication app(argc, argv);
    // Using QML to render the UI... Instantiate QML Engine
    QQmlApplicationEngine engine;
    // Provide the address of the QML markup file
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    /*~~~~~~~~~ GENERATE "NUTS AND BOLTS" OF APPLICATION ~~~~~~~~~~~~*/
    // Generate our websocketsession and application controller
    boost::shared_ptr<QBWebSocketSession>
    websocket(new QBWebSocketSession(properties.IP, properties.port));

    boost::shared_ptr<QBClient>
    controller(new QBClient(&engine,websocket.get()));

    /*~~~~~~~~~~~~~~~~~ START THE WEBSOCKET CONNECTION ROUTINE ~~~~~~~~~~~*/
    websocket->run();

    /* ~~~~~~~~~~~~~~~~ OPEN THE APPLICATION GUI / UX ENGINE ~~~~~~~~~~~*/
    engine.rootContext()->setContextProperty("APP_NAME", properties.AppName);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    // Allow for loading of the material style
    QQuickStyle::setStyle("Material");
    engine.load(url);


    // This will not return until the application has been closed.
    app.exec();

    // Inform the websocket that the application is closing.
    websocket->stop();

    // Stop the engine and clear it's cache
    engine.clearComponentCache();

    // Return success.
    return EXIT_SUCCESS;
}
