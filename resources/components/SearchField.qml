//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12

Pane {
    id: searchRoot
    property int radius: 10
    property int buttonHeight: 20
    property alias placeholder: searchTextField.placeholderText
    property string searchCriterion
    property var searchList: QBClient.searchResults
    property alias choices: choiceList
    property alias popup: searchListPopup
    signal selected;

    Material.elevation: 5
    topPadding: 5
    bottomPadding: 0
    background: Rectangle {
        color: "white" //searchRoot.Material.backgroundColor
        radius: searchRoot.Material.elevation > 0 ? searchRoot.radius : 0

        layer.enabled: searchRoot.enabled && searchRoot.Material.elevation > 0
        layer.effect: ElevationEffect {
            elevation: searchRoot.Material.elevation
        }
    }

    Column {
        TextField {
            id: searchTextField
            width: searchRoot.width
            background: Rectangle{anchors.fill: parent; color: "transparent"}
            selectByMouse: true
            onTextEdited: QBClient.search(searchCriterion,text)
        }
        Keys.onDownPressed: choiceList.incrementCurrentIndex()
        Keys.onUpPressed:   choiceList.decrementCurrentIndex()
        Keys.onEnterPressed: searchRoot.selected()
        Keys.onReturnPressed: searchRoot.selected()
    }
    onSearchListChanged: {
        var list = QBClient.searchResults
        if (list.length > 0
                && searchTextField.length
                && searchTextField.activeFocus)
            searchListPopup.open()
        else
            searchListPopup.close()
    }

    Popup {
        id: searchListPopup
        modal: false
        width: parent.width
        height: 120
        y: parent.y + parent.height
        ListView {
            id: choiceList
            model: QBClient.searchResults
            width: parent.width
            height: parent.height
            spacing: 5
            clip: true
        }

    }
}

