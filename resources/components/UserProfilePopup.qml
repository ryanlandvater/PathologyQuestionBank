//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.9
import QtQuick 2.15
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.4

Popup {
    id: userPopup
    parent: Overlay.overlay
    anchors.centerIn: parent
    height: parent.height/2
    width: parent.width/2
    modal: true
    onClosed: userSwipe.setCurrentIndex(0)
    Item {
        anchors.fill: parent
        Text {
            id: userPopupTitle
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            text: qsTr(" User Profile for "+QBClient.user.UserFirstName
                       + " " + QBClient.user.UserLastName)
            color: "#00274C"
            font.bold:true
            minimumPixelSize: 10
            font.pixelSize: Math.floor (30* QBClient.screenDPI)
            fontSizeMode: Text.HorizontalFit
            horizontalAlignment: Text.AlignHCenter
//                font.capitalization: Font.SmallCaps
        }
        SwipeView {
            id: userSwipe
            anchors.top: userPopupTitle.bottom
            anchors.topMargin: 5
            anchors.bottom: closePopupButton.top
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true
            interactive: false
            Column {
                spacing: 20
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    text:qsTr(QBClient.user.UserAuthorRole ?
                                  "Author Privilages <b>enabled</b>":
                                  "Author Privilages <b>disabled</b>")
                }
                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    text: qsTr(QBClient.user.UserAdminRole === "true" ?
                               "Administrator Privilages <b>enabled</b>" :
                               "Administrator Privilages <b>disabled</b>")
                }
                Button {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    height: 50
                    Material.background: "#00274C"
                    onClicked: userSwipe.setCurrentIndex(1)
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Change Your Password")
                        color: "white"
                        font.bold:true
                    }
                }
            }
            Column {
                spacing: 20
                TextField{
                    id: oldPasswordField
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
                    Text{
                        anchors.top: oldPasswordField.bottom
                        anchors.left: oldPasswordField.left
                        text: qsTr("Previous Password")
                        color: "#00274C"
                    }
                } TextField {
                    id: newPasswordField
                    property bool valid: false
                    onTextChanged: {
                        valid = text.search(/(?=.*[0-9]+)(?=.*[A-Z])(?=.*[a-z])(?=.{8,})/) === 0;
                    }
                    validator: RegularExpressionValidator {regularExpression: /(?=.*[0-9]+)(?=.*[A-Z])(?=.*[a-z])(?=.{8,})/}
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20
                    echoMode: TextInput.Password
                    horizontalAlignment: Text.AlignHCenter
                    placeholderText:"Requires 8 characters with upper and lower case, and number"
                    onFocusChanged: {
                        if(focus)
                            selectAll();
                    } Text{
                        anchors.top: newPasswordField.bottom
                        anchors.left: newPasswordField.left
                        text: qsTr("New Password")
                        color: "#00274C"
                    }
                } TextField {
                    id: rePasswordField
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20
                    echoMode: TextInput.Password
                    horizontalAlignment: Text.AlignHCenter
                    placeholderText: "Requires 8 characters with upper and lower case, and number"
                    onFocusChanged: {
                        if(focus)
                            selectAll();
                    }
                    Text{
                        anchors.top: rePasswordField.bottom
                        anchors.left: rePasswordField.left
                        text: qsTr("Retype Password")
                        color: "#00274C"
                    }
                }

                Rectangle{height:1;width:1;color:"transparent"} Button {
                    property bool match: newPasswordField.text===rePasswordField.text
                                         && newPasswordField.valid
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    height: 50
                    Material.background: "#00274C"
                    enabled: newPasswordField.text===rePasswordField.text && newPasswordField.valid
                    onClicked: QBClient.updatePassword(oldPasswordField.text,newPasswordField.text);
                    Text {
                        anchors.centerIn: parent
                        text: qsTr(parent.match ? "Submit Updated Password" :
                                       newPasswordField.valid ?"Passwords Don't Match" :
                                       "Requirements Not Met")
                        color: parent.match ? "white" : "#c90000"
                        font.bold:true
                    }
                }
            }
        }
        Button {
            id: closePopupButton
            Material.background: "#c90000"
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            Text {
                anchors.centerIn: parent
                text: qsTr("Close")
                color: "white"
                font.bold:true
            }
            onClicked: userPopup.close()
        }
    }
}
