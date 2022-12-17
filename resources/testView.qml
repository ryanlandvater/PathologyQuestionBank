//
//  testView.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 9/5/20.
//  Copyright © 2020 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import QtGraphicalEffects 1.15
import "./components"

Item {
    id: testRoot
    property int numQuestions: QBClient.test.Questions.length
    anchors.fill: parent


    // START SWIPE VIEW
    SwipeView {
        id:questionSwipeView
        anchors.top: testControlBar.bottom
        anchors.bottom: bottomControlBar.top
        anchors.left: testRoot.left
        anchors.right: testRoot.right
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        currentIndex: 0
        interactive: Qt.platform.os === "ios"
        orientation: Qt.Horizontal
        onCurrentIndexChanged: QBClient.questionAt(questionSwipeView.currentIndex)

        Repeater {
            model: QBClient.test.Questions
            Loader {
                id: qbankPane
                active: SwipeView.isCurrentItem
                source: QBClient.question? "./components/QuestionView.qml"
                                         : "./components/Loading.qml"
            }
        }



    } Rectangle {
        id: scrollFadeBar
        height: 50
        anchors.top: testControlBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        gradient: Gradient{
            GradientStop{position: 0; color: Material.backgroundColor}
            GradientStop{position: 1; color: "transparent"}
        }
    }
    // END SWIPE VIEW


    Pane {
        id:testControlBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        anchors.top: parent.top
        anchors.topMargin: 10
        height: 60

        Material.background: Material.BlueGrey
        Material.elevation: 5
        Image {
            id: previousQuestionButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            visible: questionSwipeView.currentIndex > 0

            sourceSize.height: height
            source: "../assets/previous_question.svg"
            fillMode: Image.PreserveAspectFit
            height: 40

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if (containsMouse) parent.source = "../assets/previous_question_hovered.svg"
                    else parent.source= "../assets/previous_question.svg"
                }
                onPressed: parent.source  = "../assets/previous_question_pressed.svg"
                onReleased: parent.source = "../assets/previous_question.svg"
                onClicked: {
                    questionSwipeView.setCurrentIndex(questionSwipeView.currentIndex-1)
                }
            }
        }
        Button {
            property bool open: false
            anchors.centerIn: parent
            width:itemNumber.contentWidth * 1.2
            height: itemNumber.contentHeight * 2.5
            Material.background: Material.BlueGrey
            Text {
                id: itemNumber
                anchors.centerIn: parent
                text: qsTr("Question <b>") + (questionSwipeView.currentIndex + 1)
                      + qsTr("</b> of ") + numQuestions
                color: "white"
                font.pixelSize: Math.floor(18*QBClient.screenDPI)
            }
            onClicked: {
                if (open) {
                    questionList.close();
                    open = false;
                } else {
                    questionList.open();
                    open = true;
                }
            }
            Popup {
                id: questionList
                modal: false
                width: parent.width
                height: Overlay.overlay.height/4
                y: parent.y + parent.height + 10
                onClosed: {
                    parent.open = false;
                }
                Material.background: Material.background
                bottomPadding: 0
                topPadding: 0
                ListView {
                    id: questionListView
                    property var lock: QBClient.locked
                    model: QBClient.test.Questions
                    width: parent.width
                    height: parent.height
                    spacing: 5
                    clip: true
                    header: Rectangle{height: 10}
                    delegate: Item {
                        property bool locked: model.modelData.ChoiceSubmitted === "true"
                        property bool marked: model.modelData.Marked === "true"
                        property var lockBinding: QBClient.locked
                        property var markedBinding: QBClient.marked
                        onLockBindingChanged: {
                            var model_ = QBClient.test.Questions
                            locked = model_[index].ChoiceSubmitted === "true"
                        }
                        onMarkedBindingChanged: {
                            var model_ = QBClient.test.Questions
                            marked = model_[index].Marked === "true"
                        }

                        height: 30
                        width: questionListView.width
                        Image {
                            id: name
                            height: 20
                            visible: locked
                            source: "./assets/lock.svg"
                            sourceSize.height: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            width: parent.width
                            height: parent.height
                            text: qsTr("Question " + (index+1))
                            color: locked?"dark grey" : "black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Image {
                            id: markedSmall
                            height: 20
                            visible: marked
                            source: "./assets/marked_light.svg"
                            sourceSize.height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.8
                            height: 1
                            color: "light grey"
                        } MouseArea {
                            anchors.fill: parent
                            onClicked: questionSwipeView.setCurrentIndex(index)
                        }
                    }
                    footer: Rectangle{height:10}
                }
            }
        }
        Image {
            id: nextQuestionButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            visible: questionSwipeView.currentIndex < QBClient.test.Questions.length - 1

            sourceSize.height: height
            source: "../assets/next_question.svg"
            fillMode: Image.PreserveAspectFit
            height: 40

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if (containsMouse) parent.source = "../assets/next_question_hovered.svg"
                    else parent.source = "../assets/next_question.svg"
                }
                onPressed: parent.source = "../assets/next_question_pressed.svg"
                onReleased: parent.source = "../assets/next_question.svg"
                onClicked: {
//                    QBClient.questionAt(questionSwipeView.currentIndex+1)
                    questionSwipeView.setCurrentIndex(questionSwipeView.currentIndex+1)
                }
            }
        }
    }

