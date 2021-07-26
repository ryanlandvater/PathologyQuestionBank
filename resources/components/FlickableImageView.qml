//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.14
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtQuick.Controls.Material.impl 2.4

Flickable {
    id:flickableImageViewRoot
    property alias footer: imageListView.footer
    property bool deleteButton: false
    property bool editMode: false
    property int count: imageListView.count
    width: parent.width
    anchors.margins: 10
    height: 250
    clip: true

    ListView {
        id: imageListView
        anchors.fill: parent
        model: QBClient.images
        orientation: ListView.Horizontal
        spacing: 5

        delegate: Image {
            id: thumbnailImage
            height: parent.height
            source: "image://QBImageDraw/"+model.modelData.ImageID
            cache: false
            fillMode: Image.PreserveAspectFit
            Rectangle{
                anchors.fill: parent
                color: "grey"
                opacity: imageMouseArea.containsMouse ? 0.15 : 0
            } Text {
                anchors.centerIn: parent
                text: qsTr("Click for Full Sized Image")
                opacity: imageMouseArea.containsMouse ? 0.5 : 0
            } Text {
                visible: flickableImageViewRoot.editMode
                anchors.verticalCenter: parent.verticalCenter
                anchors.bottom: parent.bottom
                text: model.modelData.FileName
                opacity: imageMouseArea.containsMouse ? 0.5 : 0
                font.bold: true
            } MouseArea {
                id: imageMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    // Full sized popup here
                    fullsizedImagePopup.open()
                    fullsizedImagePopup.imgid = model.modelData.ImageID
                }
            }
//            Rectangle {
//                id: deleteImageButton
//                color: deleteChoiceSelectorMouseArea.containsMouse ?
//                                    "#F44336" : "#DBDBDB"
//                width: 80
//                height: 20
//                anchors.right: parent.right
//                anchors.top: parent.top
//                anchors.topMargin: -choicePane.topPadding
//                Rectangle {
//                    id: rad
//                    color: parent.color
//                    width: parent.width
//                    radius: 5
//                    height: radius * 2
//                    anchors.verticalCenter: parent.bottom
//                } Text {
//                    id: removeText
//                    text: qsTr("Remove")
//                    anchors.top: parent.top
//                    anchors.right: parent.right
//                    anchors.left: parent.left
//                    anchors.bottom: rad.bottom
//                    horizontalAlignment: Text.AlignHCenter
//                    verticalAlignment: Text.AlignVCenter
//                    color: deleteChoiceSelectorMouseArea.containsMouse ?
//                                        "black" : "dark grey"
//                } MouseArea {
//                    id: deleteChoiceSelectorMouseArea
//                    anchors.top: parent.top
//                    anchors.bottom: rad.bottom
//                    anchors.left: parent.left
//                    anchors.right: parent.right
//                    hoverEnabled: true
//                    onClicked: QBClient.removeChoice(_CID)
//                }
//                Image {
//                id: deleteImageButton
//                source: deleteChoiceSelectorMouseArea.containsMouse ?
//                            (QBClient.screenDPI>0.9?"../assets/red_x.png":"../assets/red_x_low.png"):
//                            (QBClient.screenDPI>0.9?"../assets/grey_x.png":"../assets/grey_x_low.png")
//                opacity: deleteChoiceSelectorMouseArea.containsMouse ?
//                         1 : 0.8
//                width: 40
//                height: 40
//                visible: flickableImageViewRoot.deleteButton
//                anchors.top: parent.top
//                anchors.right: parent.right
//                ToolTip.text: "Remove " + model.modelData.FileName
//                ToolTip.visible: deleteChoiceSelectorMouseArea.containsMouse
//                MouseArea {
//                    id: deleteChoiceSelectorMouseArea
//                    anchors.fill: parent
//                    hoverEnabled: true
//                    onClicked: QBClient.removeImage(model.modelData.ImageID)
//                }
//            }
            Item {
                id: deleteImageButton
                width: 80
                height: 25
                visible: flickableImageViewRoot.deleteButton
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.top: parent.top
                opacity: deleteChoiceSelectorMouseArea.containsMouse ? 1 : 0.7
                clip: true
                Rectangle {
                    id: rad
                    anchors.fill: parent
                    anchors.topMargin: - radius
                    color: deleteChoiceSelectorMouseArea.containsMouse ?
                                        "#F44336" : "#DBDBDB"
                    radius: 5
                } Text {
                    id: removeText
                    text: qsTr("Remove")
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.bottom: rad.bottom
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                    ToolTip.text: "Remove " + model.modelData.FileName
                    ToolTip.visible: deleteChoiceSelectorMouseArea.containsMouse
                } MouseArea {
                    id: deleteChoiceSelectorMouseArea
                    anchors.top: parent.top
                    anchors.bottom: rad.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    hoverEnabled: true
                    onClicked: QBClient.removeImage(model.modelData.ImageID)
                }
            }
            Popup {
                id: fullsizedImagePopup
                property string imgid
                modal: true
                focus: true
                parent: Overlay.overlay
                x: parent.width * 0.05
                y: parent.height * 0.05
                height: parent.height * 0.9
                width: parent.width * 0.9
                padding: 0
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                onAboutToShow: fullsizedImageLoader.active = true
                onAboutToHide: fullsizedImageLoader.active = false
                Loader {
                    id: fullsizedImageLoader
                    anchors.fill: parent
                    active: false

                    sourceComponent: Flickable{
                        id: imageFlickable
                        property alias imageWidth: imageFullView.width
                        property alias imageHeight: imageFullView.height
                        anchors.fill: parent
                        clip:true
                        Image {
                            id: imageFullView
                            anchors.centerIn: parent
                            scale: zoomSlider.visible ? zoomSlider.value : 1
                            onScaleChanged: {
                                    var zoomPoint = Qt.point(imageFlickable.width/2 + imageFlickable.contentX,
                                                         imageFlickable.height/2 + imageFlickable.contentY);

                                    imageFlickable.resizeContent(width*scale, height*scale, zoomPoint);
                                    imageFlickable.returnToBounds();
                                }
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            source: thumbnailImage.source
                            PinchArea {
                                pinch.target: imageFullView
                                MouseArea{anchors.fill: parent}
                            }
                        }
//                        Component.onCompleted: {
//                            if (imageFullView.height < fullsizedImagePopup.height ||
//                                    imageFullView.width < fullsizedImagePopup.width){
//                                fullsizedImagePopup.height = imageFullView.height
//                                fullsizedImagePopup.width = imageFullView.width
//                            }
//                        }
                    }
                }
                Item {
                    id: closeImageButton
                    width: 80
                    height: 25
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: parent.top
                    opacity: closeImageMouseArea.containsMouse ? 1 : 0.7
                    clip: true
                    Rectangle {
                        id: close_rad
                        anchors.fill: parent
                        anchors.topMargin: - radius
                        color: closeImageMouseArea.containsMouse ?
                                            "#F44336" : "#DBDBDB"
                        radius: 5
                    } Text {
                        text: qsTr("Close")
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.bottom: close_rad.bottom
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        color: "black"
                    } MouseArea {
                        id: closeImageMouseArea
                        anchors.top: parent.top
                        anchors.bottom: close_rad.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        hoverEnabled: true
                        onClicked: fullsizedImagePopup.close()
                    }
                }
                Rectangle {
                    anchors.verticalCenter: fullsizedImageLoader.verticalCenter
                    anchors.right: fullsizedImageLoader.right
                    anchors.rightMargin: 10

                    color: "white"
                    width: zoomSlider.width
                    radius: width / 2
                    Material.elevation: 6
                    height: zoomSlider.height + radius + zoomIn.height + zoomOut.height
                    layer.enabled: true
                    layer.effect: ElevationEffect {elevation: parent.Material.elevation}

                    opacity: zoomSlider.hovered || zoomSlider.pressed ? 0.9 : 0.6
                    visible: if (fullsizedImageLoader.item)
                                 (fullsizedImageLoader.width/fullsizedImageLoader.item.imageWidth < 1)
                             else false

                    Image {
                        id: zoomIn
                        anchors.bottom: zoomSlider.top
//                        anchors.bottomMargin: parent.radius
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        width: parent.width * 0.6
                        source: "../assets/zoom_in.png"
                    }
                    Slider {
                        id: zoomSlider
                        orientation: "Vertical"
                        anchors.centerIn: parent
                        height: fullsizedImageLoader.height / 2
                        from: if (fullsizedImageLoader.item) {
                                  var loaderWidth = fullsizedImageLoader.width
                                  var loaderHeight = fullsizedImageLoader.height
                                  var imgWidth = fullsizedImageLoader.item.imageWidth
                                  var imgHeight = fullsizedImageLoader.item.imageHeight
                                  return (loaderWidth / imgWidth > loaderHeight / imgHeight) ?
                                              loaderWidth / imgWidth : loaderHeight / imgHeight
                              } else 0.0
                        to: 1.0
                        value: from
                    }
                    Image {
                        id: zoomOut
                        anchors.top: zoomSlider.bottom
//                        anchors.topMargin: parent.radius
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        width: parent.width * 0.6
                        source: "../assets/zoom_out.png"
                    }
                }

            }
            // END POPUP
        }
    }


//    Image {
//        id: fullSizedImage
//        property string imageID
//        source: "image://QBImageDraw/"+imageID
//    }
}
