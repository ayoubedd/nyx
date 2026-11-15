import QtQuick
import QtQuick.Layouts

// Clickable row: icon, label, optional right-aligned detail text.
MouseArea {
    id: root

    property string icon
    property string label
    property string detail
    property bool highlighted: false
    property color tint: Theme.foreground

    width: parent ? parent.width : 0
    implicitHeight: 36
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius - 4
        color: root.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        Icon {
            name: root.icon
            filled: root.highlighted
            color: root.highlighted ? Theme.accent : root.tint
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: root.highlighted ? Theme.foreground : root.tint
        }

        Text {
            visible: text !== ""
            text: root.detail
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }
    }
}
