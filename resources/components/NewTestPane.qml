//
//  DashbordPane.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/7/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import QtQml.Models 2.15

Pane {
    id: qbankPaneRoot

    ScrollView {
        id: qbankScrollView
        anchors.top: parent.top
        anchors.bottom:generateTestButtons.top
        anchors.left: parent.left
        anchors.right: parent.right
//        anchors.margins: 10
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

//        background: Rectangle {
//            anchors.fill: parent
//            radius: 5
//            opacity: 0.8
//            color: "#f7f8f9"
//            border.color: "light grey"
//            border.width: 3
//        }

        Column {
            width: parent.width * 0.9
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            // TITLE
            Text {
                id: generateTestTitle
                text: qsTr("Create a New Test")
                font.bold:true
                font.pixelSize: Math.floor(30 * QBClient.screenDPI)
                width: parent.width
                color: "#3f5b68"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // STATUS FLAG ROW
            Text {
                id: stateTitle
                text: qsTr("Question Status")
                color: "#3f5b68"
                font.italic: true
                font.pixelSize: Math.floor (20 * QBClient.screenDPI)
            } RowLayout {
                Layout.fillWidth: true
                ButtonGroup {
                    id: statusButtonGroup
                    exclusive: true
                } ListModel {
                    id: statusFlagModel
                   ListElement {flag: "Unused"}
                   ListElement {flag: "Incorrect"}
                   ListElement {flag: "Marked"}
                   ListElement {flag: "All"}
                } Repeater {
                    model: statusFlagModel
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        CheckBox{
                            id: statusCheckbox
                            ButtonGroup.group: statusButtonGroup
                        } Text {
                            text: qsTr(modelData)
                            color: statusCheckbox.hovered || statusCheckbox.checked
                                   ? "#00274C" : "#5c5c5c"
                        }
                    }
                }
            } // END STATUS FLAG ROW

            // AP QUESTION GRID
            RowLayout {
                Layout.fillWidth: true
                CheckBox{
                    id: apALLCheckbox
                    tristate: true
                    checkState: apTopicsButtonGroup.checkState
                    nextCheckState: function () {
                        switch (checkState) {
                        case Qt.Checked:
                        case Qt.PartiallyChecked:
                            return Qt.Unchecked;
                        case Qt.Unchecked:
                            return Qt.Checked;
                        }
                    }
                } Text {
                    text: qsTr("Anatomic Pathology Topics:")
                    color: apALLCheckbox.hovered || apTopicsButtonGroup.checkState !== Qt.Unchecked
                           ? "#00274C" : "#5c5c5c"
                    font.italic: true
                    font.pixelSize: Math.floor(20 * QBClient.screenDPI)
                }
                ButtonGroup {
                    id: apTopicsButtonGroup
                    exclusive: false
                    checkState: apALLCheckbox.checkState
                }
            } GridLayout {
                width: parent.width * 0.9
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 3
                columnSpacing: 5
                rowSpacing: 5
                Repeater {
                    model: QBClient.settings.TopicsList.AnatomicPathology
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        CheckBox{
                            id: apCheckbox
                            ButtonGroup.group: apTopicsButtonGroup
                        } Text {
                            text: qsTr(modelData)
                            color: apCheckbox.hovered || apCheckbox.checked
                                   ? "#00274C" : "#5c5c5c"
                        }
                    }
                }
            } // END AP QUESTION GRID

            // CP QUESTION GRID
            RowLayout {
                Layout.fillWidth: true
                CheckBox{
                    id: cpALLCheckbox
                    checkState: cpTopicsButtonGroup.checkState
                    tristate: true
                    nextCheckState: function () {
                        switch (checkState) {
                        case Qt.Checked:
                        case Qt.PartiallyChecked:
                            return Qt.Unchecked;
                        case Qt.Unchecked:
                            return Qt.Checked;
                        }
                    }
                } Text {
                    text: qsTr("Clinical Pathology Topics:")
                    color: cpALLCheckbox.hovered || cpTopicsButtonGroup.checkState !== Qt.Unchecked
                           ? "#00274C" : "#5c5c5c"
                    font.italic: true
                    font.pixelSize: Math.floor(20 * QBClient.screenDPI)
                }
                ButtonGroup {
                    id: cpTopicsButtonGroup
                    exclusive: false
                    checkState: cpALLCheckbox.checkState
                }
            } GridLayout {
                width: parent.width * 0.9
                columns: 3
                anchors.horizontalCenter: parent.horizontalCenter
                columnSpacing: 5
                rowSpacing: 5
                Repeater {
                    model: QBClient.settings.TopicsList.ClinicalPathology
                    delegate: RowLayout {
                        CheckBox{
                            id: cpCheckbox
                            checked: QBClient.containsTags(modelData)
                            onCheckedChanged: QBClient.assignTag("TestTopics",modelData,!checked)
                            ButtonGroup.group: cpTopicsButtonGroup
                        } Text {
                            text: qsTr(modelData)
                            color: cpCheckbox.hovered || cpCheckbox.checked
                                   ? "#00274C" : "#5c5c5c"
//                            font.bold: cpCheckbox.hovered || cpCheckbox.checked
                        }
                    }
                }
            } // END CP QUESTION GRID

            // NUMBER OF QUESTIONS ROW
            RowLayout {
                Text {
                    text: qsTr("Number of Questions: ")
                    color: "#00274C"
                    font.italic: true
                    font.pixelSize: Math.floor(20* QBClient.screenDPI)
                }
                SpinBox {
                    id: numQuestions
                    Layout.fillWidth: true
                    from: 0
                    value: 40
                    to: 40
                    editable: true
                    font.pixelSize: Math.floor(20* QBClient.screenDPI)
                    inputMethodHints: Qt.ImhDigitsOnly
                    stepSize: 5
                } Text {
                    text: qsTr("J-Mode: ")
                    color: "#00274C"
                    font.italic: true
                    font.pixelSize: Math.floor(20* QBClient.screenDPI)
                    MouseArea{id:jmodeTitle; anchors.fill: parent; hoverEnabled: true}
                    ToolTip.visible: jmodeTitle.containsMouse
                    ToolTip.text: "J-Mode (Justin and Julianne Mode): This will show the correct answer and"+
                                  " all explainations regardless of how you answered the question."
                } Switch {
                    id: jmodeSwitch
                }
            }// END NUMBER OF QUESTIONS ROW

        }
    }
    // BOTTOM BUTTONS
    RowLayout {
        id:generateTestButtons
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        anchors.bottom: parent.bottom
        spacing: 10

        Button {
            Layout.fillWidth: true
            Material.background: "#00274C"
            enabled: numQuestions.value > 0 &&
                     statusButtonGroup.checkState === Qt.PartiallyChecked &&
                     (apTopicsButtonGroup.checkState !== Qt.Unchecked ||
                      cpTopicsButtonGroup.checkState !== Qt.Unchecked)
            Text {
                anchors.centerIn: parent
                text: qsTr("Start Test")
                color: "white"
                font.bold: true
            }

            onClicked: {
                var status;
                var tags = [];
                var numQs = numQuestions.value;

                var statusButtons = statusButtonGroup.buttons;
                var APButtons = apTopicsButtonGroup.buttons;
                var APText = QBClient.settings.TopicsList.AnatomicPathology
                var CPButtons = cpTopicsButtonGroup.buttons;
                var CPText = QBClient.settings.TopicsList.ClinicalPathology;

                var jmode = jmodeSwitch.position > 0.5 ? true : false;

                var i = 0;
                for ( i = 0; i < statusButtons.length; i ++)
                    if (statusButtons[i].checked) {
                        status = statusFlagModel.get(i).flag
                        break;
                    }
                for ( i = 0; i < APButtons.length; i++) {
                    if (APButtons[i].checked) {
                        tags.push(APText[i]);
                    }
                } for ( i = 0; i < CPButtons.length; i++) {
                    if (CPButtons[i].checked)
                        tags.push(CPText[i]);
                } QBClient.generateTest(status, tags, numQuestions.value, jmode)
            }
        }
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
