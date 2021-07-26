//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4

Popup {
    id: fileDragPopupRoot
    modal: true
    focus: true
    parent: Overlay.overlay
    anchors.centerIn: parent
    height: parent.height/2
    width: parent.width/2
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    Material.background: Material.color(Material.Grey, Material.Shade100)

    Text {
        id: name
        text: qsTr("Please Drag the Image to Upload Here")
        anchors.centerIn: parent
        font.bold: true
    }

    DropArea {
        id: fileDropArea
        anchors.fill: parent
        onEntered: {
            drag.accept (Qt.LinkAction);
            fileDragPopupRoot.Material.background = Material.color(Material.LightGreen, Material.Shade200)
        }
        onDropped: {
            QBClient.uploadImage(drop.urls)
            fileDragPopupRoot.Material.background = Material.color(Material.Grey, Material.Shade100)
            fileDragPopupRoot.close()
        }
        onExited: {
            fileDragPopupRoot.Material.background = Material.color(Material.Grey, Material.Shade100)
        }
    }

    onOpened: modal = true
    onClosed: modal = false
}
