import QtQuick
import qs.common

// Vertical tab in the dashboard rail: icon with a small label underneath.
MouseArea {
    id: root

    property string icon
    property string label
    property bool selected: false

    width: parent ? parent.width : 72
    implicitHeight: 60
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: root.selected ? Theme.surfaceHigh : root.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 3

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: root.icon
            filled: root.selected
            size: 22
            color: root.selected ? Theme.accent : Theme.foregroundDim
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: root.selected ? Theme.foreground : Theme.foregroundDim
        }
    }
}
