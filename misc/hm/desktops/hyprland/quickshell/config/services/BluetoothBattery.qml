pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Battery levels of connected Bluetooth devices (headphones, mice,
// keyboards...) and low-battery warnings, like the laptop's (Battery.qml):
// one notification at 15% and one at 5% per device, re-armed once it is
// charged above 20% or reconnects.
//
// A singleton so a bar per monitor doesn't mean a warning per monitor.
Singleton {
    id: root

    readonly property int warnLow: 15
    readonly property int warnCritical: 5

    // Connected devices that report a battery level.
    readonly property var devices: (Bluetooth.defaultAdapter?.devices.values ?? []).filter(d => d.connected && d.batteryAvailable)

    function level(d) {
        const b = d?.battery ?? 0;
        return b > 1 ? b / 100 : b;
    }

    function percent(d) {
        return Math.round(level(d) * 100);
    }

    // Advertised name, ignoring BlueZ's address-shaped placeholder aliases.
    function name(d) {
        for (const n of [d.deviceName, d.name])
            if (n && !/^([0-9a-f]{2}[-:_]){5}[0-9a-f]{2}$/i.test(n))
                return n;
        return "Bluetooth device";
    }

    readonly property var low: devices.filter(d => percent(d) <= warnLow)
    // Lowest-battery device (for the bar label), or null.
    readonly property var lowest: devices.length ? devices.slice().sort((a, b) => level(a) - level(b))[0] : null

    // address -> lowest threshold already notified
    property var warned: ({})

    // Changes whenever any level or the device set changes.
    readonly property string snapshot: devices.map(d => `${d.address}=${percent(d)}`).join(",")
    onSnapshotChanged: check()

    function notify(summary, body, urgency) {
        Quickshell.execDetached(["busctl", "--user", "call", "org.freedesktop.Notifications", "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "Notify", "susssasa{sv}i", "Bluetooth", "0", "battery-low", summary, body, "0", "1", "urgency", "y", String(urgency), "-1"]);
    }

    function check() {
        const next = {};
        for (const d of devices) {
            const p = percent(d);
            if (p <= 0)
                continue; // not reported yet
            let w = warned[d.address] ?? 100;
            if (p > 20)
                w = 100;
            if (p <= warnCritical && w > warnCritical) {
                w = warnCritical;
                notify(`${name(d)} battery critically low`, `${p}% remaining. Charge it soon.`, 2);
            } else if (p <= warnLow && w > warnLow) {
                w = warnLow;
                notify(`${name(d)} battery low`, `${p}% remaining.`, 1);
            }
            next[d.address] = w;
        }
        // Disconnected devices drop out, so a reconnect warns again.
        warned = next;
    }
}