//    Pane {
//        id: sideControlBar
//        anchors.top: parent.top
//        anchors.bottom: bottomControlBar.top
//    }

    Rectangle {
        id: bottomControlBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Material.color(Material.BlueGrey)

        Text {
            id: testID
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "<b>TestID:</b> <i>" + QBClient.test.TestID + "</i>"
            color: "#E6E7E8"

        }
        RowLayout {
            id: marked
            property bool flagged: QBClient.question.Marked ? QBClient.question.Marked : false;
            anchors.left: testID.right
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            Image {
                id: markedIcon
                source: parent.flagged ?  "../assets/marked.svg" : "../assets/unmarked_grey.svg"
                sourceSize.height: height
                height: 20
            }
            Text {
                id: markedText
                text: parent.flagged ? qsTr("Marked") : qsTr("Unmarked")
                font.bold: true
                color: parent.flagged ? "#C1272D" : "light grey"
            }
        } MouseArea {
            anchors.fill: marked
            hoverEnabled: true
            ToolTip.visible: containsMouse
            ToolTip.text: (marked.flagged ? "Unmark" : "Mark") +" this question."
            onClicked: QBClient.toggleMarked(questionSwipeView.currentIndex)
        } DropShadow {
            anchors.fill: marked
            radius: 8.0
            samples: 14
            visible: marked.flagged
            color: "#80000000"
            source: marked
        }

        Image {
            id: pauseTest
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: submitTestButton.left
            anchors.rightMargin: 10
            fillMode: Image.PreserveAspectFit
            antialiasing: false
            sourceSize.height: height
            source: "../assets/pause_test.svg"

            MouseArea {
                id:pauseTestButton
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if (containsMouse)
                        parent.source  = "../assets/pause_test_hover.svg"
                    else parent.source = "../assets/pause_test.svg"
                }
                onPressed: parent.source  = "../assets/pause_test_pressed.svg"
                onReleased: parent.source = "../assets/pause_test.svg"

                onClicked: QBClient.pauseTest()
            }
        } DropShadow {
            anchors.fill: pauseTest
            radius: 8.0
            samples: 14
            color: "#80000000"
            source: pauseTest
        }

        Image {
            id: submitTestButton
            height: 50
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            fillMode: Image.PreserveAspectFit
            antialiasing: false
            sourceSize.height: height
            source: "../assets/submitTest.svg"

            MouseArea {
                id:submitTestMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if (containsMouse) parent.source = "../assets/submitTest_hover.svg"
                    else parent.source = "../assets/submitTest.svg"
                }
                onPressed: parent.source  = "../assets/submitTest_pressed.svg"
                onReleased: parent.source = "../assets/submitTest.svg"
                onClicked: QBClient.submitTest()
            }
        } DropShadow {
            anchors.fill: submitTestButton
            radius: 8.0
            samples: 14
            color: "#80000000"
            source: submitTestButton
        }
    }
    Popup {
        id: submitTestPopup

    }
}
