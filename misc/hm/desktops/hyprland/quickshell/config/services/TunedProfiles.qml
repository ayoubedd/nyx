pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// tuned power profiles (machines/x1/power.nix), shared by the battery menu,
// the dashboard Power tab and the launcher.
//
// "Automatic" = the profile x1-power-profile picks for the power source
// (AC -> x1-balanced, battery -> x1-battery-balanced). It switches on every
// plug/unplug; picking a profile by hand lasts until the next one.
// Switching goes through `tuned-adm`, which polkit allows for active sessions
// without a password.
Singleton {
    id: root

    readonly property var profiles: [
        {
            id: "x1-powersave",
            icon: "eco",
            label: "Power saver",
            detail: "Lowest power, quiet"
        },
        {
            id: "x1-battery-balanced",
            icon: "battery_5_bar",
            label: "Battery balanced",
            detail: "Balanced, tuned for battery"
        },
        {
            id: "x1-balanced",
            icon: "balance",
            label: "Balanced",
            detail: "Everyday default"
        },
        {
            id: "x1-performance",
            icon: "speed",
            label: "Performance",
            detail: "Max speed, more heat"
        }
    ]

    property string current: "" // active tuned profile ("" = unknown yet)
    readonly property string autoProfile: UPower.onBattery ? "x1-battery-balanced" : "x1-balanced"
    readonly property bool automatic: current !== "" && current === autoProfile
    readonly property var currentInfo: profiles.find(p => p.id === current) ?? null

    function label(id) {
        return profiles.find(p => p.id === id)?.label ?? id;
    }

    function set(id) {
        if (!id)
            return;
        current = id; // optimistic
        setProc.command = ["tuned-adm", "profile", id];
        setProc.running = true;
    }

    // Back to the automatic choice for the current power source.
    function setAutomatic() {
        set(autoProfile);
    }

    function refresh() {
        if (!readProc.running)
            readProc.running = true;
    }

    // Switches made elsewhere arrive as tuned's profile_changed D-Bus signal
    // (overlays/Osd.qml calls refresh() on it), so there's no polling. Views
    // still call watch(true) when they open, to re-read once just in case.
    function watch(on) {
        if (on)
            refresh();
    }

    Component.onCompleted: refresh()

    // x1-power-profile switches right after a plug/unplug.
    Connections {
        target: UPower
        function onOnBatteryChanged() {
            afterAcChange.restart();
        }
    }

    Timer {
        id: afterAcChange
        interval: 2500
        onTriggered: root.refresh()
    }

    Process {
        id: readProc
        command: ["tuned-adm", "active"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/Current active profile:\s*(\S+)/);
                if (m)
                    root.current = m[1];
            }
        }
    }

    Process {
        id: setProc
        onExited: root.refresh()
    }
}
