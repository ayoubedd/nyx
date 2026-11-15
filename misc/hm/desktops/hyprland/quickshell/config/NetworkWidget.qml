import QtQuick
import Quickshell
import Quickshell.Networking

BarButton {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevices: Networking.devices.values.filter(d => d.type === DeviceType.Wired && d.nmManaged)
    readonly property var wired: wiredDevices.find(d => d.connected) ?? null
    readonly property var current: wifi?.networks.values.find(n => n.connected) ?? null

    function strength(net) {
        const s = net?.signalStrength ?? 0;
        return s > 1 ? s / 100 : s;
    }

    function signalIcon(net) {
        const s = strength(net);
        return s > 0.66 ? "wifi" : s > 0.33 ? "wifi_2_bar" : "wifi_1_bar";
    }

    icon: wired ? "lan" : !Networking.wifiEnabled ? "wifi_off" : current ? signalIcon(current) : "signal_wifi_bad"
    iconColor: wired || current ? Theme.foreground : Theme.foregroundDim
    active: menu.shown
    tooltip: {
        if (wired) {
            const mbps = wired.linkSpeed ?? 0;
            const speed = mbps > 0 ? ` · ${mbps >= 1000 ? `${mbps / 1000} Gb/s` : `${mbps} Mb/s`}` : "";
            return `Ethernet: ${wired.network?.name || wired.name}${speed}`;
        }
        if (!Networking.wifiEnabled)
            return "Wi-Fi: off";
        if (!current)
            return "Wi-Fi: not connected";
        return `Wi-Fi: ${current.name} · ${Math.round(strength(current) * 100)}%`;
    }
    onClicked: menu.toggle()

    Dropdown {
        id: menu
        target: root
        contentWidth: 300

        // Only scan while the list is on screen.
        onVisibleChanged: if (root.wifi)
            root.wifi.scannerEnabled = visible

        // Ethernet section, only when there is a wired adapter.
        DropdownHeader {
            visible: root.wiredDevices.length > 0
            title: "Ethernet"
            showToggle: false
        }

        Repeater {
            model: root.wiredDevices

            WiredItem {
                required property var modelData
                device: modelData
            }
        }

        Separator {
            visible: root.wiredDevices.length > 0
        }

        DropdownHeader {
            title: "Wi-Fi"
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        Repeater {
            model: {
                if (!Networking.wifiEnabled || !root.wifi)
                    return [];
                const seen = new Set();
                return root.wifi.networks.values.filter(n => n.name && !seen.has(n.name) && seen.add(n.name)).sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (root.strength(b) - root.strength(a))).slice(0, 8);
            }

            NetworkItem {
                required property var modelData
                network: modelData
                signalIcon: root.signalIcon(modelData)
            }
        }

        Separator {}

        MenuItem {
            icon: "settings"
            label: "Network settings"
            tint: Theme.foregroundDim
            onClicked: {
                menu.shown = false;
                Quickshell.execDetached(["nm-connection-editor"]);
            }
        }
    }
}
