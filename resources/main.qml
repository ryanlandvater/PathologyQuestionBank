//
//  main.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.4
//import QtCharts 2.15

ApplicationWindow {
    id: applicationWindowRoot

    // General layout
    visible: true
    Material.theme: Material.Light
    Material.accent: "#00274C"

    width: 1040
    height: 800
    minimumWidth: 810
    minimumHeight: 650
    title: qsTr(APP_NAME)

    Component.onCompleted: {
        QBClient.screenDPI = Screen.pixelDensity/4.46
    }

    // State switching between pages
    Item {
        id: stateSwitcher
        state: QBClient ? QBClient.state : "NULL"
        states: [
            State {
                name: "NULL"
                PropertyChanges {
                    target: pageLoader
                    source: ""
                }
            },
            State {
                name: "login"
                PropertyChanges {
                    target: pageLoader
                    source: "/login.qml"
                }
            },
            State {
                name: "dashboard"
                PropertyChanges {
                    target: pageLoader
                    source: "/dashboard.qml"
                }
            },
            State {
                name: "questionEditor"
                PropertyChanges {
                    target: pageLoader
                    source: "/questionEditor.qml"
                }
            },
            State {
                name: "questionAnalysis"
                PropertyChanges {
                    target: pageLoader
                    source: "/questionAnalytics.qml"
                }
            },
            State {
                name: "test"
                PropertyChanges {
                    target: pageLoader
                    source: "/testView.qml"
                }
            },
            State {
                name: "score"
                PropertyChanges {
                    target: pageLoader
                    source: "/scoreView.qml"
                }
            },
            State {
                name: "sharedTestEditor"
                PropertyChanges {
                    target: pageLoader
                    source: "/sharedTest.qml"
                }
            }

        ]
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
    }
    Popup {
        id: connectingLoaderPopup
        property var connected: QBClient.connected ? QBClient.connected:false
        parent: Overlay.overlay
        anchors.centerIn: parent
        height: parent/3
        width: parent/3


        closePolicy: Popup.NoAutoClose
        modal: true
        background: Rectangle{color: "transparent"}
        onConnectedChanged: if (connected) close(); else open();

        Rectangle {
            anchors.fill: parent
            BusyIndicator{ id:i; anchors.centerIn:parent; running:true;
                Material.elevation: 4; Material.accent: "white"}
            Text{ text:  "Establishing a Connection to the QBank Server..."
                anchors.top: i.bottom; anchors.horizontalCenter: parent.horizontalCenter
                color: "white"; font.bold: true; font.capitalization: Font.SmallCaps}
        }
    }
    Popup {
        id: notificationPopup
        parent: Overlay.overlay
        contentHeight: notificationText.height
        contentWidth: notificationText.width
        padding: 20
        topInset: 10
        leftInset: 10
        rightInset: 10
        bottomInset: 10

        opacity: 0.7
        modal: false
        closePolicy: Popup.NoAutoClose
        Text{
            id: notificationText


            text: qsTr(QBClient.notify)
            color: Material.accent
            font.bold: true
            font.pixelSize: Math.floor(20 * QBClient.screenDPI)


            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Connections {
            target: QBClient
            function onNotifyChanged() {
                notificationPopup.open()
                fadeTimer.restart()
            }
        } enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 7.0; duration: 1000 }
        } exit: Transition {
            NumberAnimation { property: "opacity"; from: 7.0; to: 0.0; duration: 2000 }
        } Timer {
            id: fadeTimer
            interval: 2000
            onTriggered: notificationPopup.close()
        }
    }

//    contentData: [
//        // Page loader that draws appropriate UI
//        Loader {
//            id: pageLoader
//            anchors.fill: parent
//        }
//    ]
    // Menu
//    menuBar: MenuBar {
//        Menu {
//            title: qsTr("&File")
//            Action { text: qsTr("&New...") }
//            MenuSeparator { }
//            Action { text: qsTr("&Quit") }
//        }
//    }
}
