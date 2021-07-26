//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4

Popup {
    id: deleteQuestionPopupRoot
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
        text: qsTr("Are you sure you want to delete this question? \n This cannot be undone.")
    } Item { anchors.fill: parent; Button {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        Material.background: Material.Red
        onClicked: QBClient.deleteQuestion(QBClient.question.QuestionID)
        text: "Yes, DELETE this question"
    }}

    onOpened: modal = true
    onClosed: modal = false
}
