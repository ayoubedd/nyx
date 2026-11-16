import QtQuick
import qs.common
import qs.services
import qs.components

// Bar pill while a screen recording runs (services/Recorder.qml):
//   ● 1:42  ■
// Click anywhere on it to stop. Hidden otherwise.
MouseArea {
    id: root

    visible: Recorder.recording
    implicitWidth: row.implicitWidth + 18
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: Recorder.stop()

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.containsMouse ? Qt.lighter(Theme.urgent, 1.1) : Theme.urgent
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        // Pulsing dot.
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: Theme.background

            SequentialAnimation on opacity {
                running: Recorder.recording
                loops: Animation.Infinite
                NumberAnimation {
                    to: 0.3
                    duration: 700
                }
                NumberAnimation {
                    to: 1
                    duration: 700
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Recorder.duration(Recorder.elapsed)
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            font.features: {
                "tnum": 1
            }
            color: Theme.background
        }

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: "stop"
            filled: true
            size: 16
            color: Theme.background
        }
    }

    Tooltip {
        target: root
        text: `Recording${Recorder.withAudio ? " with sound" : ""} · click to stop`
        show: root.containsMouse
    }
}
