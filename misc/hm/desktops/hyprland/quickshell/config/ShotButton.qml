import QtQuick

// Toolbar button for the screenshot overlay: icon with an optional label.
MouseArea {
    id: root

    property string icon
    property string label
    property bool selected: false

    implicitWidth: row.implicitWidth + 20
    implicitHeight: 36
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.selected ? Theme.accent : root.containsMouse ? Theme.surfaceHigh : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            filled: root.selected
            size: 18
            color: root.selected ? Theme.background : Theme.foreground
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            text: root.label
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: root.selected ? Font.DemiBold : Font.Normal
            color: root.selected ? Theme.background : Theme.foreground
        }
    }
}
