//
//  login.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.4

import "./components"

Item {
    id: loginRoot
    anchors.fill: parent

    Rectangle{
        anchors.fill: parent
        gradient: Gradient{
            GradientStop{position: 0; color: "white"}
            GradientStop{position: 1; color: "grey"}
        }
    }

    Image {
        id: backgroundTile
        sourceSize.width: 512
        sourceSize.height: 512
        source: "./assets/backgrn_tile.svg"
        anchors.fill: parent
        fillMode: Image.Tile
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
    }
    LoginFrame {
        id: loginFrame
        Material.elevation: 3
    }
}
