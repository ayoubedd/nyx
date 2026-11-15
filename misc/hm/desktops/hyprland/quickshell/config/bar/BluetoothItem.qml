import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.common
import qs.components

// A Bluetooth device in the Bluetooth menu:
//   (icon)  Buds Core                    🔋 80%   ✕
//           Connected
// Paired devices: click = connect/disconnect, hover ✕ = forget.
// Nearby devices: click = pair (handled by the owner via clicked()).
MouseArea {
    id: root

    required property var device
    property bool paired: true
    property string label
    property string icon: "bluetooth"
    property bool failed: false

    readonly property bool busy: device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting
    readonly property real battery: device.battery > 1 ? device.battery / 100 : device.battery
    readonly property bool showBattery: paired && device.connected && device.batteryAvailable

    function batteryIcon(b) {
        return b > 0.9 ? "battery_full" : `battery_${Math.max(0, Math.min(6, Math.round(b * 6)))}_bar`;
    }

    width: parent ? parent.width : 0
    implicitHeight: 40
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

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
                name: root.icon
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
                text: root.label
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: root.device.connected ? Font.DemiBold : Font.Medium
                color: Theme.foreground
            }

            Text {
                Layout.fillWidth: true
                text: {
                    if (!root.paired)
                        return root.device.pairing ? "Pairing…" : root.failed ? "Pairing failed" : "Not paired";
                    if (root.busy)
                        return root.device.connected ? "Disconnecting…" : "Connecting…";
                    return root.device.connected ? "Connected" : "Not connected";
                }
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 3
                color: root.failed && !root.device.pairing ? Theme.urgent : Theme.foregroundDim
            }
        }

        // Battery (connected devices that report it).
        Row {
            visible: root.showBattery && !forget.visible
            spacing: 2

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: root.batteryIcon(root.battery)
                size: 15
                rotation: 90
                color: root.battery <= 0.2 ? Theme.urgent : Theme.foregroundDim
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: `${Math.round(root.battery * 100)}%`
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }
        }

        // Forget (paired devices, on hover).
        MouseArea {
            id: forget
            visible: root.paired && (root.containsMouse || containsMouse) && !root.busy
            implicitWidth: 24
            implicitHeight: 24
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.device.forget()

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: forget.containsMouse ? Theme.muted : "transparent"
            }

            Icon {
                anchors.centerIn: parent
                name: "close"
                size: 15
                color: Theme.foregroundDim
            }
        }

        // "Pair" pill (nearby devices).
        Rectangle {
            visible: !root.paired && !root.device.pairing
            implicitWidth: pairText.implicitWidth + 18
            implicitHeight: 24
            radius: height / 2
            color: root.containsMouse ? Theme.accent : Theme.surfaceHigh

            Text {
                id: pairText
                anchors.centerIn: parent
                text: root.failed ? "Retry" : "Pair"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.weight: Font.DemiBold
                color: root.containsMouse ? Theme.background : Theme.foreground
            }
        }

        Icon {
            visible: !root.paired && root.device.pairing
            name: "progress_activity"
            size: 16
            color: Theme.foregroundDim

            RotationAnimation on rotation {
                running: parent.visible
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 1000
            }
        }
    }
}
