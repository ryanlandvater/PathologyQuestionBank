//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.5
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4

Pane {
    id: root
    Material.elevation: 2
    topPadding: 0
    bottomPadding: 0
    Material.background: paneBackground

    property alias model: listView.model
    property int buttonHeight: 40
    property int heightMax
    property string mainColor:"#00274C"
    property string bkgrndColor: "#dce8f2"
    property string paneBackground: Material.background
    property string headerText
    property alias list: listView
    property int count: list.count
    signal clicked()

    visible: list.count
    property int defaultHeight: list.count*buttonHeight
                                + 45/*header*/+ 20/*footer*/
    height: heightMax ? (defaultHeight < heightMax
            ? list.count*buttonHeight+ 50 + 20
            : heightMax) : defaultHeight

    Rectangle {
        id: header
        height: 40
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: Material.backgroundColor
    }

    ScrollView {
        id: scrollView
        anchors.top: header.bottom
        anchors.topMargin: -(blur.height/2)
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        clip: true

        ListView {
            id: listView
            header: Rectangle{height:blur.height}
            footer: Rectangle{height: 20}
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            spacing: 0

            highlight: highlight
            highlightFollowsCurrentItem: true

        }

        // THIS IS A TEMPLATE DELEGATE, which is unused
        Component {
            id: button
            Rectangle {
                id: buttonBackground
                height: root.buttonHeight
                width: parent.width
                radius: index === listView.currentIndex ? 5 : 0
                Text {
                    id: buttonLeftText
                    anchors.fill: parent

                    text: qsTr(root.buttonLeftText)
                    font.bold: index == listView.currentIndex
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                } Text {
                    id: buttonRightText
                    anchors.fill: parent

                    text: qsTr(root.buttonRightText)
                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                } Text {
                    id: buttonCenterText
                    anchors.fill: parent

                    text: qsTr(root.buttonCenterText)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        if (containsMouse)
                            listView.currentIndex = index
                    } onClicked: root.clicked()
                }
            }
        }
        // END DELEGATE TEMPLATE

        Component {
            id: highlight
            Rectangle {
                color: root.bkgrndColor
                border.width: 2; border.color: root.mainColor
                width: listView.width; height: 50
                radius: 2
            }
        }

    }

     Rectangle { id: blur
        height: 10
        anchors.top: header.bottom
        anchors.topMargin: -height/2
        anchors.right: parent.right
        anchors.left: parent.left
        gradient: Gradient {
            GradientStop{position: 0; color: root.paneBackground}
            GradientStop{position: 1; color: "transparent"}
        }
    } Text {
        anchors.top: header.top; anchors.bottom: blur.bottom
        anchors.left: parent.left; anchors.right: parent.right

        text: qsTr(headerText)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.capitalization: Font.SmallCaps
        font.pixelSize: Math.floor (20* QBClient.screenDPI)
    }
//    Rectangle {
//        id: footer
//        anchors.bottom: parent.bottom
//        anchors.left: parent.left
//        anchors.right: parent.right
//        height: 5
//        color: "light grey"
//        visible: vertScroll.position < 0.9
//        MouseArea {
//            id: footerMouseArea
//            anchors.fill: parent
//            hoverEnabled: true
//            onContainsMouseChanged: {
//                if (containsMouse) {
//                    listView.currentIndex++;
//                    console.log("pos: "+ vertScroll.position+ "siz: " + vertScroll.size)
//                }
//            }
//        }
//    }
}
