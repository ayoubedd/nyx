import QtQuick
import qs.common

// Rounded dialog button; `primary` is the filled accent one.
MouseArea {
    id: root

    property string text
    property bool primary: false

    implicitHeight: 38
    implicitWidth: label.implicitWidth + 32
    hoverEnabled: true
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    opacity: enabled ? 1 : 0.45

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.primary ? (root.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent) : (root.containsMouse ? Theme.surfaceHigh : Theme.surface)

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        font.weight: root.primary ? Font.DemiBold : Font.Normal
        color: root.primary ? Theme.background : Theme.foreground
    }
}
