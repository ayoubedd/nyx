import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.common
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
    iconColor: enabled ? Theme.foreground : Theme.foregroundDim
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
        contentWidth: 300

        onShownChanged: if (!shown && root.scanning)
            root.setScanning(false)

        DropdownHeader {
            title: "Bluetooth"
            checked: root.enabled
            onToggled: if (root.adapter)
                root.adapter.enabled = !root.adapter.enabled
        }

        // ---- My devices ----
        Repeater {
            model: root.enabled ? root.paired : []

            MouseArea {
                id: row
                required property var modelData
                readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
                readonly property real battery: modelData.battery > 1 ? modelData.battery / 100 : modelData.battery

                width: parent.width
                implicitHeight: 36
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius - 4
                    color: row.containsMouse ? Theme.surface : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 6
                    spacing: 12

                    Icon {
                        name: root.deviceIcon(row.modelData)
                        filled: row.modelData.connected
                        color: row.modelData.connected ? Theme.accent : Theme.foreground
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.label(row.modelData)
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        color: Theme.foreground
                    }

                    Text {
                        visible: text !== "" && !forget.visible
                        text: row.busy ? "…" : row.modelData.connected && row.modelData.batteryAvailable ? `${Math.round(row.battery * 100)}%` : ""
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    // Forget (unpair), on hover.
                    PillButton {
                        id: forget
                        visible: row.containsMouse || containsMouse
                        icon: "close"
                        onClicked: row.modelData.forget()
                    }
                }
            }
        }

        // ---- Other devices ----
        Separator {
            visible: root.enabled
        }

        RowLayout {
            visible: root.enabled
            width: parent.width
            height: 36

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                // Nameless devices aren't listed; their count lives here so it
                // doesn't add a line.
                text: root.unnamedCount > 0 ? `Other devices · ${root.unnamedCount} unnamed` : "Other devices"
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foregroundDim
            }

            // Scan / Stop.
            MouseArea {
                Layout.rightMargin: 6
                implicitWidth: scanRow.implicitWidth + 18
                implicitHeight: 26
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setScanning(!root.scanning)

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: root.scanning ? Theme.accent : parent.containsMouse ? Theme.surfaceHigh : Theme.surface
                }

                Row {
                    id: scanRow
                    anchors.centerIn: parent
                    spacing: 5

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: root.scanning ? "progress_activity" : "radar"
                        size: 15
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

        // Discovered devices: a fixed-height scrolling list, so the menu
        // doesn't change size (and jump around) as devices are found.
        // ScriptModel keeps rows for devices already listed; new ones are
        // appended (discovery order, no re-sorting).
        Item {
            visible: root.enabled
            width: parent.width
            height: 5 * 36

            ListView {
                id: found
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: ScriptModel {
                    values: root.enabled ? root.nearby : []
                }

                delegate: MenuItem {
                    id: row
                    required property var modelData

                    width: found.width
                    icon: root.deviceIcon(modelData)
                    label: root.label(modelData)
                    detail: modelData.pairing ? "Pairing…" : root.failedAddress === modelData.address ? "Pairing failed" : "Pair"
                    onClicked: if (!modelData.pairing)
                        root.pair(modelData)

                    // Pairing ended without success -> show the failure.
                    // (Success is handled by root.onPairedChanged.)
                    Connections {
                        target: row.modelData
                        function onPairingChanged() {
                            if (!row.modelData.pairing && !row.modelData.paired) {
                                root.failedAddress = row.modelData.address;
                                if (root.pendingAddress === row.modelData.address)
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
                anchors.rightMargin: 1
                y: found.height * found.visibleArea.yPosition
                width: 3
                height: Math.max(16, found.height * found.visibleArea.heightRatio)
                radius: 1.5
                color: Theme.muted
            }

            // Placeholder inside the same area (no height change).
            Text {
                visible: found.count === 0
                anchors.centerIn: parent
                text: root.scanning ? "Looking for devices…" : "Scan to find devices nearby"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }
        }

        Separator {}

        MenuItem {
            icon: "settings"
            label: "Bluetooth settings"
            tint: Theme.foregroundDim
            onClicked: {
                menu.shown = false;
                Quickshell.execDetached(["blueman-manager"]);
            }
        }
    }
}
