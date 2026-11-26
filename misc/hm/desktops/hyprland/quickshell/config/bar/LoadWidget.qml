import QtQuick
import qs.common
import qs.services
import qs.components

// Bar pill under sustained load (services/SystemLoad.qml):
//   [chip] CPU 87%   [memory] RAM 91%
// Only the parts that are high show; red above 90%. Click: the dashboard's
// System tab (what's using the CPU, with "End process"); Bar.qml wires
// `openSystem`.
MouseArea {
    id: root

    signal openSystem

    visible: SystemLoad.alert
    implicitWidth: row.implicitWidth + 18
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.openSystem()

    readonly property bool critical: (SystemLoad.cpuAlert && SystemLoad.cpu >= 0.9) || (SystemLoad.memAlert && SystemLoad.mem >= 0.9)

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.containsMouse ? Theme.surfaceHigh : Theme.surface
        border.width: 1
        border.color: root.critical ? Theme.urgent : Theme.surfaceHigh
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Reading {
            visible: SystemLoad.cpuAlert
            icon: "memory"
            label: "CPU"
            value: SystemLoad.cpu
        }

        Reading {
            visible: SystemLoad.memAlert
            icon: "memory_alt"
            label: "RAM"
            value: SystemLoad.mem
        }
    }

    Tooltip {
        target: root
        text: `CPU ${Math.round(SystemLoad.cpu * 100)}% · Memory ${(SystemLoad.memUsed / 1073741824).toFixed(1)} / ${(SystemLoad.memTotal / 1073741824).toFixed(1)} GiB · click to see what's using it`
        show: root.containsMouse
    }

    component Reading: Row {
        id: reading

        property string icon
        property string label
        property real value

        spacing: 4

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: reading.icon
            size: 15
            color: reading.value >= 0.9 ? Theme.urgent : Theme.foregroundDim
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${reading.label} ${Math.round(reading.value * 100)}%`
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            font.features: {
                "tnum": 1
            }
            color: reading.value >= 0.9 ? Theme.urgent : Theme.foreground
        }
    }
}
