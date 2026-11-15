import QtQuick
import qs.common
import qs.components

// Tiny round icon button for the bar media controls.
MouseArea {
    id: root

    property string icon

    implicitWidth: 22
    implicitHeight: 22
    hoverEnabled: true
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    opacity: enabled ? 1 : 0.35

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.containsMouse ? Theme.surfaceHigh : "transparent"
    }

    // Drawn symbol (MediaGlyph) rather than the icon font.
    MediaGlyph {
        anchors.centerIn: parent
        size: 14
        kind: root.icon === "pause" ? "pause" : root.icon === "skip_next" ? "next" : root.icon === "skip_previous" ? "prev" : "play"
        color: Theme.foreground
    }
}
