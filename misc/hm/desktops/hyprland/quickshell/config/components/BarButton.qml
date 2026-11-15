import QtQuick
import qs.common

// Round, icon-only bar button with a subtle hover/active background.
MouseArea {
    id: root

    property alias icon: glyph.name
    property alias iconColor: glyph.color
    property alias filled: glyph.filled
    property bool active: false
    property bool badge: false
    // Hover text (see Tooltip.qml); empty = none.
    property string tooltip: ""

    implicitWidth: 30
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.active ? Theme.surfaceHigh : root.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    Icon {
        id: glyph
        anchors.centerIn: parent
    }

    Rectangle {
        visible: root.badge
        width: 6
        height: 6
        radius: 3
        color: Theme.urgent
        x: glyph.x + glyph.width - 4
        y: glyph.y + 1
    }

    Tooltip {
        target: root
        text: root.tooltip
        show: root.containsMouse && !root.pressed && !root.active
    }
}
