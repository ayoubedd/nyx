import QtQuick
import Quickshell.Networking

// An Ethernet adapter row: click to connect/disconnect its profile.
MenuItem {
    id: root

    required property var device

    readonly property bool busy: device.state === ConnectionState.Connecting || device.state === ConnectionState.Disconnecting

    function speed(mbps) {
        if (!mbps || mbps <= 0)
            return "";
        return mbps >= 1000 ? `${mbps / 1000} Gb/s` : `${mbps} Mb/s`;
    }

    icon: "lan"
    label: device.network?.name || device.name
    highlighted: device.connected
    tint: device.hasLink ? Theme.foreground : Theme.foregroundDim
    detail: busy ? "…" : device.connected ? (speed(device.linkSpeed) || "Connected") : device.hasLink ? "Disconnected" : "Unplugged"
    enabled: device.hasLink || device.connected
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onClicked: {
        if (device.connected)
            device.disconnect();
        else
            device.network?.connect();
    }
}
