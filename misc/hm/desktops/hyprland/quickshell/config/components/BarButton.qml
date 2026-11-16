import QtQuick
import qs.common

// Round bar button with a subtle hover/active background: an icon, plus an
// optional short label after it (e.g. a low battery level).
MouseArea {
    id: root

    property alias icon: glyph.name
    property alias iconColor: glyph.color
    property alias filled: glyph.filled
    property bool active: false
    property bool badge: false
    // Text after the icon; empty = icon only.
    property string label: ""
    property color labelColor: Theme.foreground
    // Hover text (see Tooltip.qml); empty = none.
    property string tooltip: ""

    implicitWidth: label ? content.implicitWidth + 16 : 30
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

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 3

        Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: glyph.implicitWidth
            implicitHeight: glyph.implicitHeight

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
        }

        Text {
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.features: {
                "tnum": 1
            }
            color: root.labelColor
        }
    }

    Tooltip {
        target: root
        text: root.tooltip
        show: root.containsMouse && !root.pressed && !root.active
    }
}
