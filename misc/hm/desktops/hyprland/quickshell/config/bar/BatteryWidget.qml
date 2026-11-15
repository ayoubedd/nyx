import QtQuick
import qs.common
import qs.services
import qs.components

// Bar battery: icon, percentage and time left / time to full.
// Hidden on machines without a battery. Click opens the dashboard Power tab.
MouseArea {
    id: root

    visible: Battery.present
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: Battery.icon
            filled: true
            color: Battery.color
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${Math.round(Battery.percent * 100)}%`
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: Battery.low ? Theme.urgent : Theme.foreground
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            leftPadding: 2
            text: Battery.shortEstimate
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foregroundDim
        }
    }

    Tooltip {
        target: root
        text: `Battery: ${Math.round(Battery.percent * 100)}% · ${Battery.status}`
        show: root.containsMouse && !root.pressed
    }
}
