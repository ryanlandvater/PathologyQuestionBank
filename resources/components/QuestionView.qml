//
//  QuestionView.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 9/5/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4


ScrollView {
    id:questionScrollView
    property ScrollBar vScrollBar: ScrollBar.vertical
    property int fontpixelSize: Math.floor(18 * QBClient.screenDPI)
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    anchors.left: parent.left
    anchors.right: parent.right
    contentWidth: -1
    clip: true
    focus: true

    function year (x) {
        var date = new Date(parseInt(x)).toLocaleString(Qt.locale(),"yyyy")
        return date;
    }

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 25
        Layout.alignment: Qt.AlignHCenter

        // TOP BUFFER
        Rectangle {
            width: parent.width
            height: clinicalHistoryFieldTitle.height
            color: "transparent"
        }

        // CLINICAL HISTORY FIELD
        Text {
            id: clinicalHistoryField
            width: questionScrollView.width - questionScrollView.vScrollBar.width

            wrapMode: "WordWrap" // for TextArea...
            visible: QBClient.question.ClinicalHistory ? true : false;
            text: QBClient.question.ClinicalHistory ? QBClient.question.ClinicalHistory : ""
            font.pixelSize: questionScrollView.fontpixelSize

            Text {
               id: clinicalHistoryFieldTitle
               visible: QBClient.question.ClinicalHistory ? true : false
               anchors.bottom: parent.top
               anchors.left: parent.left
               color: "navy"

               text: qsTr("Relevant Clinical History")
           }
        }
        //END CLINICAL HISTORY FIELD

        // QUESTION TEXT FIELD
        Text {
            id: questionField
            width: questionScrollView.width - questionScrollView.vScrollBar.width

            wrapMode: "WordWrap"
            font.bold:true
            font.pixelSize: questionScrollView.fontpixelSize

            text: QBClient.question.QuestionText ? QBClient.question.QuestionText : ""

            Text {
               id: questionFieldTitle
               anchors.bottom: parent.top
               anchors.left: parent.left
               color: "navy"

               text: qsTr("Question Text")
           }
        }
        // END QUESTION TEXT FIELD

        FlickableImageView {
            id: imagesListView
            width: questionScrollView.width - questionScrollView.vScrollBar.width
            visible: QBClient.question.NumberOfImages > 0
            deleteButton: false
            footer: loadingFooter
        }
        Component{
            id: loadingFooter
            Item {
                property bool running: imagesListView.count < QBClient.question.NumberOfImages
                height: imagesListView.height
                width:  running? imagesListView.height:0
                visible: running
                Pane {
                    id: testUploadImageButton
                    anchors.fill: parent
                    anchors.margins: 20
                    Material.background: Material.color(Material.Grey,Material.Shade100)
                    Material.elevation: 5
                    BusyIndicator{
                        id: indicator
                        anchors.centerIn:parent;
                        running:running;
                    } Text {
                        anchors.top: indicator.bottom
                        anchors.horizontalCenter: indicator.horizontalCenter
                        text: qsTr("Loading Images...")
                        font.bold: true;
                        font.capitalization: Font.SmallCaps
                        color: Material.accentColor
                    }
                }
            }
        }

        // TODO: Move position bindings from the component to the Loader.
        //       Check all uses of 'parent' inside the root element of the component.
        //       Rename all outer uses of the id "answerList" to "loader_Column.item.answerList".
        Column {
            property alias answerList: inner_answerList
            anchors.left: parent.left
            anchors.right: parent.right
//            anchors.rightMargin: questionScrollView.vScrollBar.width

            // Inline function to shuffle answers
            function shuffle (model) {
                var currentIndx = model.length;
                var buffer;
                var randomIndx;
                while (0 !== currentIndx) {
                    randomIndx = Math.floor(Math.random() * currentIndx);
                    currentIndx -= 1;

                    buffer = model[currentIndx];
                    model[currentIndx] = model[randomIndx];
                    model[randomIndx] = buffer;
                } return model;
            }
            function top (model) {
                var selection = QBClient.question.ChoiceSelection;
                var buffer;
                for (var indx = 0; indx < model.length; indx++)
                    if (model[indx].ChoiceID === selection) {
                        buffer = model[0];
                        model[0] = model[indx];
                        model[indx] = buffer;
                        break;
                    }
                return model;
            }

            Repeater {
                id: inner_answerList
                model: QBClient.locked ? parent.top(QBClient.choices) : parent.shuffle(QBClient.choices)

                delegate: Item {
                    id: choiceRoot
                    width: parent.width
                    height: childrenRect.height

                    Loader {
                        id: loader_Button
                        property var question: QBClient.question
                        property bool correct: question.ChoiceSelection === question.CorrectAnswerIndex
                        property bool jmode: QBClient.test.JMode === "true"
                        sourceComponent: (question.ChoiceSelection === model.modelData.ChoiceID ||
                                          correct || jmode) && QBClient.locked  ? component_Pane : component_Button
                    }

                    Component {
                        id: component_Button
                        Button {
                            width: choiceRoot.width
                            height: 60
                            enabled: !QBClient.locked
                            contentItem: Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                width: parent.width
                                height: parent.height

                                text: qsTr(model.modelData.ChoiceText ? model.modelData.ChoiceText : "")
                                font.pixelSize: questionScrollView.fontpixelSize
                                verticalAlignment: Text.AlignVCenter
                                wrapMode: Text.WordWrap
                            }
                            Material.background: QBClient.question.ChoiceSelection ?
                                                     (QBClient.question.ChoiceSelection === model.modelData.ChoiceID ?
                                                          Material.color(Material.BlueGrey,Material.Shade300) :
                                                          Material.color(Material.BlueGrey,Material.Shade100)) :
                                                     Material.color(Material.BlueGrey, Material.Shade100)
                            Material.elevation: QBClient.question.ChoiceSelection ?
                                                    (QBClient.question.ChoiceSelection === model.modelData.ChoiceID ?
                                                         5 : 2) : 2

                            onClicked: QBClient.selectAnswer(model.modelData.ChoiceID)
                        }
                    }

                    //BEGIN COMPONENT PANE
                    Component {
                        id: component_Pane
                        Pane {
                            id: explainationPane
                            property bool correct: QBClient.question.ChoiceSelection ===
                                                   QBClient.question.CorrectAnswerIndex

                            width: choiceRoot.width
                            height: (correctSelector.height > choiceEditorColumn.height ?
                                        correctSelector.height : choiceEditorColumn.height) + 20
                            bottomInset: 10

                            Material.background: Material.color(model.modelData.ChoiceID ===
                                                                QBClient.question.CorrectAnswerIndex ?
                                                                    Material.Green : (index == 0 ?
                                                                                          Material.Red:
                                                                                          Material.Grey),
                                                                Material.Shade100)
                            Material.elevation: 3

                            Image {
                                id: correctSelector
                                property bool correct: QBClient.question.ChoiceSelection ===
                                                       QBClient.question.CorrectAnswerIndex
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: 60
                                fillMode: Image.PreserveAspectFit
                                sourceSize.width: width
//                                sourceSize.height: height
//                                sourceSize.height: height
                                source: model.modelData.ChoiceID === QBClient.question.CorrectAnswerIndex
                                ? "../assets/green_check.svg"
                                : (index == 0 ? "../assets/red_x.svg"
                                           : "../assets/grey_x.svg")
                            }


                            Column {
                                id: choiceEditorColumn
                                anchors.top: parent.top
                                anchors.left: correctSelector.right
                                anchors.leftMargin: 20
                                anchors.right: parent.right
                                spacing: 10
                                width: parent.width
                                height: choiceText.contentHeight + spacing +
                                        choiceExplainationText.contentHeight + spacing +
                                        choiceExplainationTextTitle.contentHeight

                                Text {
                                    id: choiceText
                                    width: parent.width
                                    height: contentHeight

                                    wrapMode: "WordWrap" // for TextArea...
                                    font.bold: true
                                    font.pixelSize: questionScrollView.fontpixelSize
                                    text: model.modelData.ChoiceText ? model.modelData.ChoiceText : ""
                                }

                                Text {
                                    id: choiceExplainationText
                                    width: parent.width
                                    height: contentHeight
                                    visible: text.length > 0

                                    wrapMode: "WordWrap" // for TextArea...
                                    font.italic: true
                                    font.pixelSize: questionScrollView.fontpixelSize - 2
//                                    verticalAlignment: Text.AlignBottom

                                    text: model.modelData.ChoiceExplanation ? model.modelData.ChoiceExplanation : ""

                                    Text {
                                        id: choiceExplainationTextTitle
                                        anchors.top: parent.bottom
                                        anchors.left: parent.left
                                        color: "navy"

                                        text: qsTr("Answer Explanation")
                                    }
                                }
                            }

                        }
                    }

                    //END COMPONENT PANE
                }
            }

            Button {
                property variant locked: QBClient.question
                width: parent.width
                height: 60
                visible: QBClient.question && !QBClient.locked
                contentItem: Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    text: qsTr("Submit Answer")
                    color: "white"
                    font.pixelSize: questionScrollView.fontpixelSize
                    font.capitalization: Font.SmallCaps
                    font.bold: true
                }

                Material.background: Material.color(Material.Indigo, Material.Shade400)
                onClicked: QBClient.submitAnswer()
            }

        }



        TextEdit {
            id: explainationField
            width: questionScrollView.width - questionScrollView.vScrollBar.width
            visible: QBClient.locked && text.length

            wrapMode: "WordWrap" // for TextArea...
            text: QBClient.question.ExpainationText ? QBClient.question.ExpainationText : ""
            font.pixelSize: questionScrollView.fontpixelSize

            readOnly: true
            selectByMouse: true
            selectionColor: "#607D8B"

            Text {
               id: explainationFieldTitle
               anchors.bottom: parent.top
               anchors.left: parent.left
               color: "navy"

               text: qsTr("Explanation Text")
           }
        }

        Text {
            id: copyright
            width: parent.width
            visible: QBClient.locked
            font.pixelSize: questionScrollView.fontpixelSize
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            text: {
                var author = QBClient.question.Author
                if (!author) return "";
                return qsTr("© Copyright "
                            + author.UserFirstName
                            +" " + author.UserLastName
                            +", "+ year(author.Updated))
            }
        }

        // Bottom Buffer
        Rectangle {
            width: parent.width
            height: 20
            color: "transparent"
        }

    }



}
