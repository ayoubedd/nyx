import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.common
import qs.services
import qs.components

// Bar Bluetooth icon + quick menu: on/off and your known (paired) devices,
// click one to connect / disconnect. Everything else (pairing new devices,
// trust, block, forget, visibility) is in the notification center's
// Bluetooth view (notifications/BluetoothDetail.qml): "Bluetooth settings…".
BarButton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter?.enabled ?? false
    readonly property var devices: adapter?.devices.values ?? []
    readonly property bool anyConnected: devices.some(d => d.connected)
    readonly property var paired: devices.filter(d => d.paired || d.bonded).sort((a, b) => b.connected - a.connected)

    // BlueZ sets a nameless device's alias to its address ("AA-BB-CC-…"),
    // so an "address-looking" name isn't a name.
    function deviceLabel(d) {
        for (const n of [d.deviceName, d.name])
            if (n && !/^([0-9a-f]{2}[-:_]){5}[0-9a-f]{2}$/i.test(n))
                return n;
        return d.address;
    }

    function deviceIcon(d) {
        const i = d.icon || "";
        return i.startsWith("audio-head") ? "headphones" : i.startsWith("audio") ? "speaker" : i.startsWith("input-mouse") ? "mouse" : i.startsWith("input-keyboard") ? "keyboard" : i.startsWith("input-gaming") ? "sports_esports" : i.startsWith("phone") ? "smartphone" : i.startsWith("computer") ? "computer" : "bluetooth";
    }

    icon: !btOn ? "bluetooth_disabled" : anyConnected ? "bluetooth_connected" : "bluetooth"
    // A connected device low on battery: red icon + its level.
    readonly property bool deviceLow: BluetoothBattery.low.length > 0
    iconColor: deviceLow ? Theme.urgent : btOn ? Theme.foreground : Theme.foregroundDim
    label: deviceLow ? `${BluetoothBattery.percent(BluetoothBattery.lowest)}%` : ""
    labelColor: Theme.urgent
    active: menu.shown
    tooltip: {
        if (!adapter)
            return "Bluetooth: unavailable";
        if (!btOn)
            return "Bluetooth: off";
        const connected = devices.filter(d => d.connected).map(d => {
            const b = d.battery > 1 ? d.battery / 100 : d.battery;
            return d.batteryAvailable ? `${root.deviceLabel(d)} (${Math.round(b * 100)}%)` : root.deviceLabel(d);
        });
        return connected.length ? `Bluetooth: ${connected.join(", ")}` : "Bluetooth: on · nothing connected";
    }
    onClicked: menu.toggle()

    // qs -c nyx ipc call bar toggle bluetooth
    Connections {
        target: Ui
        function onMenuRequested(name, screen) {
            if (name === "bluetooth" && (root.QsWindow.window?.screen?.name ?? "") === screen)
                menu.toggle();
        }
    }

    Dropdown {
        id: menu
        target: root
        contentWidth: 340
        contentSpacing: 8
        // Opening the menu switches a radio BluetoothAutoOff turned off back on.
        onShownChanged: if (shown)
            BluetoothAutoOff.wake()

        Card {
            id: mineColumn

            RowLayout {
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    text: "Bluetooth"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Toggle {
                    checked: root.btOn
                    onToggled: if (root.adapter)
                        root.adapter.enabled = !root.adapter.enabled
                }
            }

            Text {
                visible: !root.btOn
                text: !root.adapter ? "No Bluetooth adapter" : "Bluetooth is off"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            Text {
                visible: root.btOn
                text: root.paired.length ? "My devices" : "No known devices yet. Pair one in Bluetooth settings."
                width: parent.width
                wrapMode: Text.WordWrap
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 3
                font.weight: root.paired.length ? Font.DemiBold : Font.Normal
                color: Theme.foregroundDim
            }

            Column {
                visible: root.btOn && root.paired.length > 0
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.btOn ? root.paired : []

                    BluetoothItem {
                        required property var modelData
                        width: mineColumn.contentWidth
                        device: modelData
                        label: root.deviceLabel(modelData)
                        icon: root.deviceIcon(modelData)
                        allowForget: false
                        onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                    }
                }
            }
        }

        MenuItem {
            icon: "settings"
            label: "Bluetooth settings…"
            onClicked: {
                menu.shown = false;
                Notifs.openCenterAt("bluetooth");
            }
        }
    }
}
