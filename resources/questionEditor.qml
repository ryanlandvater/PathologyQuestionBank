//
//  questionEditor.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/8/20.
//  Copyright © 2020 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3

import "./components/"

Item {
    id: questionEditorRoot
    anchors.fill: parent

    ScrollView {
        id:editorScrollView
        property ScrollBar vScrollBar: ScrollBar.vertical
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        anchors.top: parent.top
        anchors.bottom: exitEditorButtons.top
        anchors.left: userPaneRoot.right
        anchors.leftMargin: 10
        anchors.right: questionEditorRoot.right
        anchors.rightMargin: 10
        clip: true
        focus: true
        onContentHeightChanged: {
//            if (answerList.count || explainationField.text.length)
//                vScrollBar.setPosition(1 - vScrollBar.size)
        }
        /*onContentWidthChanged: {
            contentWidth = questionEditorRoot.width - userPaneRoot.width
        }*/


        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 25
            Layout.alignment: Qt.AlignHCenter

            // QUESTION TITLE
            Text {
                id: questionEditorTitle
                width: editorScrollView.width
                wrapMode: "WordWrap"

                text: qsTr("<b>Question Editor</b> for Question: ") +
                      (questionNameField.length ?
                           "<i><b>"+"\"" + questionNameField.text + "\" </b></i>" :
                           "<i>" + QBClient.question.QuestionID +"</i>")


                color: "#3f5b68"
                minimumPixelSize: 5
                font.pixelSize: Math.floor(25* QBClient.screenDPI)
                horizontalAlignment: Text.AlignHCenter
//                fontSizeMode: Text.Fit

            }
            // END QUESTION TITLE

            // QUESTION NAME
            TextField {
                id: questionNameField
                width: editorScrollView.width
                wrapMode: "WordWrap"
                selectByMouse: true
                onEditingFinished: QBClient.updateQuestion("QuestionName",text);

                text: QBClient.question.QuestionName ? QBClient.question.QuestionName : ""
                placeholderText: qsTr("Optional. This is for you or your collaborators, hoping to easily find this question.")
                Text {
                    id: questionNameFieldTitle
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    color: parent.text.length || parent.activeFocus ? "navy" : "dark grey"

                    text: qsTr("Question Name")
                }
            }
            // END QUESTION NAME

            // CLINICAL HISTORY FIELD
            TextField {
                id: clinicalHistoryField
                width: editorScrollView.width

                wrapMode: "WordWrap" // for TextArea...
                selectByMouse: true
                activeFocusOnTab: true
                onEditingFinished: {
                    QBClient.updateQuestion("ClinicalHistory",text);
                }

                text: QBClient.question.ClinicalHistory ? QBClient.question.ClinicalHistory : ""
                placeholderText: qsTr("Optional. If you would like to include relevant clinical history.")

                Text {
                   id: clinicalHistoryFieldTitle
                   anchors.top: parent.bottom
                   anchors.left: parent.left
                   color: parent.text.length || parent.activeFocus ? "navy" : "dark grey"

                   text: qsTr("Relevant Clinical History")
               }
            }
            //END CLINICAL HISTORY FIELD

            // QUESTION TEXT FIELD
            TextField {
                id: questionField
                width: editorScrollView.width

                wrapMode: "WordWrap"
                selectByMouse: true
                font.bold:true
                activeFocusOnTab: true
                onEditingFinished: QBClient.updateQuestion("QuestionText",text);

                text: QBClient.question.QuestionText ? QBClient.question.QuestionText : ""
                placeholderText: qsTr("This is where the question goes (REQUIRED)")

                Text {
                   id: questionFieldTitle
                   anchors.top: parent.bottom
                   anchors.left: parent.left
                   color: parent.text.length || parent.activeFocus ? "navy" : "dark grey"

                   text: qsTr("Question Text")
               }
            }
            //END QUESTION TEXT FIELD

            FlickableImageView {
                id: imagesListView
                width: editorScrollView.width
                deleteButton: true
                footer: Item {
                    height: parent.height
                    width: parent.height
                    visible: Qt.platform.os !== "ios"
                    Button {
                        id: testUploadImageButton
                        anchors.fill: parent
                        anchors.margins: 20
                        Material.background: Material.color(Material.Grey,Material.Shade100)
                        Text {
                            anchors.centerIn: parent
                            font.italic: true
                            text: qsTr("Click to Upload a Photo")
                        }
                        onClicked: {
                            if (Qt.platform.os === "ios") {
                                fileDialog.open()
                                fileDialog.setFolder(shortcuts.pictures)
                            } else {
                                fileDragPopup.open()
                            }
                        }
                    }
                }
            }

            // BEGIN Choice List
            Column {
                width: editorScrollView.width
                spacing: 10

                Repeater {
                    id: answerList
                    model: QBClient.choices

                    delegate: Pane {
                        id: choicePane
                        property string _CID: model.modelData.ChoiceID
                        width: editorScrollView.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: choiceEditorColumn.height * 1.5
                        Layout.alignment: Qt.AlignHCenter
                        Material.background: Material.color(
                                                 _CID === QBClient.question.CorrectAnswerIndex ?
                                                 Material.Green:Material.Grey,Material.Shade100)
                        Component.onCompleted: {
                            editorScrollView.vScrollBar.setPosition(1 - editorScrollView.vScrollBar.size)
                        }

                        Material.elevation: 2
                        Image {
                            id: correctSelector
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 60
                            fillMode: Image.PreserveAspectFit
                            antialiasing: true
                            sourceSize.width: width
                            source:  correctSelectorMouseArea.containsMouse ||
                                     _CID === QBClient.question.CorrectAnswerIndex ?
                                         "../assets/green_check.svg" : "../assets/grey_check.svg"
                            opacity: correctSelectorMouseArea.containsMouse ||
                                     _CID === QBClient.question.CorrectAnswerIndex ?
                                         1:0.6
                            MouseArea {
                                id: correctSelectorMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    forceActiveFocus()
                                    QBClient.assignAnswer(_CID)
                                }
                            }
                        }
                        Rectangle {
                            id: deleteChoiceImage
                            color: deleteChoiceSelectorMouseArea.containsMouse ?
                                                "#F44336" : "#DBDBDB"
                            width: 80
                            height: 20
                            anchors.right: parent.right
//                            anchors.rightMargin: -choicePane.rightPadding
                            anchors.top: parent.top
                            anchors.topMargin: -choicePane.topPadding
                            Rectangle {
                                id: rad
                                color: parent.color
                                width: parent.width
                                radius: 5
                                height: radius * 2
                                anchors.verticalCenter: parent.bottom
                            } Text {
                                id: removeText
                                text: qsTr("Remove")
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.bottom: rad.bottom
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: deleteChoiceSelectorMouseArea.containsMouse ?
                                                    "black" : "dark grey"
                            } MouseArea {
                                id: deleteChoiceSelectorMouseArea
                                anchors.top: parent.top
                                anchors.bottom: rad.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                hoverEnabled: true
                                onClicked: QBClient.removeChoice(_CID)
                            }
                        }


                        Column {
                            id: choiceEditorColumn
                            anchors.top: parent.top
                            anchors.left: correctSelector.right
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.margins: 10
                            spacing: 10
                            TextField {
                                id: choiceText
                                width: parent.width

                                wrapMode: "WordWrap" // for TextArea...
                                selectByMouse: true
                                activeFocusOnTab: true
                                font.bold: true
                                onEditingFinished: QBClient.updateChoice(_CID, "ChoiceText",text);
                                text: model.modelData.ChoiceText ? model.modelData.ChoiceText : ""

                                placeholderText: qsTr("Choice Text Goes Here...")
                                Text {
                                   id: choiceTextTitle
                                   anchors.top: parent.bottom
                                   anchors.left: parent.left
                                   color: parent.text.length || parent.activeFocus ? "navy" : "dark grey"

                                   text: qsTr("Answer Text")
                               }
                            }

                            TextField {
                                id: choiceExplainationText
                                width: parent.width

                                wrapMode: "WordWrap" // for TextArea...
                                selectByMouse: true
                                activeFocusOnTab: true
                                font.italic: true
                                onEditingFinished: QBClient.updateChoice(_CID, "ChoiceExplanation",text);
                                text: model.modelData.ChoiceExplanation ? model.modelData.ChoiceExplanation : ""

                                placeholderText: qsTr("Optional. Choice Explanation (for example, why it is incorrect) goes here...")
                                Text {
                                   id: choiceExplainationTextTitle
                                   anchors.top: parent.bottom
                                   anchors.left: parent.left
                                   color: parent.text.length || parent.activeFocus ? "navy" : "dark grey"

                                   text: qsTr("Answer Explanation (hidden during test)")
                               }
                            }
                        }

                    }
                }

                Item { width: parent.width; height: childrenRect.height; Button {
                        width: parent.width-20
                        height: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        Material.background: Material.color(Material.Grey,Material.Shade100)
                        Layout.alignment: Qt.AlignVCenter
                        Text {
                            anchors.centerIn: parent
                            font.italic: true
                            text: qsTr("+ Click to Add a New Answer Choice")
                        }
                        onClicked: QBClient.addAnswerChoice();
                }}

            }

            //TODO: add TextEdit type here...
            TextArea {
                id: explainationField
                width: editorScrollView.width

                wrapMode: "WordWrap" // for TextArea...
                selectByMouse: true
                activeFocusOnTab: true
                onEditingFinished: {
                    explanationTimer.stop();
                    QBClient.updateQuestion("ExpainationText",text);
                } onFocusChanged: if (activeFocus) explanationTimer.restart();

                text: QBClient.question.ExpainationText ? QBClient.question.ExpainationText : ""
                placeholderText: qsTr("General explanation on the topic. Avoid directly giving the answer here as it appears each time.")

                Text {
                   id: explainationFieldTitle
                   anchors.top: parent.bottom
                   anchors.left: parent.left
                   color: parent.text.length || parent.activeFocus ? "navy" : "dark grey"

                   text: qsTr("Explanation Text")
               }
                Timer {id: explanationTimer; interval: 30000; repeat: true;
                    onTriggered: QBClient.updateQuestion("ExpainationText",parent.text)
                }
            } Rectangle {
                height: 1
                width: editorScrollView.width
                opacity: 0
            }

            Item{ width:editorScrollView.width; height: childrenRect.height;  Button {
                id: addTagsButton
                width: editorScrollView.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                height: 70
                Text {
                    id: addTagsText
                    anchors.centerIn: parent
                    text: qsTr("Tag Question With Topics")
                    font.bold: true
                    color: "white"
                }
                Material.background: Material.color(Material.Indigo, Material.Shade300)
                onClicked: addTagsPopup.open()
            }} Rectangle {
                // Simply a buffer
                height: 10
                width: editorScrollView.width
                opacity: 0
            }
        }



    }
    // END THE SCROLL VIEW CONTAINING USABLE ITEMS

    function missing() {
        var response = "Cannot";
        return response;
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
            Material.background: Material.Green
            enabled: QBClient.publishable && QBClient.question.TestTopics.length > 0
            onClicked: publishQuestionPopup.open()
            Text {
                anchors.centerIn: parent
                text: qsTr("Publish Question")
                color: "white"
                font.bold: true
            }
        }
        Button {
            Layout.fillWidth: true
            Material.background: Material.color(Material.Indigo,Material.Shade300)
            onClicked: QBClient.closeEditor()
            Text {
                anchors.centerIn: parent
                text: qsTr("Save for later")
                color: "white"
            }
        }
        Button {
            Layout.fillWidth: true
            Material.background: "#c90000"
            onClicked: deleteQuestionPopup.open()
            Text {
                anchors.centerIn: parent
                text: qsTr("Delete Question")
                color: "white"
            }
        }
    }

    // Additional components (popups and the like)
    AddTagsPopup {
        id: addTagsPopup
    }

    UserPane {
        id:userPaneRoot
    }

    FileDragPopup {
        id: fileDragPopup
    }

    DeleteQuestionPopup {
        id: deleteQuestionPopup
    }

    Popup {
        id: publishQuestionPopup
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
            text: qsTr("Are you sure you are ready to publish? \n This question will go live immediately.")
        } Item { anchors.fill: parent; Button {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            Material.background: Material.Green
            onClicked: QBClient.publishQuestion(QBClient.question.QuestionID)
            text: "Yes, PUBLISH this question"
        }}

        onOpened: modal = true
        onClosed: modal = false
    }
}

