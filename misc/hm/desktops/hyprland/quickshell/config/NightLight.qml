pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Night light via the running hyprsunset (services.hyprsunset in
// hyprland.nix), controlled through `hyprctl hyprsunset ...`.
//
// A manual change lasts until hyprsunset's next scheduled profile
// (21:00 -> 4000K, 07:30 -> off).
//
//   qs -c nyx ipc call nightlight toggle
Singleton {
    id: root

    readonly property int neutral: 6000 // K; hyprsunset's identity
    readonly property int warm: 4000 // K; "on" (matches the 21:00 profile)
    readonly property int warmest: 2500 // K; slider limit

    property int temperature: neutral
    readonly property bool on: temperature < neutral - 50

    // 0 (neutral) .. 1 (warmest), for the slider.
    readonly property real warmth: Math.max(0, Math.min(1, (neutral - temperature) / (neutral - warmest)))

    function setTemperature(k) {
        temperature = Math.round(Math.max(warmest, Math.min(neutral, k)) / 50) * 50;
        pending.restart();
    }

    function setWarmth(v) {
        setTemperature(neutral - v * (neutral - warmest));
    }

    function toggle() {
        setTemperature(on ? neutral : warm);
    }

    function refresh() {
        read.running = true;
    }

    // Coalesce slider drags into one hyprctl call per ~80ms.
    Timer {
        id: pending
        interval: 80
        onTriggered: {
            if (root.temperature >= root.neutral)
                Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
            else
                Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(root.temperature)]);
        }
    }

    Process {
        id: read
        command: ["hyprctl", "hyprsunset", "temperature"]
        // hyprctl prints the value without a trailing newline, so collect the
        // whole output (a SplitParser would never see a complete line).
        stdout: StdioCollector {
            onStreamFinished: {
                const k = parseInt(text);
                if (k > 0 && !pending.running)
                    root.temperature = k;
            }
        }
    }

    // Stay in sync with hyprsunset's schedule: every 30s while the control
    // center is open, every 5 min otherwise (so IPC toggles know the state).
    Timer {
        running: true
        interval: Notifs.centerOpen ? 30000 : 300000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "nightlight"

        function toggle(): void {
            root.toggle();
        }
        function set(kelvin: int): void {
            root.setTemperature(kelvin);
        }
        function isOn(): bool {
            return root.on;
        }
    }
}
