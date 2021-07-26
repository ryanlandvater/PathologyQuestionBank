//
//  Dashboard.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/6/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import "./components"

Item {
    id: dashboardRoot
    anchors.fill: parent

    // START SWIPE VIEW
    SwipeView {
        id:dashboardSwipe
        anchors.top: dashboardRoot.top
        anchors.bottom: dashboardRoot.bottom
        anchors.left: userPaneRoot.right
        anchors.right: dashboardRoot.right
        anchors.margins: 0

        currentIndex: 1
        interactive: false
        orientation: Qt.Horizontal


        // Access QBank
        Loader {
            id: qbankPane
            active: SwipeView.isCurrentItem
            source: "./components/NewTestPane.qml"
        }

        Loader {
            id: dashbordPane
            active: SwipeView.isCurrentItem
            source: "./components/DasbordPane.qml"
        }

        Loader {
            id: questionWriterPane
            active: SwipeView.isCurrentItem
            source: "./components/QuestionWriterPane.qml"
        }

    }
    // END SWIPE VIEW

    UserPane {
        id:userPaneRoot
    }


}
