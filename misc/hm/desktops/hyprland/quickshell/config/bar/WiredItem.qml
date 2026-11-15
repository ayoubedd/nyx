import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.common
import qs.components

// An Ethernet adapter: click to connect/disconnect its profile.
//   (lan)  Wired connection 1
//          Connected · 1 Gb/s
MouseArea {
    id: root

    required property var device

    readonly property bool busy: device.state === ConnectionState.Connecting || device.state === ConnectionState.Disconnecting

    function speed(mbps) {
        if (!mbps || mbps <= 0)
            return "";
        return mbps >= 1000 ? `${mbps / 1000} Gb/s` : `${mbps} Mb/s`;
    }

    width: parent ? parent.width : 0
    implicitHeight: 40
    hoverEnabled: true
    enabled: device.hasLink || device.connected
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
        if (device.connected)
            device.disconnect();
        else
            device.network?.connect();
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -6
        anchors.rightMargin: -6
        radius: 10
        color: root.containsMouse ? Theme.surfaceHigh : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10
        opacity: root.enabled ? 1 : 0.5

        Rectangle {
            implicitWidth: 30
            implicitHeight: 30
            radius: 15
            color: root.device.connected ? Theme.accent : Theme.surfaceHigh

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animDuration
                }
            }

            Icon {
                anchors.centerIn: parent
                name: "lan"
                filled: true
                size: 16
                color: root.device.connected ? Theme.background : Theme.foreground
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.device.network?.name || root.device.name
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: root.device.connected ? Font.DemiBold : Font.Medium
                color: Theme.foreground
            }

            Text {
                Layout.fillWidth: true
                text: root.busy ? (root.device.connected ? "Disconnecting…" : "Connecting…") : root.device.connected ? ["Connected", root.speed(root.device.linkSpeed)].filter(s => s).join(" · ") : root.device.hasLink ? "Not connected" : "Cable unplugged"
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 3
                color: Theme.foregroundDim
            }
        }
    }
}
