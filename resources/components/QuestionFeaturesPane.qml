//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4

Item {
    id: questionFeaturesPaneRoot
    property alias questionNameFildText: questionNameField.text
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    TextField {
        id: questionNameField
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15

        wrapMode: "WordWrap"
        selectByMouse: true
        onEditingFinished: QBClient.updateQuestion("QuestionName",text);

        placeholderText: qsTr("Optional. This is for you or your collaborators, hoping to easily find this question.")
    } Text {
        id: questionNameFieldTitle
        anchors.top: questionNameField.bottom
        anchors.left: questionNameField.left
        color: "navy"

        text: qsTr("Question Name")
    }

    Item {
        id: clinicalHistoryFieldContainer
        anchors.top: questionNameFieldTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15
        height: clinicalHistoryField.height
        TextField {
            id: clinicalHistoryField
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            wrapMode: "WordWrap" // for TextArea...
            selectByMouse: true
            activeFocusOnTab: true
            onEditingFinished: QBClient.updateQuestion("ClinicalHistory",text);

            placeholderText: qsTr("Optional. If you would like to include relevant clinical history.")
        }
    } Text {
        id: clinicalHistoryFieldTitle
        anchors.top: clinicalHistoryFieldContainer.bottom
        anchors.left: clinicalHistoryFieldContainer.left
        color: "navy"

        text: qsTr("Relevant Clinical History")
    }

    Item {
        id: questionFieldContainer
        anchors.top: clinicalHistoryFieldTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15
        height: questionField.height
        TextField {
            id: questionField
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            wrapMode: "WordWrap"
            selectByMouse: true
            font.bold:true
            activeFocusOnTab: true
            onEditingFinished: QBClient.updateQuestion("QuestionText",text);

            placeholderText: qsTr("This is where the question goes.")
        }
    } Text {
        id: questionFieldTitle
        anchors.top: questionFieldContainer.bottom
        anchors.left: questionFieldContainer.left
        color: "navy"

        text: qsTr("Question Text")
    }

}
