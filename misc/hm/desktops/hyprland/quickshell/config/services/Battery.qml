pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.common

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
    // ---- low-battery ladder ------------------------------------------------
    // Once per discharge each (plugging in re-arms them):
    //   20%  warning, with a "Power saver" button (unless it's already on);
    //   10%  switches to Power saver by itself (x1-power-profile switches
    //        back to the automatic profile when the charger is plugged in);
    //    5%  critical: locks now and suspends after a 60 s grace period
    //        unless the charger is connected.
    // This runs before UPower's own critical action (2%, a power-off here:
    // HybridSleep needs swap and there is none).
    readonly property int offerSaverAt: 20
    readonly property int autoSaverAt: 10
    readonly property int suspendAt: 5
    readonly property string saverProfile: "x1-powersave"

    property int warned: 100 // lowest threshold already handled this discharge
    property bool suspendPending: false
    readonly property int percentInt: Math.round(percent * 100)

    // urgency: "low" | "normal" | "critical" (critical shows even with DND on).
    function notify(summary, body, urgency, icon) {
        Notifier.send("Battery", summary, body, {
            urgency: urgency,
            icon: icon
        });
    }

    function checkLevel() {
        if (!present || percentInt <= 0)
            return;
        if (!discharging) {
            warned = 100;
            if (suspendPending) {
                suspendPending = false;
                suspendTimer.stop();
                notify("Suspend cancelled", "Charger connected.", "normal", "battery-good-charging");
            }
            return;
        }

        const left = shortEstimate ? ` About ${shortEstimate} left.` : "";
        if (percentInt <= suspendAt && warned > suspendAt) {
            warned = suspendAt;
            suspendPending = true;
            suspendTimer.restart();
            notify("Battery critically low", `${percentInt}% remaining. Locking now and suspending in 60 seconds; plug in the charger to cancel.`, "critical", "battery-empty");
            Quickshell.execDetached(["loginctl", "lock-session"]);
        } else if (percentInt <= autoSaverAt && warned > autoSaverAt) {
            warned = autoSaverAt;
            const switching = TunedProfiles.current !== saverProfile;
            if (switching)
                TunedProfiles.set(saverProfile);
            notify("Battery low", `${percentInt}% remaining.${left}${switching ? " Switched to Power saver." : ""}`, "critical", "battery-caution");
        } else if (percentInt <= offerSaverAt && warned > offerSaverAt) {
            warned = offerSaverAt;
            if (TunedProfiles.current === saverProfile)
                notify("Battery at " + percentInt + "%", left.trim(), "normal", "battery-low");
            else
                Notifier.ask("Battery", `Battery at ${percentInt}%`, `${left.trim()} Power saver makes it last longer.`.trim(), {
                    icon: "battery-low"
                }, {
                    powersave: "Power saver"
                }, () => TunedProfiles.set(saverProfile));
        }
    }

    onPercentIntChanged: {
        checkLevel();
        checkLimit();
    }
    onDischargingChanged: checkLevel()
    Component.onCompleted: {
        chargedThisPlug = charging;
        startupCheck.start();
    }

    // At login / shell start, check once the shell is up: right away the
    // notification server and popups may not be ready yet, and the warning
    // ended up in the center without popping up.
    Timer {
        id: startupCheck
        interval: 4000
        onTriggered: root.checkLevel()
    }

    Timer {
        id: suspendTimer
        interval: 60000
        onTriggered: {
            root.suspendPending = false;
            if (root.discharging && root.percentInt <= root.suspendAt) {
                // Re-arm: woken up still on battery, the next percent drop
                // locks and suspends again (instead of running down to
                // UPower's 2% power-off).
                root.warned = root.suspendAt + 1;
                Quickshell.execDetached(["systemctl", "suspend"]);
            }
        }
    }

    // ---- on the charger ------------------------------------------------------
    // "Charged to 80% — fine to unplug" once the charge limit is reached
    // (only if it actually charged up to it while plugged in), and a warning
    // when the charger is too weak to charge at full speed.
    readonly property bool onAc: !UPower.onBattery
    readonly property int fullSpeedWatts: 65 // the X1's own charger
    readonly property int slowBelowWatts: 45

    // ThinkPad charge_control_end_threshold (set by tuned / x1-charge-*).
    // The one reader of it: the bar's battery menu uses chargeLimit too.
    FileView {
        id: limitFile
        path: "/sys/class/power_supply/BAT0/charge_control_end_threshold"
        printErrors: false
    }
    readonly property int chargeLimit: parseInt(limitFile.text()) || 0
    // "Charge to full once" is on while the end threshold is lifted to 100.
    readonly property bool fullOnce: chargeLimit === 100

    // sysfs sends no change events: re-read on demand.
    function reloadLimit() {
        limitFile.reload();
    }

    function setFullOnce(on) {
        Quickshell.execDetached(["systemctl", "start", on ? "x1-charge-full.service" : "x1-charge-limit.service"]);
        limitReload.restart();
    }

    // Re-read the threshold once the unit has run (or x1-charge-limit has
    // reset "full once" after an unplug).
    Timer {
        id: limitReload
        interval: 800
        onTriggered: limitFile.reload()
    }

    property bool chargedThisPlug: false
    property bool limitNotified: false

    onChargingChanged: if (charging)
        chargedThisPlug = true

    function checkLimit() {
        if (!onAc || limitNotified || !chargedThisPlug || chargeLimit <= 0 || chargeLimit >= 100)
            return;
        if (percentInt >= chargeLimit - 1 && !charging) {
            limitNotified = true;
            notify(`Charged to ${percentInt}%`, `The battery is held at its ${chargeLimit}% limit to last longer. Fine to unplug.`, "low", "battery-full-charging");
        }
    }
    onHoldingChanged: checkLimit()
    onChargeLimitChanged: checkLimit()
    onFullChanged: checkLimit()

    onOnAcChanged: {
        chargedThisPlug = charging;
        limitNotified = false;
        limitFile.reload();
        limitReload.restart();
        if (onAc)
            chargerCheck.restart();
    }

    // USB-C PD negotiates the power a moment after plugging in.
    Timer {
        id: chargerCheck
        interval: 4000
        onTriggered: if (root.onAc)
            chargerWatts.running = true
    }

    // Maximum power of the connected USB-C source: voltage_max x current_max.
    Process {
        id: chargerWatts
        command: ["sh", "-c", "for d in /sys/class/power_supply/ucsi-source-psy-*; do [ \"$(cat \"$d/online\" 2>/dev/null)\" = 1 ] || continue; v=$(cat \"$d/voltage_max\"); i=$(cat \"$d/current_max\"); echo $(( v / 1000 * (i / 1000) / 1000000 )); done"]
        stdout: SplitParser {
            onRead: line => {
                const w = parseInt(line);
                if (w > 0 && w < root.slowBelowWatts)
                    root.notify(`Charging slowly — ${w} W charger`, `This laptop charges at full speed with ${root.fullSpeedWatts} W. Under load the battery may still drain.`, "normal", "battery-caution-charging");
            }
        }
    }
}
