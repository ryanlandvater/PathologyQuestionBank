import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtCharts 2.15

import "./components/"

Item {
    id: questionAnalysisRoot
    anchors.fill: parent
    function adjustBrightness (hex, percent) {
        if (percent === 0) return Material.backgroundColor
        hex = hex.replace(/^\s*#|\s*$/g, '');
        var r = parseInt (hex.substr(0,2), 16);
        var g = parseInt (hex.substr(2,2), 16);
        var b = parseInt (hex.substr(4,2), 16);
        return '#' +
                ((0|(1<<8) + r + (256 - r) * (1-percent)).toString(16)).substr(1) +
                ((0|(1<<8) + g + (256 - g) * (1-percent)).toString(16)).substr(1) +
                ((0|(1<<8) + b + (256 - b) * (1-percent)).toString(16)).substr(1);
    }

    ScrollView {
        id: analysisScrollView
        property ScrollBar vScrollBar: ScrollBar.vertical
        property int fontpixelSize: Math.floor(18 * QBClient.screenDPI)
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        anchors.top: parent.top
        anchors.bottom: exitEditorButtons.top
        anchors.left: userPaneRoot.right
        anchors.leftMargin: 10
        anchors.right: questionAnalysisRoot.right
        anchors.rightMargin: 10
        clip: true
        focus: true


        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 25
            Layout.alignment: Qt.AlignHCenter

            // QUESTION TITLE
            Text {
                id: questionEditorTitle
                width: analysisScrollView.width
                wrapMode: "WordWrap"

                text: qsTr("<b>Question Analysis</b> for Question: ") +
                      (questionNameLoader.item.text.length ?
                           "<i><b>"+"\"" + questionNameLoader.item.text + "\" </b></i>" :
                           "<i>" + QBClient.question.QuestionID +"</i>")


                color: "#3f5b68"
                minimumPixelSize: 5
                font.pixelSize: Math.floor(25* QBClient.screenDPI)
                horizontalAlignment: Text.AlignHCenter

            }
            // END QUESTION TITLE

            // QUESTION TEXT FIELD
            Loader {
                id: questionLoader
                sourceComponent: questionTextComponent
            } Component {
                id: questionTextComponent
                Text {
                    id: questionText
                    width: analysisScrollView.width - analysisScrollView.vScrollBar.width

                    wrapMode: "WordWrap"
                    font.bold:true
                    font.pixelSize: analysisScrollView.fontpixelSize

                    text: QBClient.question.QuestionText ? QBClient.question.QuestionText : ""

                    Text {
                        id: questionFieldTitle
                        anchors.bottom: parent.top
                        anchors.left: parent.left
                        color: "navy"

                        text: qsTr("Question Text")
                    }
                }
            } Component {
                id: questionFieldComponent
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
                        color: "navy"

                        text: qsTr("Question Text")
                    }
                }
            }
            //END QUESTION TEXT FIELD

            // ANSWER BREAKDOWN CHART
            Row {
                id: breakdownRow
                width: analysisScrollView.width - analysisScrollView.vScrollBar.width
                height: answerListColumn.height < analysisScrollView.width / 2 ?
                            analysisScrollView.width / 2 : answerListColumn.height
                ChartView {
                    id: breakdownChart
//                    title: "First-time Respondants' Answers"
//                    titleColor: "dark grey"
                    width: parent.width /2
                    height: parent.height
                    Layout.alignment: Qt.AlignCenter
                    antialiasing: true
                    backgroundColor: "transparent"
                    plotAreaColor: "transparent"
                    legend.visible: false
                    margins.bottom: 0
                    margins.top: 0
                    margins.left: 10
                    margins.right: 10

                    PieSeries {
                        id: performancePie

                        holeSize: 0.5
                        startAngle: 45; endAngle: 45
                        size: 0.9
                        Component.onCompleted: {
                            performancePie.clear()
                            var choices = QBClient.choices;
                            for (var index in choices) {
                                if (choices[index].Performance) {
                                    var _CID = choices[index].ChoiceID
                                    var slice = performancePie.append(_CID, choices[index].Performance)
                                    if (_CID === QBClient.question.CorrectAnswerIndex) {
                                        slice.color = adjustBrightness("#4CAF50",slice.value)
                                    } else {
                                        slice.color = adjustBrightness("#B01717",slice.value);
                                    }
                                    slice.borderColor = "black"
                                    slice.label
                                }
                            } if (performancePie.count < 1) {
                                noResponsesYet.visible = true
                                percetCorrectTitle.visible = false
                                breakdownRow.height = answerListColumn.height
                            }
                            loadAnimation.start()
                            correctTitleAnimation.start()
                        }
                        NumberAnimation on endAngle {
                            id: loadAnimation
                            to: 405
                            duration: 1000
                            easing.type: Easing.OutCubic
                        }
                    } Text {
                        id: percetCorrectTitle
                        property int correct
                        anchors.horizontalCenter: breakdownChart.horizontalCenter
                        anchors.verticalCenter: breakdownChart.verticalCenter
//                            anchors.verticalCenterOffset: contentHeight/4
                        text: qsTr("<b>"+correct+"%</b><br>Correct")
                        horizontalAlignment: Text.AlignHCenter
                        NumberAnimation on correct {
                            id: correctTitleAnimation
                            from: 0
                            to: {
                                var c = QBClient.choices
                                for (var i in c) {
                                    var _CID = c[i].ChoiceID
                                    if (_CID === QBClient.question.CorrectAnswerIndex)
                                        return Math.round(c[i].Performance*100)
                                }
                                return 0;

                            }
                            duration: 1000
                            easing.type: Easing.OutCubic
                        }
                    }
                    Text {
                        id: noResponsesYet
                        anchors.centerIn: breakdownChart
                        visible: false
                        color: "dark grey"
                        font.bold: true
                        text: qsTr("There are no responses yet to report")
                    }
                }
                Column {
                    id: answerListColumn
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width/2
                    height: childrenRect.height

                    spacing: 10

                    Repeater {
                        model: QBClient.choices
                        delegate:
                            Pane {
                                id: answerPane
                                property string _CID: model.modelData.ChoiceID
                                property bool correct: _CID === QBClient.question.CorrectAnswerIndex
                                property real perform: model.modelData.Performance
                                                       ? model.modelData.Performance : 0
                                property int elevation: answerPaneMouseArea.containsMouse ? 3 : 1

                                width: answerListColumn.width
                                contentHeight: choiceText.contentHeight + 10
                                bottomInset: 10

                                Material.background:correct ? adjustBrightness("#4CAF50", perform)
                                                            : adjustBrightness("#B01717", perform);
                                Material.elevation: elevation

                                Text {
                                    id: choiceText
                                    width: parent.width
                                    height: contentHeight
                                    anchors.verticalCenter: parent.verticalCenter

                                    wrapMode: "WordWrap" // for TextArea...✓
                                    font.bold: true
                                    font.pixelSize: analysisScrollView.fontpixelSize
                                    text: (_CID === QBClient.question.CorrectAnswerIndex ?
                                              "✓ ":"") + qsTr(model.modelData.ChoiceText
                                                               +" ["+(Math.round(answerPane.perform*100))+"%]")
                                }

                                MouseArea {
                                    id: answerPaneMouseArea
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    onHoveredChanged: {
                                        if (containsMouse) {
                                            var slice = performancePie.find(_CID)
                                            if (slice && slice.value < 1.0 && slice.value > 0.0)
                                                performancePie.find(_CID).exploded = true
                                        } else {
                                            if (performancePie.find(_CID))
                                                performancePie.find(_CID).exploded = false
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            // END ANSWER BREAKDOWN CHART

            // QUESTION NAME
            Loader {
                id: questionNameLoader
                sourceComponent: nameText //questionNameField
            }
            Component{
                id: nameText
                Text {
                    id: questionNameText
                    text: qsTr(QBClient.question.QuestionName ? QBClient.question.QuestionName
                                                              : QBClient.question.QuestionID)
                    font.pixelSize: analysisScrollView.fontpixelSize

                    Text {
                        id: questionNameTextTitle
                        anchors.top: parent.bottom
                        anchors.left: parent.left
                        color: "navy"

                        text: qsTr(QBClient.question.QuestionName ? "Question Name":"Question ID")
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        ToolTip.text: "Click to Edit Question Name"
                        ToolTip.visible: containsMouse
                        onClicked: questionNameLoader.sourceComponent = nameField
                    }
                }
            }
            Component {
                id: nameField
                Item {
                    width: analysisScrollView.width - analysisScrollView.vScrollBar.width
                    height: questionNameField.height
                TextField {
                    id: questionNameField
                    anchors.left: parent.left
                    width: parent.width - finishedButton.width * 1.2
                    wrapMode: "WordWrap"
                    selectByMouse: true
                    onEditingFinished: {
                        QBClient.updateQuestion("QuestionName",text);
                        questionNameLoader.sourceComponent = nameText
                    }

                    text: QBClient.question.QuestionName ? QBClient.question.QuestionName : ""
                    placeholderText: qsTr("Optional. This is for you or your collaborators, hoping to easily find this question.")
                    Text {
                        id: questionNameFieldTitle
                        anchors.top: parent.bottom
                        anchors.left: parent.left
                        color: "navy"

                        text: qsTr("Question Name")
                    }
                }
                    Button {
                        id: finishedButton
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        anchors.right: parent.right
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Finished")
                            color: "white"
                        }
                        Material.background: Material.color(Material.Indigo,Material.Shade300)
                        onClicked: questionNameLoader.sourceComponent = nameText
                    }

                }
            }
            // END QUESTION NAME

            // CLINICAL HISTORY FIELD
            Loader {
                id: clinicalHistoryLoader
                sourceComponent: clinicalHistoryTextComponent
            }
            Component {
                id: clinicalHistoryTextComponent
                Text {
                    id: clinicalHistoryText
                    width: analysisScrollView.width - analysisScrollView.vScrollBar.width

                    wrapMode: "WordWrap" // for TextArea...
                    visible: QBClient.question.ClinicalHistory ? true : false;
                    text: QBClient.question.ClinicalHistory ? QBClient.question.ClinicalHistory : ""
                    font.pixelSize: analysisScrollView.fontpixelSize

                    Text {
                        id: clinicalHistoryFieldTitle
                        visible: QBClient.question.ClinicalHistory ? true : false
                        anchors.top: parent.bottom
                        anchors.left: parent.left
                        color: "navy"

                        text: qsTr("Relevant Clinical History")
                    }
                }
            }
            Component {
                id: clinicalHistoryFieldComponent
                TextField {
                    id: clinicalHistoryField
                    width: analysisScrollView.width

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
                        color: "navy"

                        text: qsTr("Relevant Clinical History")
                    }
                }
            }
            //END CLINICAL HISTORY FIELD

            // ANSWER CHOICES
            Column {
                width: analysisScrollView.width
                spacing: 10

                Repeater {
                    id: answerList
                    model: QBClient.choices


                    delegate: Pane {
                        id: choicePane
                        property string _CID: model.modelData.ChoiceID
                        width: analysisScrollView.width - 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: choiceEditorColumn.height + 40 + choiceExplainationTextTitle.contentHeight // For the top buff
                        Layout.alignment: Qt.AlignHCenter
                        Material.background: Material.color(
                                                 _CID === QBClient.question.CorrectAnswerIndex ?
                                                 Material.Green:Material.Grey,Material.Shade100)

                        Material.elevation: 2
                        Image {
                            id: correctSelector
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 60
                            fillMode: Image.PreserveAspectFit
                            antialiasing: true
                            sourceSize.width: width
                            source: _CID === QBClient.question.CorrectAnswerIndex ?
                            "../assets/green_check.svg" : "../assets/grey_x.svg"
                            opacity: _CID === QBClient.question.CorrectAnswerIndex ?
                                         1:0.4
                        }

                        Column {
                            id: choiceEditorColumn
                            anchors.top: parent.top
                            anchors.left: correctSelector.right
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.margins: 10
                            spacing: 10
                            Text {
                                id: choiceTextlower
                                width: parent.width

                                wrapMode: "WordWrap" // for TextArea...
                                font.bold: true
                                font.pixelSize: analysisScrollView.fontpixelSize
                                text: model.modelData.ChoiceText ? model.modelData.ChoiceText : ""
                                Text {
                                   id: choiceTextTitle
                                   anchors.top: parent.bottom
                                   anchors.left: parent.left
                                   color: "navy"

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
                                   color: "navy"

                                   text: qsTr("Answer Explanation (hidden during test)")
                               }
                            }
                        }

                    }
                }
            }
            // END ANSWER CHOICES

            // EXPLAINATION TEXT
            TextArea {
                id: explainationField
                width: analysisScrollView.width

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
                   color: "navy"

                   text: qsTr("Explanation Text")
               }
                Timer {id: explanationTimer; interval: 30000; repeat: true;
                    onTriggered: QBClient.updateQuestion("ExpainationText",parent.text)
                }
            } Rectangle {
                height: 1
                width: analysisScrollView.width
                opacity: 0
            }
            // END EXPLAINATION TEXT


            Item{ width:analysisScrollView.width; height: childrenRect.height;  Button {
                    id: addTagsButton
                    width: analysisScrollView.width - 40
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
                }
            }

            // QUESTION IMAGES
            FlickableImageView {
                id: imagesListView
                width: analysisScrollView.width
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
                            text: qsTr("Click to Upload a Photo\n Less than 5 MB please.")
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
                Text {
                   id: imagesTitle
                   anchors.bottom: parent.top
                   anchors.left: parent.left
                   color: "navy"
                   text: qsTr("Question Images")
               }
            } Rectangle {
                // Simply a buffer
                height: 10
                width: analysisScrollView.width
                opacity: 0
            }
            // END QUESTION IMAGES

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
                text: qsTr("Return")
                color: "white"
            }
        }
//        Button {
//            Layout.fillWidth: true
//            Material.background: Material.Red
////            onClicked: deleteQuestionPopup.open()
//            Text {
//                anchors.centerIn: parent
//                text: qsTr("Retire Question")
//                color: "white"
//            }
//        }
    }

    // Additional components (popups and the like)
    AddTagsPopup {
        id: addTagsPopup
    }

    FileDragPopup {
        id: fileDragPopup
    }

    UserPane {
        id:userPaneRoot
    }
}
