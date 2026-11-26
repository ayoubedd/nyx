import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import qs.common
import qs.services
import qs.components
import qs.bar

// Bluetooth settings in the notification center (the bar menu only connects
// known devices): the adapter (name, "visible to other devices"), every
// paired device with connect / disconnect, battery, trusted (auto-connect),
// blocked and forget, and pairing new devices.
//
// Pairing: "Scan" discovers nearby devices (stops after 60 s, or when you
// leave the view); click one to pair, then it's trusted and connected.
// Note: quickshell registers no BlueZ agent; bt-agent (NoInputNoOutput, see
// quickshell/default.nix) does "Just Works" pairing, so headphones, mice,
// speakers and controllers are fine; phones just confirm on their side.
ColumnLayout {
    id: root

    spacing: 12

    // Opening the panel switches a radio BluetoothAutoOff turned off back on.
    Component.onCompleted: BluetoothAutoOff.wake()

    // ---- pairing state ----
    readonly property bool scanning: adapter?.discovering ?? false
    readonly property var unpaired: (adapter?.devices.values ?? []).filter(d => !d.paired && !d.bonded)
    // Discovery order (no sorting), so new devices are appended instead of
    // reshuffling the list. Nameless ones (mostly BLE gadgets) are counted.
    readonly property var nearby: unpaired.filter(d => realName(d) !== "")
    readonly property int unnamedCount: unpaired.length - nearby.length
    property string failedAddress: "" // pairing just failed (shown a few s)
    property string pendingAddress: "" // being paired from here

    function realName(d) {
        for (const n of [d.deviceName, d.name])
            if (n && !/^([0-9a-f]{2}[-:_]){5}[0-9a-f]{2}$/i.test(n))
                return n;
        return "";
    }

    function setScanning(on) {
        if (!adapter || !btOn)
            return;
        adapter.discovering = on;
        if (on)
            scanTimeout.restart();
        else
            scanTimeout.stop();
    }

    function pair(d) {
        failedAddress = "";
        pendingAddress = d.address;
        if (d.connected) {
            // Connected but never bonded: BlueZ refuses to pair while
            // connected, so drop the link first, then pair.
            d.disconnect();
            pairAfterDisconnect.device = d;
            pairAfterDisconnect.restart();
        } else {
            d.pair();
        }
    }

    // Paired: trust (auto-reconnect) and connect. Done here, not in the row:
    // on success the device moves to "My devices", destroying that row.
    onPairedChanged: {
        if (!pendingAddress)
            return;
        const d = paired.find(x => x.address === pendingAddress);
        if (d) {
            pendingAddress = "";
            d.trusted = true;
            d.connect();
        }
    }

    Timer {
        id: pairAfterDisconnect
        property var device: null
        interval: 1200
        onTriggered: {
            if (device && !device.paired)
                device.pair();
            device = null;
        }
    }

    Timer {
        id: scanTimeout
        interval: 60000
        onTriggered: root.setScanning(false)
    }

    Timer {
        id: clearFailed
        interval: 4000
        onTriggered: root.failedAddress = ""
    }

    // Leaving the view (or the center) stops a scan.
    Connections {
        target: Notifs
        function onCenterDetailChanged() {
            if (Notifs.centerDetail !== "bluetooth" && root.scanning)
                root.setScanning(false);
        }
    }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter?.enabled ?? false
    readonly property var paired: (adapter?.devices.values ?? []).filter(d => d.paired || d.bonded).sort((a, b) => (b.connected - a.connected) || name(a).localeCompare(name(b)))

    function name(d) {
        for (const n of [d.deviceName, d.name])
            if (n && !/^([0-9a-f]{2}[-:_]){5}[0-9a-f]{2}$/i.test(n))
                return n;
        return d.address;
    }

    function icon(d) {
        const i = d.icon || "";
        return i.startsWith("audio-head") ? "headphones" : i.startsWith("audio") ? "speaker" : i.startsWith("input-mouse") ? "mouse" : i.startsWith("input-keyboard") ? "keyboard" : i.startsWith("input-gaming") ? "sports_esports" : i.startsWith("phone") ? "smartphone" : i.startsWith("computer") ? "computer" : "bluetooth";
    }

    function battery(d) {
        const b = d.battery > 1 ? d.battery / 100 : d.battery;
        return Math.round(b * 100);
    }

    // ---- switch + this computer ----
    Tile {
        Layout.fillWidth: true
        spacing: 10

        SwitchRow {
            icon: root.btOn ? "bluetooth" : "bluetooth_disabled"
            label: "Bluetooth"
            detail: !root.adapter ? "No Bluetooth adapter" : !root.btOn ? "Off" : `${root.paired.filter(d => d.connected).length} connected`
            checked: root.btOn
            onToggled: if (root.adapter)
                root.adapter.enabled = !root.adapter.enabled
        }

        Rectangle {
            visible: root.btOn
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        // Visible to other devices (turns itself off after 3 minutes).
        SwitchRow {
            visible: root.btOn
            icon: "visibility"
            label: "Visible to other devices"
            detail: `As "${root.adapter?.name ?? ""}"${root.adapter?.discoverable ? " · for 3 minutes" : ""}`
            checked: root.adapter?.discoverable ?? false
            onToggled: {
                if (!root.adapter)
                    return;
                root.adapter.discoverableTimeout = 180;
                root.adapter.discoverable = !root.adapter.discoverable;
            }
        }
    }

    // ---- paired devices ----
    Text {
        visible: root.btOn
        Layout.leftMargin: 4
        text: root.paired.length ? `My devices (${root.paired.length})` : "My devices"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Text {
        visible: root.btOn && root.paired.length === 0
        Layout.leftMargin: 4
        text: "No paired devices yet."
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        color: Theme.foregroundDim
    }

    Repeater {
        model: root.btOn ? root.paired : []

        Tile {
            id: devTile
            required property var modelData
            readonly property var d: modelData
            readonly property bool busy: d.state === BluetoothDeviceState.Connecting || d.state === BluetoothDeviceState.Disconnecting

            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                width: parent.width
                spacing: 10

                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: devTile.d.connected ? Theme.accent : Theme.surfaceHigh

                    Icon {
                        anchors.centerIn: parent
                        name: root.icon(devTile.d)
                        size: 18
                        color: devTile.d.connected ? Theme.background : Theme.foreground
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: root.name(devTile.d)
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            const parts = [devTile.busy ? (devTile.d.connected ? "Disconnecting…" : "Connecting…") : devTile.d.connected ? "Connected" : "Not connected"];
                            if (devTile.d.connected && devTile.d.batteryAvailable)
                                parts.push(`Battery ${root.battery(devTile.d)}%`);
                            if (devTile.d.blocked)
                                parts.push("Blocked");
                            return parts.join(" · ");
                        }
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: devTile.d.connected && devTile.d.batteryAvailable && root.battery(devTile.d) <= 15 ? Theme.urgent : Theme.foregroundDim
                    }
                }

                PillButton {
                    visible: !devTile.d.blocked
                    text: devTile.d.connected ? "Disconnect" : "Connect"
                    enabled: !devTile.busy
                    onClicked: devTile.d.connected ? devTile.d.disconnect() : devTile.d.connect()
                }
            }

            SwitchRow {
                icon: "autorenew"
                label: "Connect automatically"
                detail: "Trusted: reconnects when in range"
                checked: devTile.d.trusted
                onToggled: devTile.d.trusted = !devTile.d.trusted
            }

            SwitchRow {
                icon: "block"
                label: "Block"
                detail: "Refuse connections from it"
                checked: devTile.d.blocked
                onToggled: devTile.d.blocked = !devTile.d.blocked
            }

            RowLayout {
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    text: devTile.d.address
                    font.family: "monospace"
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }

                PillButton {
                    text: "Forget"
                    onClicked: devTile.d.forget()
                }
            }
        }
    }

    // ---- pair a new device ----
    RowLayout {
        visible: root.btOn
        Layout.fillWidth: true
        Layout.leftMargin: 4

        Text {
            Layout.fillWidth: true
            text: root.unnamedCount > 0 ? `Pair a new device · ${root.unnamedCount} unnamed nearby` : "Pair a new device"
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            font.weight: Font.DemiBold
            color: Theme.foregroundDim
        }

        // Scan / Stop.
        MouseArea {
            id: scanButton
            implicitWidth: scanRow.implicitWidth + 18
            implicitHeight: 26
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.setScanning(!root.scanning)

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: root.scanning ? Theme.accent : scanButton.containsMouse ? Theme.glassTileHover : Theme.glassTile
            }

            Row {
                id: scanRow
                anchors.centerIn: parent
                spacing: 5

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: root.scanning ? "progress_activity" : "radar"
                    size: 14
                    color: root.scanning ? Theme.background : Theme.foreground

                    RotationAnimation on rotation {
                        running: root.scanning
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.scanning ? "Stop" : "Scan"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Font.DemiBold
                    color: root.scanning ? Theme.background : Theme.foreground
                }
            }
        }
    }

    Tile {
        visible: root.btOn
        Layout.fillWidth: true
        spacing: 4

        Text {
            visible: root.nearby.length === 0
            width: parent.width
            wrapMode: Text.WordWrap
            text: root.scanning ? "Looking for devices… Put your device in pairing mode." : "Press Scan, and put the device in pairing mode."
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        Repeater {
            model: root.btOn ? root.nearby : []

            BluetoothItem {
                id: nearbyRow
                required property var modelData
                width: parent.width
                device: modelData
                paired: false
                label: root.realName(modelData)
                icon: root.icon(modelData)
                failed: root.failedAddress === modelData.address
                onClicked: if (!modelData.pairing)
                    root.pair(modelData)

                // Pairing ended without success -> show the failure.
                Connections {
                    target: nearbyRow.modelData
                    function onPairingChanged() {
                        if (!nearbyRow.modelData.pairing && !nearbyRow.modelData.paired) {
                            root.failedAddress = nearbyRow.modelData.address;
                            if (root.pendingAddress === nearbyRow.modelData.address)
                                root.pendingAddress = "";
                            clearFailed.restart();
                        }
                    }
                }
            }
        }
    }
}
