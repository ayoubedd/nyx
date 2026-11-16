import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.common
import qs.services
import qs.components

// Bar Bluetooth icon + menu.
//   My devices     paired devices: click = connect/disconnect, hover ✕ = forget
//   Other devices  "Scan" discovers nearby devices; click one to pair, then it
//                  is trusted (auto-reconnect) and connected.
// Scanning stops when the menu closes, after 60s, or when Bluetooth turns off.
//
// Note: quickshell registers no BlueZ pairing agent, so devices that need a
// PIN / passkey confirmation (phones, some keyboards) may fail to pair here;
// "Just Works" devices (headphones, speakers, mice, controllers) are fine.
BarButton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var devices: adapter?.devices.values ?? []
    readonly property bool anyConnected: devices.some(d => d.connected)
    readonly property bool scanning: adapter?.discovering ?? false

    readonly property var paired: devices.filter(d => d.paired || d.bonded).sort((a, b) => b.connected - a.connected)
    // Nearby, not yet paired, with a real name. Devices that don't advertise
    // one (mostly BLE beacons/gadgets) are only counted; names often arrive a
    // few seconds into a scan, and they then show up here.
    readonly property var unpaired: devices.filter(d => !d.paired && !d.bonded)
    // Discovery order (no sorting), so new devices are appended instead of
    // reshuffling the list.
    readonly property var nearby: unpaired.filter(d => realName(d) !== "")
    readonly property int unnamedCount: unpaired.filter(d => realName(d) === "").length

    // Address of a device whose pairing just failed (shown for a few seconds).
    property string failedAddress: ""

    // BlueZ sets a nameless device's alias to its address ("AA-BB-CC-…"),
    // so an "address-looking" name isn't a name.
    function looksLikeAddress(s) {
        return /^([0-9a-f]{2}[-:_]){5}[0-9a-f]{2}$/i.test(s || "");
    }

    // Advertised name first, then the alias, ignoring address placeholders.
    function realName(d) {
        for (const n of [d.deviceName, d.name])
            if (n && !looksLikeAddress(n))
                return n;
        return "";
    }

    function label(d) {
        return realName(d) || d.address;
    }

    function deviceIcon(d) {
        const i = d.icon || "";
        return i.startsWith("audio-head") ? "headphones" : i.startsWith("audio") ? "speaker" : i.startsWith("input-mouse") ? "mouse" : i.startsWith("input-keyboard") ? "keyboard" : i.startsWith("input-gaming") ? "sports_esports" : i.startsWith("phone") ? "smartphone" : i.startsWith("computer") ? "computer" : "bluetooth";
    }

    function setScanning(on) {
        if (!adapter || !enabled)
            return;
        adapter.discovering = on;
        if (on)
            scanTimeout.restart();
        else
            scanTimeout.stop();
    }

    // Device being paired from this menu. Trusting + connecting it happens
    // here (not in its row): on success it moves from "Other devices" to "My
    // devices", which destroys the row that started the pairing.
    property string pendingAddress: ""

    function pair(d) {
        failedAddress = "";
        pendingAddress = d.address;
        if (d.connected) {
            // Connected but never bonded (e.g. a pairing that ran without an
            // agent): BlueZ refuses to pair while connected ("already
            // connected"), so drop the link first, then pair.
            d.disconnect();
            pairAfterDisconnect.device = d;
            pairAfterDisconnect.restart();
        } else {
            d.pair();
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

    onPairedChanged: {
        if (!pendingAddress)
            return;
        const d = paired.find(x => x.address === pendingAddress);
        if (d) {
            pendingAddress = "";
            d.trusted = true; // auto-reconnect in the future
            d.connect();
        }
    }

    icon: !enabled ? "bluetooth_disabled" : anyConnected ? "bluetooth_connected" : "bluetooth"
    // A connected device low on battery: red icon + its level.
    readonly property bool deviceLow: BluetoothBattery.low.length > 0
    iconColor: deviceLow ? Theme.urgent : enabled ? Theme.foreground : Theme.foregroundDim
    label: deviceLow ? `${BluetoothBattery.percent(BluetoothBattery.lowest)}%` : ""
    labelColor: Theme.urgent
    active: menu.shown
    tooltip: {
        if (!adapter)
            return "Bluetooth: unavailable";
        if (!enabled)
            return "Bluetooth: off";
        const connected = devices.filter(d => d.connected).map(d => {
            const b = d.battery > 1 ? d.battery / 100 : d.battery;
            return d.batteryAvailable ? `${root.label(d)} (${Math.round(b * 100)}%)` : root.label(d);
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

    onEnabledChanged: if (!enabled)
        scanTimeout.stop()

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

    Dropdown {
        id: menu
        target: root
        contentWidth: 340
        contentSpacing: 8

        onShownChanged: if (!shown && root.scanning)
            root.setScanning(false)

        // ---- Bluetooth: switch + my devices ----
        Rectangle {
            width: parent.width
            implicitHeight: mineColumn.implicitHeight + 24
            radius: 14
            color: Theme.surface

            Column {
                id: mineColumn
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 10

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
                        checked: root.enabled
                        onToggled: if (root.adapter)
                            root.adapter.enabled = !root.adapter.enabled
                    }
                }

                Text {
                    visible: !root.enabled
                    text: !root.adapter ? "No Bluetooth adapter" : "Bluetooth is off"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }

                Text {
                    visible: root.enabled && root.paired.length > 0
                    text: "My devices"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    font.weight: Font.DemiBold
                    color: Theme.foregroundDim
                }

                Column {
                    visible: root.enabled && root.paired.length > 0
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: root.enabled ? root.paired : []

                        BluetoothItem {
                            required property var modelData
                            width: mineColumn.width
                            device: modelData
                            label: root.label(modelData)
                            icon: root.deviceIcon(modelData)
                            onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                        }
                    }
                }
            }
        }

        // ---- Other devices (pairing) ----
        Rectangle {
            visible: root.enabled
            width: parent.width
            implicitHeight: otherColumn.implicitHeight + 24
            radius: 14
            color: Theme.surface

            Column {
                id: otherColumn
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 8

                RowLayout {
                    width: parent.width

                    Text {
                        Layout.fillWidth: true
                        // Nameless devices aren't listed; their count lives here.
                        text: root.unnamedCount > 0 ? `Other devices · ${root.unnamedCount} unnamed` : "Other devices"
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    // Scan / Stop.
                    MouseArea {
                        id: scanButton
                        implicitWidth: scanRow.implicitWidth + 18
                        implicitHeight: 24
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setScanning(!root.scanning)

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: root.scanning ? Theme.accent : scanButton.containsMouse ? Theme.muted : Theme.surfaceHigh

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animDuration
                                }
                            }
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

                // Fixed-height scrolling list, so the menu doesn't change size
                // (and jump around) as devices are found. ScriptModel keeps
                // rows for devices already listed; new ones are appended.
                Item {
                    width: parent.width
                    height: 4 * 44

                    ListView {
                        id: found
                        anchors.fill: parent
                        spacing: 4
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: ScriptModel {
                            values: root.enabled ? root.nearby : []
                        }

                        delegate: BluetoothItem {
                            id: nearbyRow
                            required property var modelData
                            width: found.width - 6
                            x: 6
                            device: modelData
                            paired: false
                            label: root.label(modelData)
                            icon: root.deviceIcon(modelData)
                            failed: root.failedAddress === modelData.address
                            onClicked: if (!modelData.pairing)
                                root.pair(modelData)

                            // Pairing ended without success -> show the failure.
                            // (Success is handled by root.onPairedChanged.)
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

                    // Thin scroll indicator when there's more than fits.
                    Rectangle {
                        visible: found.contentHeight > found.height
                        anchors.right: parent.right
                        y: found.height * found.visibleArea.yPosition
                        width: 3
                        height: Math.max(16, found.height * found.visibleArea.heightRatio)
                        radius: 1.5
                        color: Theme.muted
                    }

                    // Placeholder inside the same area (no height change).
                    Column {
                        visible: found.count === 0
                        anchors.centerIn: parent
                        spacing: 6

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: root.scanning ? "bluetooth_searching" : "radar"
                            size: 26
                            color: Theme.foregroundDim
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.scanning ? "Looking for devices…" : "Scan to find devices nearby"
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.foregroundDim
                        }
                    }
                }
            }
        }

        MenuItem {
            icon: "settings"
            label: "Bluetooth settings"
            onClicked: {
                menu.shown = false;
                Quickshell.execDetached(["blueman-manager"]);
            }
        }
    }
}
