import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.4
import QtGraphicalEffects 1.12
import "./components"

Item {
    id: testRoot
    anchors.fill: parent

    Loader {
        id: scoreLoader
        anchors.top: parent.top
        anchors.bottom: bottomControlBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        sourceComponent: ScoreBreakdownPane{}
    }

//    Repeater {
//        id: testTopicss
//        anchors.top: testscore.bottom
//        model: QBClient.score.TestTopics
//        height: 100
//        Rectangle {
//            width: 10
//            height: 10
//            color: "red"
//        }
//    }

    Rectangle {
        id: bottomControlBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Material.color(Material.BlueGrey)

        Text {
            id: testID
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "<b>TestID:</b> <i>" + QBClient.test.TestID + "</i>"
            color: "#E6E7E8"

        }
        Image {
            id: pauseTest
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            fillMode: Image.PreserveAspectFit
            antialiasing: false
            source: "../assets/pause_test.svg"

            MouseArea {
                id:pauseTestButton
                anchors.fill: parent
                hoverEnabled: true
                onHoveredChanged: {
                    if (containsMouse)
                        parent.source  = "../assets/pause_test_hover.svg"
                    else parent.source = "../assets/pause_test.svg"
                }
                onPressed: parent.source  = "../assets/pause_test_pressed.svg"
                onReleased: parent.source = "../assets/pause_test.svg"

                onClicked: QBClient.pauseTest()
            }
        } DropShadow {
            anchors.fill: pauseTest
            radius: 8.0
            samples: 14
            color: "#80000000"
            source: pauseTest
        }

    }
}
