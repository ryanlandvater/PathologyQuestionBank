//
//  LoginFrame.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4

Pane {
    id: loginFrame
    width: 360
    height: 650
    anchors.centerIn: parent

    Rectangle {
        id: loginFrameBackground
        anchors.fill: parent
        radius: 5
        opacity: 0.8
        color: "#f7f8f9"

        border.color: "light grey"
        border.width: 3
    }

    Image {
        id: icon
        sourceSize.width: width
        source: "../assets/QBankIcon.svg"
        anchors.top: parent.top
        anchors.topMargin: 10
        width: 256
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }
    Text {
        id: title
        anchors.top: icon.bottom
        anchors.topMargin: 10
        anchors.left: icon.left
        anchors.right: icon.right


        minimumPixelSize: 10
        font.pixelSize: Math.floor(40 * QBClient.screenDPI)
        fontSizeMode: Text.HorizontalFit
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        font.capitalization: Font.AllUppercase
        color:"#00274C"

        text: qsTr("Michigan Pathology\nQuestion Bank")
    }
    TextField{
        id: usernameField
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Math.floor(20*QBClient.screenDPI)
        selectByMouse: true
        font.pixelSize: Math.floor(25*QBClient.screenDPI)
        horizontalAlignment: Text.AlignHCenter
        text: QBClient.user.Username ? QBClient.user.Username : ""
        onFocusChanged: {
            if(focus)
                selectAll();
        }
    } Text{
        id: usernameTitle
        anchors.top: usernameField.bottom
        anchors.left: usernameField.left
        text: qsTr("Username")
        color: "#00274C"
    }

    TextField{
        id: passwordField
        anchors.top: usernameField.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        anchors.bottomMargin: 40
        echoMode: TextInput.Password
        horizontalAlignment: Text.AlignHCenter
        onFocusChanged: {
            if(focus)
                selectAll();
        }
    } Text{
        id: passwordTitle
        anchors.top: passwordField.bottom
        anchors.left: passwordField.left
        text: qsTr("Password")
        color: "#00274C"
    }

    CheckBox {
        id: keepMeLoggedIn
        anchors.top: passwordField.bottom
        anchors.left: passwordField.left
        anchors.margins: 20
        anchors.leftMargin: -leftInset
        onClicked: QBClient.keepLogin = checked
        Component.onCompleted: checked = QBClient.keepLogin
        ToolTip.text: "Do NOT do this on public computers. Sessions expire after 12 hours."
        ToolTip.visible: keepMeLoggedIn.hovered
        Connections {
            target: QBClient
            function onKeepLoginChanged () {
                keepMeLoggedIn.checked = QBClient.keepLogin
            }
        }
        Text {
            anchors.left: keepMeLoggedIn.right
            anchors.verticalCenter: keepMeLoggedIn.verticalCenter
            text: qsTr("Keep me logged in")
            color: "#00274C"
        }

    }
    Button {
        id: loginButton
        Material.background: "#00274C"
        anchors.top: keepMeLoggedIn.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
//        anchors.margins: 20
        enabled: passwordField.text && usernameField.text

        Text {
            anchors.centerIn: parent
            text: qsTr("Login")
            color: "white"
            font.bold: true
        }
        onClicked: QBClient.attemptLogin(usernameField.text,passwordField.text)
    }

    // Make sure that you can press the enter key to log in as well.
    Keys.onPressed: {
        if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                && loginButton.enabled) {
            QBClient.attemptLogin(usernameField.text,passwordField.text)
        }
    }
}
