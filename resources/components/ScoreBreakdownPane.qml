//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtCharts 2.15

Item {
    id:root
    anchors.fill: parent
    Image {
        anchors.fill: parent
        source: "../assets/backgrn_tile_white.png"
        fillMode: Image.Tile
        opacity: 1
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignTop
    }

    ScrollView {
        id:scrollView
        anchors.fill: parent
        Column {
            width: scrollView.width
            anchors.top: parent.top
            Text {
                id: reviewTestTitle
                text: qsTr("Test Review")
                font.bold:true
                font.pixelSize: Math.floor(30 * QBClient.screenDPI)
                width: parent.width
                color: "#3f5b68"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                id: reviewTestStats
                property real percent: {
                    return Math.round(QBClient.score.Correct/QBClient.score.Questions*100)
                }

                text: qsTr("You answered "+QBClient.score.Correct+ " of " + QBClient.score.Questions
                           + " correctly. This is approximately " + percent +"% correct.")
                font.bold:true
                font.pixelSize: Math.floor(20 * QBClient.screenDPI)
                width: parent.width
                color: "#3f5b68"
            }
            ChartView {
                id: testPerformanceChart
                property var score: QBClient.score
                width: parent.width > 750 ? parent.width*0.75:500
                height: width
                anchors.horizontalCenter: parent.horizontalCenter

                title: qsTr("Overall Test Performance")
                antialiasing: true
                backgroundColor: "transparent"
                plotAreaColor: "transparent"
                legend.alignment: Qt.AlignLeft
                theme:ChartView.ChartThemeBlueIcy
                PieSeries {
                    holeSize: 0.4
                    PieSlice{label:"Correct" ; value: QBClient.score.Correct
                    labelVisible: true}
                    PieSlice{label:"Incorrect"; value: QBClient.score.Questions
                                                       -QBClient.score.Correct
                                                       -QBClient.score.Unused}
                    PieSlice{label:"Unanswered"; value: QBClient.score.Unused
                    labelVisible: QBClient.score.Unused > 0}
                }
            }
            ChartView {
                id: topicPerformanceChart
                width: parent.width > 750 ? parent.width*0.75:500
                height: 100 * topicsAxis.count
                anchors.horizontalCenter: parent.horizontalCenter

                title: qsTr("Topic Breakdown")
                antialiasing: true
                backgroundColor: "transparent"
                legend.visible: false//: Qt.AlignBottom
                theme:ChartView.ChartThemeBlueIcy
                HorizontalPercentBarSeries {
                    id: topicBarSeries
                    axisY: BarCategoryAxis {id: topicsAxis;}
                    BarSet { id:correctBar; label: "Correct"}
                    BarSet { id:incorrectBar; label: "Incorrect"}
                    BarSet { id:unusedBar; label: "Unanswered"}
                    Component.onCompleted: {
                        var topics = QBClient.scoreTopics
                        var categories = []
                        for (var index in topics) {
                            categories.push(topics[index].TopicName)
                            correctBar.append(topics[index].Correct)
                            incorrectBar.append(topics[index].Questions
                                                -topics[index].Correct
                                                -topics[index].Unused)
                            unusedBar.append(topics[index].Unused)
                        } topicsAxis.categories = categories
                    }
                }
            }
            }
    //        ListView {
    //            width: parent.width / 3
    //            height: testPerformanceChart.height
    //            model: 5
    //            delegate: Rectangle {
    //                height: questionNumberText.contentHeight*1.5
    //                width: parent.width
    //                color: "red"
    //                Text {
    //                    id: questionNumberText
    //                    anchors.verticalCenter: parent.verticalCenter
    //                    anchors.left: parent.left
    //                    anchors.leftMargin: 20
    //                    text: qsTr("Question " + model.index)
    //                }
    //            }
    //        }
    }
}

