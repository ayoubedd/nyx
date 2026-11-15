pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery state + time estimates, shared by the bar and the Power tab.
//
// Estimates prefer UPower's own (smoothed) values; when UPower has none yet
// (e.g. right after plugging/unplugging) they fall back to
//   remaining energy / current discharge rate        (time left)
//   missing energy   / current charge rate           (time to full)
Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    // The composite display device may not report isLaptopBattery.
    readonly property bool present: (device?.isLaptopBattery || device?.isPresent) ?? false

    readonly property real percent: {
        const p = device?.percentage ?? 0;
        return p > 1 ? p / 100 : p;
    }
    readonly property int state: device?.state ?? UPowerDeviceState.Unknown
    readonly property bool charging: state === UPowerDeviceState.Charging
    readonly property bool full: state === UPowerDeviceState.FullyCharged
    // Plugged in but held (e.g. ThinkPad charge threshold).
    readonly property bool holding: state === UPowerDeviceState.PendingCharge
    readonly property bool discharging: state === UPowerDeviceState.Discharging || state === UPowerDeviceState.PendingDischarge
    readonly property bool low: discharging && percent <= 0.15

    readonly property real rate: Math.abs(device?.changeRate ?? 0) // W
    readonly property real energy: device?.energy ?? 0 // Wh
    readonly property real capacity: device?.energyCapacity ?? 0 // Wh

    // Seconds; 0 = unknown.
    readonly property real timeToEmpty: {
        if (!discharging)
            return 0;
        if ((device?.timeToEmpty ?? 0) > 0)
            return device.timeToEmpty;
        return rate > 0.1 ? energy / rate * 3600 : 0;
    }
    readonly property real timeToFull: {
        if (!charging)
            return 0;
        if ((device?.timeToFull ?? 0) > 0)
            return device.timeToFull;
        return rate > 0.1 && capacity > energy ? (capacity - energy) / rate * 3600 : 0;
    }

    function duration(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return h > 0 ? `${h}h ${String(m).padStart(2, "0")}m` : `${m}m`;
    }

    // Short estimate for the bar, e.g. "2h 10m" / "45m to full".
    readonly property string shortEstimate: {
        if (charging && timeToFull > 0)
            return `${duration(timeToFull)} to full`;
        if (discharging && timeToEmpty > 0)
            return duration(timeToEmpty);
        return "";
    }

    // Full sentence for the Power tab.
    readonly property string status: {
        if (full)
            return "Fully charged";
        if (charging)
            return timeToFull > 0 ? `Charging · ${duration(timeToFull)} until full` : "Charging · estimating…";
        if (holding)
            return "Plugged in · not charging";
        if (discharging)
            return timeToEmpty > 0 ? `On battery · ${duration(timeToEmpty)} left` : "On battery · estimating…";
        return UPower.onBattery ? "On battery" : "Plugged in";
    }

    readonly property string icon: {
        if (charging)
            return "battery_charging_full";
        if (full || holding && percent >= 0.95)
            return "battery_full";
        if (low)
            return "battery_alert";
        return `battery_${Math.max(0, Math.min(6, Math.round(percent * 6)))}_bar`;
    }

    readonly property color color: charging || full ? Theme.success : low ? Theme.urgent : Theme.foreground

    // ---- low battery warnings --------------------------------------------
    // One notification per threshold per discharge; plugging in re-arms them.
    // At `suspendAt` the machine suspends after a 60s grace period unless the
    // charger is connected. This runs before UPower's own critical action
    // (2%, which is a power-off here: HybridSleep needs swap and there is none).
    readonly property int warnLow: 15
    readonly property int warnCritical: 5
    readonly property int suspendAt: 3 // 0 = never suspend

    property int warned: 100 // lowest threshold already notified this discharge
    property bool suspendPending: false
    readonly property int percentInt: Math.round(percent * 100)

    // Through the session's notification server (quickshell's own Notifs.qml).
    // urgency: 0 low, 1 normal, 2 critical (critical shows even with DND on).
    function notify(summary, body, urgency, icon) {
        Quickshell.execDetached(["busctl", "--user", "call", "org.freedesktop.Notifications", "/org/freedesktop/Notifications", "org.freedesktop.Notifications", "Notify", "susssasa{sv}i", "Battery", "0", icon, summary, body, "0", "1", "urgency", "y", String(urgency), "-1"]);
    }

    function checkLevel() {
        if (!present || percentInt <= 0)
            return;
        if (!discharging) {
            warned = 100;
            if (suspendPending) {
                suspendPending = false;
                suspendTimer.stop();
                notify("Suspend cancelled", "Charger connected.", 1, "battery-good-charging");
            }
            return;
        }

        const left = shortEstimate ? ` (about ${shortEstimate})` : "";
        if (percentInt <= warnCritical && warned > warnCritical) {
            warned = warnCritical;
            notify("Battery critically low", `${percentInt}% remaining${left}. Plug in now.`, 2, "battery-caution");
        } else if (percentInt <= warnLow && warned > warnLow) {
            warned = warnLow;
            notify("Battery low", `${percentInt}% remaining${left}.`, 1, "battery-low");
        }

        if (suspendAt > 0 && percentInt <= suspendAt && !suspendPending) {
            suspendPending = true;
            suspendTimer.restart();
            notify("Suspending in 60 seconds", `Battery at ${percentInt}%. Plug in the charger to cancel.`, 2, "battery-empty");
        }
    }

    onPercentIntChanged: checkLevel()
    onDischargingChanged: checkLevel()
    Component.onCompleted: checkLevel()

    Timer {
        id: suspendTimer
        interval: 60000
        onTriggered: {
            root.suspendPending = false;
            if (root.discharging && root.percentInt <= root.suspendAt)
                Quickshell.execDetached(["systemctl", "suspend"]);
        }
    }
}
