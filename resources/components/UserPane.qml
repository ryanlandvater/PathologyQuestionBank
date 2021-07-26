//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.4
//import QtQuick.Controls.Material.impl 2.4

Pane {
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.margins: -1
    width: 250

    property var user: QBClient.user


    // BEGIN HEADER BAR STYLE
    background: Item {
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: "#6f8aa3"//"#4a7aa8"//"#607D8B"
        } Image {
            anchors.fill: parent
            sourceSize.width: 512
            sourceSize.height: 512
            source: "../assets/backgrn_tile_white.svg"
            fillMode: Image.Tile
            opacity: 0.1
            horizontalAlignment: Image.AlignLeft
            verticalAlignment: Image.AlignTop
        } Rectangle{
            anchors.fill: parent
            gradient: Gradient{
                GradientStop{position: 0; color: "transparent"}
                GradientStop{position: 1; color: "#00274C"}//"#3f5b68"}
            }
        }
    }
    // ENDING: STYLE ENDING

    // PATIENT INFORMATION
//    Image {
//        id: photo
//        source: "../assets/missingPhoto.png"
//        width: 150
//        height: 150
//        antialiasing: true
//        fillMode: Image.PreserveAspectFit
//        anchors.top: parent.top
//        anchors.horizontalCenter: parent.horizontalCenter

//    }
    Text {
        id: firstName
        text: user.UserFirstName
//        anchors.top: photo.bottom
//        anchors.topMargin: -10
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.1
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        color: "White"
        minimumPixelSize: 10
        font.pixelSize: lastName.font.pixelSize - Math.floor(10* QBClient.screenDPI)
        fontSizeMode: Text.HorizontalFit
    } Text {
        id: lastName
        text: user.UserLastName
        anchors.top: firstName.bottom
        anchors.topMargin: -10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        color: "White"
        minimumPixelSize: 10
        font.pixelSize: Math.floor(60* QBClient.screenDPI)
        fontSizeMode: Text.HorizontalFit
    }
    Text {
        id: userID_text
        text: qsTr("User ID:  ") + user.UserID

        anchors.top: lastName.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        color: "White"
        font.italic: true
        minimumPixelSize: 10
        font.pixelSize: Math.floor (30* QBClient.screenDPI)
        fontSizeMode: Text.HorizontalFit
    }
//    Button {
//        anchors.fill: userID_text
//        visible: false
//        ToolTip.visible: hovered
//        ToolTip.text: qsTr("Click to copy user id")
//        hoverEnabled: true
//        onClicked:
//    }

    Item {
        anchors.top: userID_text.bottom
        anchors.bottom: icon.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: 20
            move: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 }
            }
            add: Transition {
                NumberAnimation { properties: "x,y"; duration: 200 }
            }
            populate: Transition {
                NumberAnimation { properties: "x,y"; duration: 400 }
            }

            Rectangle {
                property bool hovered: closeMouseArea.containsMouse
                height: 40
                width: parent.width
                border.color: hovered ? "white" : "#dedede"
                border.width: 4
                radius: 5
                color: "transparent"
//                layer.enabled: true
//                layer.effect: ElevationEffect {elevation: hovered ? 3:1}
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Logout")
                    color: parent.hovered ? "white" : "#dedede"
                    font.pixelSize: Math.floor (18* QBClient.screenDPI)
                    font.bold: true
                } MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: QBClient.logout()
                }
            }
            Rectangle {
                property bool hovered: newTestMouseArea.containsMouse
                height: 40
                width: parent.width
                border.color: hovered ? "white" : "#dedede"
                border.width: 4
                radius: 5
                color: "transparent"
                visible: if (dashboardSwipe)
                             dashboardSwipe.currentIndex !== 0
                         else false
                Text {
                    anchors.centerIn: parent
                    text: qsTr("New Test")
                    color: parent.hovered ? "white" : "#dedede"
                    font.pixelSize: Math.floor(18* QBClient.screenDPI)
                    font.bold: true
                } MouseArea {
                    id: newTestMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: dashboardSwipe.setCurrentIndex(0)
                }
            }
            Rectangle {
                property bool hovered: writerMouseArea.containsMouse
                height: 40
                width: parent.width
                border.color: hovered ? "white" : "#dedede"
                border.width: 4
                radius: 5
                color: "transparent"
                visible: if (dashboardSwipe)
                             dashboardSwipe.currentIndex !== 2
                         else false
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Question Writer")
                    color: parent.hovered ? "white" : "#dedede"
                    font.pixelSize: Math.floor (18* QBClient.screenDPI)
                    font.bold: true
                } MouseArea {
                    id: writerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: dashboardSwipe.setCurrentIndex(2)
                }
            }
            Rectangle {
                property bool hovered: userOptionsMouseArea.containsMouse
                height: 40
                width: parent.width
                border.color: hovered ? "white" : "#dedede"
                border.width: 4
                radius: 5
                color: "transparent"
                visible: if (dashboardSwipe)
                             dashboardSwipe.currentIndex !== 3
                         else false
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Settings")
                    color: parent.hovered ? "white" : "#dedede"
                    font.pixelSize: Math.floor(18* QBClient.screenDPI)
                    font.bold: true
                } MouseArea {
                    id: userOptionsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: userPopup.open()
                }
            }
        }
    }

    // ICON BEGIN
    Image {
        id: icon
        width: parent.width/2
        sourceSize.width: width
        source: "../assets/whiteLogo.svg"
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        anchors.bottom: qbankTitle.top
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 80

    }
    Text {
        id: qbankTitle
        anchors.bottom: copyrightTitle.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        text: qsTr("Pathology QBank")
        color: "White"
        font.pixelSize: Math.floor(24* QBClient.screenDPI)
    }
    Text {
        id: copyrightTitle
        anchors.bottom: version.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        text: qsTr("Ryan Landvater © 2021, Michigan Pathology")
        color: "White"
        font.pixelSize: Math.floor(9* QBClient.screenDPI)
        font.italic: true
    }
    Text {
        id: version
        anchors.bottom: parent.bottom
        anchors.left: qbankTitle.left
        anchors.right: qbankTitle.right
        text: qsTr("Version 0.5")
        color: "White"
    }
    // ENDING ICON
    UserProfilePopup {
        id: userPopup
    }
}
// ENDING : HERE IS THE HEADER BAR ENDING
