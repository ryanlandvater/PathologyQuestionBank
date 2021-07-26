//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Layouts 1.3

Popup {
    id: addTagsPopup
    onAboutToShow: addTagsLoader.active = true
    onAboutToHide: addTagsLoader.active = false
    parent: Overlay.overlay
    anchors.centerIn: parent
    height: parent.height/1.3
    width: parent.width/1.5
    modal: true
    Loader {
        id: addTagsLoader
        anchors.fill: parent
        sourceComponent:
            Column {
            width: addTagsLoader.width
            spacing: 10
            Text {
                id: addTagsTitle
                text: qsTr("Assign Topics to the Question")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Math.floor(25 * QBClient.screenDPI)
                font.bold:true
                color: "#00274C"
            }
            Text {
                id: apTags
                text: qsTr("Anatomic Pathology Topics:")
                font.italic: true
                font.pixelSize: Math.floor(20 * QBClient.screenDPI)
            }
            GridLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 3
                columnSpacing: 10
                Repeater {
                    model: QBClient.settings.TopicsList.AnatomicPathology
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        CheckBox{
                            id: apCheckbox
//                            property variant question: QBClient.question
                            checked: QBClient.containsTags(modelData)
                            onCheckedChanged: QBClient.assignTag("TestTopics",modelData,!checked)

                        } Text {
                            text: qsTr(modelData)
                            color: apCheckbox.hovered || apCheckbox.checked
                                   ? "#00274C" : "#5c5c5c"
                        }
                    }
                }
            }
            Text {
                id: cpTags
                text: qsTr("Clinical Pathology Topics:")
                font.italic: true
                font.pixelSize: Math.floor(20 * QBClient.screenDPI)
            }
            GridLayout {
                columns: 3
                anchors.horizontalCenter: parent.horizontalCenter
                Repeater {
                    model: QBClient.settings.TopicsList.ClinicalPathology
                    delegate: RowLayout {
                        CheckBox{
                            id: cpCheckbox
                            checked: QBClient.containsTags(modelData)
                            onCheckedChanged: QBClient.assignTag("TestTopics",modelData,!checked)
                        } Text {
                            text: qsTr(modelData)
                            color: cpCheckbox.hovered || cpCheckbox.checked
                                   ? "#00274C" : "#5c5c5c"
                        }
                    }
                }
            }

        }
    }
}
