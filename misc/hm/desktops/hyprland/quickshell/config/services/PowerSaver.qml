import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.common

// Session-side battery saving while on battery:
//   - Hyprland animations off
//   - lighter blur (2 passes instead of 4) on the translucent overlays
// (The system-wide tuned profile is switched by x1-power-profile,
// machines/x1/power.nix.)
//
// Applied at startup, on every AC change, and again after Hyprland reloads
// its config (a reload resets options set at runtime).
Scope {
    id: root

    readonly property bool onBattery: UPower.onBattery

    // Quickshell's own animations (menus, popups, sliders, OSD…) are off
    // on battery and with the Power saver profile (Theme.ms() returns 0).
    readonly property bool reduceMotion: onBattery || TunedProfiles.current === "x1-powersave"
    onReduceMotionChanged: Theme.reduceMotion = reduceMotion

    // Plugged-in values: keep in sync with hypr/common.lua (decoration.blur).
    readonly property int blurPassesAc: 4
    readonly property int blurPassesBattery: 2

    property real lastApply: 0

    function apply() {
        lastApply = Date.now();
        const passes = onBattery ? blurPassesBattery : blurPassesAc;
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({ animations = { enabled = ${!onBattery} }, decoration = { blur = { passes = ${passes} } } })`]);
    }

    onOnBatteryChanged: apply()
    Component.onCompleted: {
        Theme.reduceMotion = reduceMotion;
        apply();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // Ignore the reload event our own change may cause.
            if (event.name === "configreloaded" && root.onBattery && Date.now() - root.lastApply > 2000)
                root.apply();
        }
    }
}
