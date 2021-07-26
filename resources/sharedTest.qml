//
//  sharedTest.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 12/6/20.
//  Copyright Â© 2020 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3

import "./components/"

Item {
    id: sharedTestRoot
    anchors.fill: parent

    ScrollView {
        id: sharedScrollView
        property ScrollBar vScrollBar: ScrollBar.vertical
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        anchors.top: parent.top
        anchors.bottom: exitEditorButtons.top
        anchors.left: userPaneRoot.right
        anchors.leftMargin: 10
        anchors.right: sharedTestRoot.right
        anchors.rightMargin: 10
        clip: true
        focus: true

        Column {
            id: sharedMainColumn
            anchors.top: parent.top
            width: sharedScrollView.width - (2*sharedScrollView.vScrollBar.width)
            anchors.left: parent.left
            anchors.leftMargin: sharedScrollView.vScrollBar.width
            spacing: 25

            // SHARED TEST TITLE
            Text {
                id: questionEditorTitle
                width: sharedMainColumn.width
                wrapMode: "WordWrap"

                text: qsTr("<b>Shared Test Editor</b> for Test: ") +
                      (sharedTestNameField.length ?
                           "<i><b>"+"\"" + sharedTestNameField.text + "\" </b></i>" :
                           "<i>" + QBClient.sharedTest.SharedTestID +"</i>")
                color: "#3f5b68"
                minimumPixelSize: 5
                font.pixelSize: Math.floor(25* QBClient.screenDPI)
                horizontalAlignment: Text.AlignHCenter

            }
            // END SHARED TEST TITLE

            // SHARED TEST NAME
            TextField {
                id: sharedTestNameField
                width: sharedMainColumn.width
                wrapMode: "WordWrap"
                selectByMouse: true
                onEditingFinished: QBClient.updateSharedTest("SharedTestName",text);
                text: QBClient.sharedTest.SharedTestName ? QBClient.sharedTest.SharedTestName : ""
                placeholderText: qsTr("This is for you or your collaborators, hoping to easily identify this shared test.")
                Text {
                    id: sharedTestNameFieldTitle
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    color: "navy"

                    text: qsTr("Shared Test Name")
                }
            }
            // END SHARED TEST NAME

            // THIS IS WHERE PERFORMANCE WILL GO
            // PERFORMANCE!!!!!!!!!!!!!!!!!! GRAPHS!

            // START QUESTION LIST
            Column {
                width: sharedMainColumn.width
                spacing: 10

                Text {
                    id: questionListTitle
                    width: sharedScrollView.width
                    text: qsTr("Questions in the Test")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.SmallCaps
                    font.pixelSize: Math.floor (20* QBClient.screenDPI)
                }

                SearchField {
                    id: questionSearch
                    searchCriterion: "QuestionName"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    placeholder: qsTr("Begin Searching for a <b>Question</b> to Add")
                    choices.delegate: questionDelegate
                    onSelected: {
                        QBClient.updateSharedTest("AddQuestion",choices.model[choices.currentIndex].QuestionID)
                        questionSearch.popup.close()
                    }
                } Component {
                    id: questionDelegate
                    Rectangle {
                        id: buttonBackground
                        property string mainAccent: "#0b3b7a"
                        property int currentIndex: questionSearch.choices.currentIndex
                        property string textColor: index === currentIndex ? mainAccent : "grey"
                        height: questionSearch.buttonHeight
                        width: parent.width
                        color: "transparent"
                        Text {
                            id: buttonTextLeft
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            text: model.modelData.QuestionName
                            ? model.modelData.QuestionName
                            : "Question ID: <i>"+ model.modelData.QuestionID+"</i>"
                            color: parent.textColor
                            font.bold: index === parent.currentIndex
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                        } Rectangle {
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.9
                            height: 1
                            color: "light grey"
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onHoveredChanged: {
                                if (containsMouse)
                                    questionSearch.choices.currentIndex = index
                            } onClicked: {
                                QBClient.updateSharedTest("AddQuestion",model.modelData.QuestionID)
                                questionSearch.popup.close()
                            }
                        }
                    }
                }

                Repeater {
                    id: questionList
                    model: QBClient.sharedTest.QuestionIDs

                    delegate: Pane {
                        id: questionPane

                        property int radius: 10
                        Material.background: Material.backgroundColor
                        Material.elevation: 2

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 40
                        background: Rectangle {
                            border.color: deleteQuestionMouseArea.containsMouse
                                          ? "#F44336" : "#0b3b7a"
                            border.width: 2
                            color: questionPane.Material.backgroundColor
                            radius: questionPane.Material.elevation > 0 ? questionPane.radius : 0
                            layer.enabled: questionPane.enabled
                                           && questionPane.Material.elevation > 0
                            layer.effect: ElevationEffect {
                                elevation: questionPane.Material.elevation
                            }
                            Item {
                                id: deleteQuestionButton
                                width: 80
                                height: 20
                                anchors.right: parent.right
                                anchors.rightMargin: parent.radius
                                anchors.top: parent.top
                                anchors.topMargin: parent.border.width
                                clip: true
                                Rectangle {
                                    id: rad
                                    anchors.fill: parent
                                    anchors.topMargin: - radius
                                    color: deleteQuestionMouseArea.containsMouse
                                           ? "#F44336" : "#0b3b7a"
                                    radius: 5
                                } Text {
                                    id: removeQuestionText
                                    text: qsTr("Remove")
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.bottom: rad.bottom
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                } MouseArea {
                                    id: deleteQuestionMouseArea
                                    anchors.top: parent.top
                                    anchors.bottom: rad.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    hoverEnabled: true
                                    onClicked:QBClient.updateSharedTest("RemoveQuestion",model.modelData.QuestionID)
                                }
                            }
                        }
                        Text {
                            id: questions
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            text: model.modelData.QuestionName
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            color: deleteQuestionMouseArea.containsMouse
                                   ? "#F44336" : "#0b3b7a"
                            font.pixelSize: Math.floor(16* QBClient.screenDPI)
                            font.bold: true
                        }
                    }
                }
            }
            // END QUESTION LIST

            // BEGIN USER LIST
            Column {
                width: sharedMainColumn.width
                spacing: 10

                Text {
                    id: userListTitle
                    width: sharedMainColumn.width
                    text: qsTr("Users to whom Test is Deployed")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.capitalization: Font.SmallCaps
                    font.pixelSize: Math.floor (20* QBClient.screenDPI)
                }
                SearchField {
                    id: userSearch
                    searchCriterion: "Username"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: sharedScrollView.width - 40
                    placeholder: qsTr("Begin Searching for a <b>User</b> to Add")
                    choices.delegate:usersDelegate
                    onSelected: {
                        var UID = choices.model[choices.currentIndex].UserID;
                        QBClient.updateSharedTest("AddUser",choices.model[choices.currentIndex].UserID)
                        popup.close()
                    }
                } Component {
                    id: usersDelegate
                    Rectangle {
                        id: buttonBackground
                        property string mainAccent: "#0d7d12"
                        property int currentIndex: userSearch.choices.currentIndex
                        property string textColor: index === currentIndex ? mainAccent : "grey"
                        height: userSearch.buttonHeight
                        width: parent.width
                        color: "transparent"
                        Text {
                            id: buttonTextLeft
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            text: model.modelData.UserFirstName + " "
                                  + model.modelData.UserLastName + " <i>("
                                  + model.modelData.Username + ")</i>"
                            color: parent.textColor
                            font.bold: index === parent.currentIndex
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                        } Rectangle {
                            anchors.top: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.9
                            height: 1
                            color: "light grey"
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onHoveredChanged: {
                                if (containsMouse)
                                    userSearch.choices.currentIndex = index
                            } onClicked: {
                                QBClient.updateSharedTest("AddUser",model.modelData.UserID)
                                userSearch.popup.close()
                            }
                        }
                    }
                }

                Repeater {
                    id: userList
                    model: QBClient.sharedTest.UserIDs

                    delegate: Pane {
                        id: userPane

                        property int radius: 10
                        Material.background: Material.backgroundColor
                        Material.elevation: 2

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 40
                        background: Rectangle {
                            border.color: deleteUserMouseArea.containsMouse
                                          ? "#F44336" : "#0d7d12"
                            border.width: 2
                            color: userPane.Material.backgroundColor
                            radius: userPane.Material.elevation > 0 ? userPane.radius : 0
                            layer.enabled: userPane.enabled
                                           && userPane.Material.elevation > 0
                            layer.effect: ElevationEffect {
                                elevation: userPane.Material.elevation
                            }
                            Item {
                                id: deleteUserButton
                                width: 80
                                height: 20
                                anchors.right: parent.right
                                anchors.rightMargin: parent.radius
                                anchors.top: parent.top
                                anchors.topMargin: parent.border.width
                                clip: true
                                Rectangle {
                                    id: rad2
                                    anchors.fill: parent
                                    anchors.topMargin: - radius
                                    color: deleteUserMouseArea.containsMouse
                                           ? "#F44336" : "#0d7d12"
                                    radius: 5
                                } Text {
                                    id: removeText
                                    text: qsTr("Remove")
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.left: parent.left
                                    anchors.bottom: rad2.bottom
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: "white"
                                } MouseArea {
                                    id: deleteUserMouseArea
                                    anchors.top: parent.top
                                    anchors.bottom: rad2.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    hoverEnabled: true
                                    onClicked:QBClient.updateSharedTest("RemoveUser",model.modelData.UserID)
                                }
                            }
                        }
                        Text {
                            id: users
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            text: model.modelData.UserFirstName + " "
                                  + model.modelData.UserLastName + " <i>("
                                   + model.modelData.Username + ")</i>"
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            color: deleteUserMouseArea.containsMouse
                                   ? "#F44336" : "#0d7d12"
                            font.pixelSize: Math.floor(12* QBClient.screenDPI)
                            font.bold: true
                        }

                    }
                }
            }
            // END USER LIST

        }
    }


    RowLayout {
        id:exitEditorButtons
        anchors.left: userPaneRoot.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        height: 50
        spacing: 10
        Button {
            Layout.fillWidth: true
            Material.background: Material.color(Material.Indigo,Material.Shade300)
            onClicked: QBClient.closeEditor()

            Text {
                anchors.centerIn: parent
                text: qsTr("Return to Dashboard")
                color: "white"
            }
        }
        Button {
            Layout.fillWidth: true
            Material.background: "#c90000"
            onClicked: deleteTestPopup.open()
            Text {
                anchors.centerIn: parent
                text: qsTr("Delete Test")
                color: "white"
            }
        }
    }

    UserPane {
        id:userPaneRoot
    }

    Popup {
        id: deleteTestPopup
        modal: true
        focus: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        height: parent.height/3
        width: parent.width/2
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        Material.background: Material.color(Material.Grey, Material.Shade100)
        Text {
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Are you sure you want to delete this shared test? \n This cannot be undone.")
        } Item { anchors.fill: parent; Button {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            Material.background: Material.Red
            onClicked: QBClient.updateSharedTest("RemoveSharedTest",QBClient.sharedTest.SharedTestID)
            text: "Yes, DELETE this shared test"
        }}

        onOpened: modal = true
        onClosed: modal = false
    }

}

