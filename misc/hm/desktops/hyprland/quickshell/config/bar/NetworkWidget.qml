import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import qs.common
import qs.services
import qs.components

// Bar network icon + menu (cards, like the sound menu):
//   Wi-Fi                                   [switch]
//   (wifi)  Home network                 Disconnect
//           Connected · Strong · WPA2
//   Other networks                            ⟳
//   (wifi)  Neighbour                          🔒
//   …
//   Ethernet (only with a wired adapter)
//   Network settings
BarButton {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevices: Networking.devices.values.filter(d => d.type === DeviceType.Wired && d.nmManaged)
    readonly property var wired: wiredDevices.find(d => d.connected) ?? null
    readonly property var current: wifi?.networks.values.find(n => n.connected) ?? null
    readonly property bool limited: Networking.connectivity === NetworkConnectivity.Limited || Networking.connectivity === NetworkConnectivity.Portal

    // Visible networks except the connected one: one entry per name, saved
    // first, then by signal.
    readonly property var others: {
        if (!Networking.wifiEnabled || !wifi)
            return [];
        const seen = new Set();
        return wifi.networks.values.filter(n => n.name && !n.connected && !seen.has(n.name) && seen.add(n.name)).sort((a, b) => (b.known - a.known) || (strength(b) - strength(a)));
    }

    function strength(net) {
        const s = net?.signalStrength ?? 0;
        return s > 1 ? s / 100 : s;
    }

    function signalIcon(net) {
        const s = strength(net);
        return s > 0.66 ? "wifi" : s > 0.33 ? "wifi_2_bar" : "wifi_1_bar";
    }

    function signalName(net) {
        const s = strength(net);
        return s > 0.66 ? "Strong" : s > 0.33 ? "Good" : "Weak";
    }

    icon: wired ? "lan" : !Networking.wifiEnabled ? "wifi_off" : current ? signalIcon(current) : "signal_wifi_bad"
    iconColor: wired || current ? Theme.foreground : Theme.foregroundDim
    active: menu.shown
    // Metered connection (phone hotspot): background downloads are paused.
    badge: Metered.metered
    tooltip: {
        const metered = Metered.metered ? " · Metered (background downloads paused)" : "";
        if (wired) {
            const mbps = wired.linkSpeed ?? 0;
            const speed = mbps > 0 ? ` · ${mbps >= 1000 ? `${mbps / 1000} Gb/s` : `${mbps} Mb/s`}` : "";
            return `Ethernet: ${wired.network?.name || wired.name}${speed}${metered}`;
        }
        if (!Networking.wifiEnabled)
            return "Wi-Fi: off";
        if (!current)
            return "Wi-Fi: not connected";
        return `Wi-Fi: ${current.name} · ${Math.round(strength(current) * 100)}%${metered}`;
    }
    onClicked: menu.toggle()

    // qs -c nyx ipc call bar toggle network
    Connections {
        target: Ui
        function onMenuRequested(name, screen) {
            if (name === "network" && (root.QsWindow.window?.screen?.name ?? "") === screen)
                menu.toggle();
        }
    }

    Dropdown {
        id: menu
        target: root
        contentWidth: 340
        contentSpacing: 8

        // Only scan while the list is on screen.
        onVisibleChanged: if (root.wifi)
            root.wifi.scannerEnabled = visible

        // ---- Wi-Fi ----
        Card {
            id: wifiColumn

            RowLayout {
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    text: "Wi-Fi"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Toggle {
                    checked: Networking.wifiEnabled
                    onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                }
            }

            Text {
                visible: !Networking.wifiEnabled || !root.wifi
                width: parent.width
                text: !root.wifi ? "No Wi-Fi adapter" : !Networking.wifiHardwareEnabled ? "Blocked by the hardware switch" : "Wi-Fi is off"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            // Current network.
            MouseArea {
                id: currentRow
                visible: !!root.current
                width: parent.width
                implicitHeight: 44
                hoverEnabled: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Rectangle {
                        implicitWidth: 34
                        implicitHeight: 34
                        radius: 17
                        color: root.limited ? Theme.urgent : Theme.accent

                        Icon {
                            anchors.centerIn: parent
                            name: root.signalIcon(root.current)
                            filled: true
                            size: 18
                            color: Theme.background
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: root.current?.name ?? ""
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: Font.DemiBold
                            color: Theme.foreground
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.current?.stateChanging ? "Disconnecting…" : [root.limited ? "No internet" : "Connected", root.signalName(root.current)].join(" · ")
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 3
                            color: root.limited ? Theme.urgent : Theme.foregroundDim
                        }
                    }

                    PillButton {
                        id: disconnectButton
                        text: "Disconnect"
                        opacity: currentRow.containsMouse || containsMouse ? 1 : 0
                        onClicked: root.current?.disconnect()

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.animDuration
                            }
                        }
                    }
                }
            }

            // Other networks.
            RowLayout {
                visible: Networking.wifiEnabled && !!root.wifi
                width: parent.width

                Text {
                    Layout.fillWidth: true
                    text: root.current ? "Other networks" : "Networks"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    font.weight: Font.DemiBold
                    color: Theme.foregroundDim
                }

                Icon {
                    name: "progress_activity"
                    size: 14
                    color: Theme.foregroundDim
                    visible: root.wifi?.scannerEnabled ?? false

                    RotationAnimation on rotation {
                        running: menu.shown
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1200
                    }
                }
            }

            Text {
                visible: Networking.wifiEnabled && !!root.wifi && root.others.length === 0
                text: "Searching…"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            // Fixed max height + scrolling, so networks appearing during a
            // scan don't keep resizing the menu.
            ListView {
                id: list
                visible: root.others.length > 0
                width: parent.width
                height: Math.min(contentHeight, 5 * 44)
                spacing: 4
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: ScriptModel {
                    values: root.others
                }

                delegate: NetworkItem {
                    required property var modelData
                    width: list.width
                    network: modelData
                    signalIcon: root.signalIcon(modelData)
                }
            }
        }

        // ---- Ethernet ----
        Card {
            id: wiredColumn
            visible: root.wiredDevices.length > 0
            spacing: 6

            Text {
                text: "Ethernet"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Repeater {
                model: root.wiredDevices

                WiredItem {
                    required property var modelData
                    device: modelData
                    width: wiredColumn.contentWidth
                }
            }
        }

        MenuItem {
            icon: "settings"
            label: "Network settings"
            onClicked: {
                menu.shown = false;
                Quickshell.execDetached(["nm-connection-editor"]);
            }
        }
    }
}
