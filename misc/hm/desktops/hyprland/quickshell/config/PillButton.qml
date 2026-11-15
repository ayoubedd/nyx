import QtQuick

// Small rounded button with text or an icon (e.g. "Show less", ✕).
MouseArea {
    id: root

    property string text
    property string icon

    implicitWidth: icon ? 24 : label.implicitWidth + 18
    implicitHeight: 24
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.containsMouse ? Theme.glassTileHover : Theme.glassTile
        border.width: 1
        border.color: Theme.glassBorder
    }

    Text {
        id: label
        visible: !root.icon
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        color: Theme.foreground
    }

    Icon {
        visible: !!root.icon
        anchors.centerIn: parent
        name: root.icon
        size: 14
    }
}
