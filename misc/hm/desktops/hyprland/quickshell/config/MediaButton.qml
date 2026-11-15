import QtQuick

// Round media control; `primary` is the larger filled play/pause button.
MouseArea {
    id: root

    property string icon
    property bool primary: false

    implicitWidth: primary ? 44 : 36
    implicitHeight: implicitWidth
    hoverEnabled: true
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    opacity: enabled ? 1 : 0.35

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.primary ? Theme.foreground : root.containsMouse ? Theme.surfaceHigh : "transparent"
    }

    // Drawn symbol (MediaGlyph) rather than the icon font.
    MediaGlyph {
        anchors.centerIn: parent
        size: root.primary ? 22 : 18
        kind: root.icon === "pause" ? "pause" : root.icon === "skip_next" ? "next" : root.icon === "skip_previous" ? "prev" : "play"
        color: root.primary ? Theme.background : Theme.foreground
    }
}
