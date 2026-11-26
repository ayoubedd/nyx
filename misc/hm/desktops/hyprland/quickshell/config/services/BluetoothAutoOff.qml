pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower

// Battery saver for the Bluetooth radio: on battery, once nothing has been
// connected for 15 minutes, the radio is switched off. It comes back on by
// itself when the Bluetooth menu or panel is opened (wake()) or when the
// charger is plugged in. Turning it off by hand isn't touched (only a
// radio this switched off is switched back on).
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool anyConnected: (adapter?.devices.values ?? []).some(d => d.connected)
    readonly property bool onBattery: UPower.onBattery
    readonly property int idleMinutes: 15

    // The radio is off because of this (so it may switch it back on).
    property bool autoOff: false

    readonly property bool idle: onBattery && enabled && !anyConnected

    function wake() {
        if (autoOff && adapter && !adapter.enabled)
            adapter.enabled = true;
        autoOff = false;
        if (idle)
            idleTimer.restart(); // a fresh 15 min from opening the menu
    }

    onIdleChanged: idle ? idleTimer.restart() : idleTimer.stop()
    Component.onCompleted: if (idle)
        idleTimer.start()

    // Turned on by hand (or anything else) meanwhile: no longer ours.
    onEnabledChanged: if (enabled)
        autoOff = false
    onOnBatteryChanged: if (!onBattery && autoOff)
        wake()

    Timer {
        id: idleTimer
        interval: root.idleMinutes * 60000
        onTriggered: if (root.idle && root.adapter) {
            root.adapter.enabled = false;
            root.autoOff = true;
        }
    }
}
