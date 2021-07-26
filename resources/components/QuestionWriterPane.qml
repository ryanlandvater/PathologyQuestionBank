//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4

Pane {
    id: writeQuestionPane
    anchors.fill:parent

    function time (x) {
        var date = new Date(parseInt(x)).toLocaleDateString("en-US");
        return date;
    }

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: cancelWriteQuestionButton.top

        spacing: 10

        Button {
            id: createQButton
            width: parent.width
            enabled: QBClient.user.UserAuthorRole
            onClicked: QBClient.createQuestion()
            Material.background:"#0d7d12"
            topInset: 5
            bottomInset: 5
            Text {
                anchors.centerIn: parent
                text: "Begin Writing a New Question"
                font.capitalization: Font.SmallCaps
                font.pixelSize: Math.floor(20 * QBClient.screenDPI)
                color: "white"
                font.bold: true
            }
        }
        Button {
            id: createSTButton
            width: parent.width
            enabled: QBClient.user.UserAuthorRole
            onClicked: QBClient.createSharedTest()
            Material.background: "#0b3b7a"
            topInset: 5
            bottomInset: 5
            Text {
                anchors.centerIn: parent
                text: "Begin Deploying a Shared Test"
                font.capitalization: Font.SmallCaps
                font.pixelSize: Math.floor(20 * QBClient.screenDPI)
                color: "white"
                font.bold: true
            }
        }

        QBGenericList {
            id: incomplete
            width: parent.width
            heightMax: (parent.height-100)/3
            mainColor: "#c90000"
            bkgrndColor: "#fad2d2"
            model: QBClient.incomplete
            headerText: "Incomplete Unpublished Questions"
            list.delegate:incompleteDelegate
        }
        Component {
            id: incompleteDelegate
            Rectangle {
                id: buttonBackground
                property string mainAccent: incomplete.mainColor
                property int currentIndex: incomplete.list.currentIndex
                property string textColor: index === currentIndex ? mainAccent : "grey"
                height: incomplete.buttonHeight
                width: parent.width
                radius: index === currentIndex ? 5 : 0
                color:  "transparent"
                Text {
                    id: buttonLeftText
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: buttonRightText.left
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10


                    text: qsTr(model.modelData.QuestionName ?
                        "Question Name: <b>" + model.modelData.QuestionName +"</b>" :
                        "Question ID: <i>" + model.modelData.QuestionID+"</i>")

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: "WordWrap"
                    color: parent.textColor
                } Text {
                    id: buttonRightText
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 10

                    text: qsTr("last updated " + time (model.modelData.Updated))

                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: parent.textColor
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.9
                    height: 1
                    color: index === currentIndex?
                               parent.mainAccent : "light grey"
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if (containsMouse)
                            incomplete.list.currentIndex = index
                    } onClicked: QBClient.editQuestion(model.modelData.QuestionID)
                }
            }
        }
        // END INCOMPLETE LIST

        // START PUBLISHED LIST
        QBGenericList {
            id: published
            width: parent.width
            heightMax: (parent.height-100)/3
            model: QBClient.published
            mainColor: "#0d7d12"
            bkgrndColor: "#badebc"
            headerText: "Published Questions"
            list.delegate:publishedListDelegate
        }
        Component {
            id: publishedListDelegate
            Rectangle {
                id: buttonBackground
                property string mainAccent: published.mainColor
                property int currentIndex: published.list.currentIndex
                property string textColor: index === currentIndex ? mainAccent : "grey"
                height: published.buttonHeight
                width: parent.width
                radius: index === currentIndex ? 5 : 0
                color:  "transparent"
                Text {
                    id: buttonLeftText
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: buttonRightText.left
                    anchors.rightMargin: 10

                    property var question: model.modelData

                    text: qsTr(model.modelData.QuestionName ?
                        "Question Name: <b>" + model.modelData.QuestionName +"</b>" :
                        "Question ID: <i>" + model.modelData.QuestionID+"</i>")
                          + " [" + model.modelData.Performance + "%]"

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: "WordWrap"
                    color: parent.textColor
                } Text {
                    id: buttonRightText
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 10

                    text: qsTr("last updated " + time (model.modelData.Updated))

                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: parent.textColor
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.9
                    height: 1
                    color: index === currentIndex?
                               parent.mainAccent : "light grey"
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if (containsMouse)
                            published.list.currentIndex = index
                    } onClicked: QBClient.analyzeQuestion(model.modelData.QuestionID)
                }
            }
        }
        // END PUBLISHED LIST

        // START SHARED TESTS
        QBGenericList {
            id: sharedTests
            width: parent.width
            heightMax: (parent.height-120)/3
            model: QBClient.sharedTests
            mainColor: "#0b3b7a"
            bkgrndColor: "#bacade"
            headerText: "Shared Tests"
            list.delegate:sharedTestsDelegate
        }
        Component {
            id: sharedTestsDelegate
            Rectangle {
                id: buttonBackground
                property string mainAccent: sharedTests.mainColor
                property int currentIndex: sharedTests.list.currentIndex
                property string textColor: index === currentIndex ? mainAccent : "grey"
                height: sharedTests.buttonHeight
                width: parent.width
                radius: index === currentIndex ? 5 : 0
                color:  "transparent"
                Text {
                    id: buttonLeftText
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: buttonRightText.left
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    property var question: model.modelData

                    text: qsTr(model.modelData.SharedTestName ?
                        "Shared Test Name: <b>" + model.modelData.SharedTestName +"</b>" :
                        "Shared Test ID: <i>" + model.modelData.SharedTestID+"</i>")
                          + " [" + model.modelData.Performance + "%]"

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: "WordWrap"
                    color: parent.textColor
                } Text {
                    id: buttonRightText
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 10

                    text: qsTr("last updated " + time (model.modelData.Updated))

                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    color: parent.textColor
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.9
                    height: 1
                    color: index === currentIndex?
                               parent.mainAccent : "light grey"
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if (containsMouse)
                            sharedTests.list.currentIndex = index
                    } onClicked: QBClient.editSharedTest(model.modelData.SharedTestID)
                }
            }
        }
        // END SHARED TESTS

    }


    RowLayout {
        id: cancelWriteQuestionButton
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        anchors.bottom: parent.bottom
        spacing: 10
        Button {
            Layout.fillWidth: true
            Material.background: "#c90000"
            onClicked: dashboardSwipe.setCurrentIndex(1)
            Text {
                anchors.centerIn: parent
                text: qsTr("Cancel")
                color: "white"
                font.bold:true
            }
        }
    }
}
