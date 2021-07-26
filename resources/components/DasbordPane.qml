//
//  DashbordPane.qml
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/7/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import QtCharts 2.15

Pane {
    id: dashbordPaneRoot
    anchors.fill: parent
    topPadding: 0
    bottomPadding: 0

    function time (x) {
        var date = new Date(parseInt(x)).toLocaleDateString("en-US");
        return date;
    }

    ScrollView {
        id: dashboardScrollView
        property var vScrollBar: ScrollBar.vertical
        anchors.fill:parent
//        implicitContentHeight: 4000
        Column {
            width: dashboardScrollView.width
            Rectangle {height: 20 ; width: 10; color: "transparent"}
            QBGenericList {
                id: inbox
                width: parent.width * 0.98
                anchors.horizontalCenter: parent.horizontalCenter
                heightMax: 400
                model: QBClient.incompleteTests
                headerText: "Your Inbox / Incomplete Tests"
                list.delegate:publishedListDelegate
            } Component {
                id: publishedListDelegate
                Rectangle {
                    id: buttonBackground
                    property string mainAccent: inbox.mainColor
                    property int currentIndex: inbox.list.currentIndex
                    property string textColor: index === currentIndex ? mainAccent : "grey"
                    height: inbox.buttonHeight
                    width: parent.width
                    radius: index === currentIndex ? 5 : 0
                    color:  "transparent"
                    Text {
                        id: buttonLeftText
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: buttonRightText.left
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        text: {
                            if (model.modelData.SharedTestName)
                                return qsTr("Shared Test: <b>"
                                            + model.modelData.SharedTestName + "</b>")
                            else
                                return qsTr(QBClient.user.UserFirstName + "'s Test Number: <b>"
                                            + model.modelData.UserTestNumber + "</b>")
                        }

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: "WordWrap"
                        color: parent.textColor
                    } Text {
                        id: buttonRightText
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 10

                        text: qsTr("updated on " + time (model.modelData.Updated))

                        font.italic: true
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color: parent.textColor
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.9
                        height: 1
                        color: index === currentIndex?
                                   parent.mainAccent : "light grey"
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (containsMouse)
                                inbox.list.currentIndex = index
                        } onClicked: QBClient.resumeTest(model.modelData.TestID)
                    }
                }
            }

            Loader {
                id: chartsLoader
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                sourceComponent: QBClient.statistics.UserID ? chartsComponent : loadingComponent
//                onLoaded: dashboardScrollView.contentHeight = inbox.height + childrenRect.height;
            } Component {
                id: chartsComponent
                Item {
                    id: chartsRoot
                    height: progressChart.height + topicsChart.height
                    ChartView  {
                        id: progressChart
                        title: "Question Bank Progress"
                        Layout.alignment: Qt.AlignCenter
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 500
                        //            legend.alignment: Qt.AlignRight
                        legend.visible: false
                        antialiasing: true
                        backgroundColor: "transparent"

                        PieSeries {
                            id: pieSeries
                            holeSize: 0.45
                            size: 0.8
                            startAngle: 45; endAngle: 45

                            PieSlice {
                                property int val: QBClient.statistics.Correct
                                label: "Correct ("+val+")"
                                value: val
                                color:"#00274C"
                                labelVisible: val > 0
                            } PieSlice {
                                property int val: QBClient.statistics.Incorrect
                                label: "Incorrect ("+val+")";
                                value: val
                                color:"#c90000"
                                labelVisible:val > 0
                            } PieSlice {
                                id: unusedSlice
                                property int val: QBClient.statistics.Unused
                                label: "Unused ("+val+")";
                                value: val
                                color:"#607D8B99"
                                labelVisible: val > 0
                            }
                            NumberAnimation on endAngle {
                                id: pieAnimation
                                to: 405
                                duration: 1000
                                easing.type: Easing.OutCubic
                            }
                        }
                        Component.onCompleted: {
                            pieAnimation.start()
                        }
                    } Text {
                        property int complete
                        anchors.horizontalCenter: progressChart.horizontalCenter
                        anchors.verticalCenter: progressChart.verticalCenter
                        anchors.verticalCenterOffset: contentHeight/4
                        text: qsTr("<b>"+complete+"%</b><br>Complete")
                        horizontalAlignment: Text.AlignHCenter
                        NumberAnimation on complete {
                            id: completeTitleAnimation
                            from: 0
                            to: Math.round((1-unusedSlice.percentage) * 100)
                            duration: 1000
                            easing.type: Easing.OutCubic
                        }
                    }
                    ChartView  {
                        id: topicsChart
                        title: "Performance by Topic"
                        Layout.alignment: Qt.AlignCenter
                        anchors.top: progressChart.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        width: parent.width
                        height: 50 * topicsBarLabel.count + 100
                        legend.alignment: Qt.AlignRight
                        antialiasing: true
                        backgroundColor: "transparent"

                        HorizontalPercentBarSeries {
                            id: barWrapper
                            property var statsTopics: QBClient.statsTopics
                            function loadTopics () {
                                var topics = QBClient.statsTopics
                                if (topics.count < 1) return
                                var categories = [],correct = [],
                                incorrect = [],unused = []
                                for (var index in topics) {
                                    categories.push (topics[index].TopicName)
                                    correct.push    (topics[index].Correct)
                                    incorrect.push  (topics[index].Incorrect)
                                    unused.push     (topics[index].Unused)
                                }
                                topicsBarLabel.categories = categories
                                correctSet.values   = correct
                                incorrectSet.values = incorrect
                                unusedSet.values    = unused
                            }
                            axisY: BarCategoryAxis { id: topicsBarLabel}
                            axisX: ValueAxis {labelsVisible: false}
                            labelsVisible: true
                            BarSet {id: correctSet;     label: "Correct";   color:"#00274C"}
                            BarSet {id: incorrectSet;   label: "Incorrect"; color:"#c90000"}
                            BarSet {id: unusedSet;      label: "Unused";    color:"#607D8B99"}
                            Component.onCompleted: loadTopics()
                            onStatsTopicsChanged: loadTopics()
                        }
                    }
                }
            }
            Component {
                id: loadingComponent
                Rectangle {
    //                anchors.fill: parent
                    height: 500
                    color: "transparent"
                    BusyIndicator{id:i; anchors.centerIn:parent; running:true;
                        Material.elevation: 4}
                    Text{text:  "Retreiving your statistics..."
                        anchors.top: i.bottom; anchors.horizontalCenter: parent.horizontalCenter
                        color: Material.accent; font.bold: true; font.capitalization: Font.SmallCaps}
                }
            }
            QBGenericList {
                id: completed
                width: parent.width * 0.98
                mainColor: "#0d7d12"
                bkgrndColor: "#badebc"
                Material.background: "#f0f0f0"
                anchors.horizontalCenter: parent.horizontalCenter
                heightMax: 300
                model: QBClient.completeTests
                headerText: "Completed Tests / Review"
                list.delegate:completedTestsDelegate
            } Component {
                id: completedTestsDelegate
                Rectangle {
                    id: buttonBackground
                    property string mainAccent: completed.mainColor
                    property int currentIndex: completed.list.currentIndex
                    property string textColor: index === currentIndex ? mainAccent : "grey"
                    height: completed.buttonHeight
                    width: completed.width - completed.rightPadding*2
                    radius: index === currentIndex ? 5 : 0
                    color:  "transparent"
                    Text {
                        id: buttonLeftText
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: buttonRightText.left
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        text: {
                            if (model.modelData.SharedTestName)
                                return qsTr("Shared Test: <b>"
                                            + model.modelData.SharedTestName + "</b>")
                            else
                                return qsTr(QBClient.user.UserFirstName + "'s Test Number: <b>"
                                            + model.modelData.UserTestNumber + "</b>")
                        }

                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: "WordWrap"
                        color: parent.textColor
                    } Text {
                        id: buttonRightText
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 10

                        text: qsTr("updated on " + time (model.modelData.Updated))

                        font.italic: true
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color: parent.textColor
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.9
                        height: 1
                        color: index === currentIndex?
                                   parent.mainAccent : "light grey"
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (containsMouse)
                                completed.list.currentIndex = index
                        } onClicked: QBClient.resumeTest(model.modelData.TestID)
                    }
                }
            }
            Rectangle{height: 30; width: 1; color: "transparent"}
        }

    }
}
