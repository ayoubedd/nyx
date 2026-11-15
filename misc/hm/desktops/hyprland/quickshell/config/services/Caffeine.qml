pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// "Keep awake": holds a systemd idle inhibitor while active. hypridle honours
// it, so the idle dim / lock / screen-off / auto-suspend listeners don't fire.
// Manual suspend (power menu, lid) still works.
//
//   qs -c nyx ipc call caffeine toggle
//   qs -c nyx ipc call caffeine enable 60     (minutes; 0 = until turned off)
//   qs -c nyx ipc call caffeine disable
Singleton {
    id: root

    property bool active: false
    property real until: 0 // epoch ms; 0 = until turned off
    property real now: Date.now()

    readonly property real remaining: active && until > 0 ? Math.max(0, until - now) : 0

    function enable(minutes) {
        until = minutes > 0 ? Date.now() + minutes * 60000 : 0;
        now = Date.now();
        active = true;
    }

    function disable() {
        active = false;
        until = 0;
    }

    function toggle() {
        if (active)
            disable();
        else
            enable(0);
    }

    // "1h 20m left" / "Until turned off" / "".
    readonly property string remainingText: {
        if (!active)
            return "";
        if (until <= 0)
            return "Until turned off";
        const mins = Math.ceil(remaining / 60000);
        const h = Math.floor(mins / 60);
        const m = mins % 60;
        return `${h > 0 ? `${h}h ` : ""}${m}m left`;
    }

    // The inhibitor lives exactly as long as this process.
    Process {
        running: root.active
        command: ["systemd-inhibit", "--what=idle", "--who=nyx", "--why=Keep awake (quickshell)", "--mode=block", "sleep", "infinity"]
    }

    Timer {
        running: root.active && root.until > 0
        interval: 10000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();
            if (root.now >= root.until)
                root.disable();
        }
    }

    IpcHandler {
        target: "caffeine"

        function toggle(): void {
            root.toggle();
        }
        function enable(minutes: int): void {
            root.enable(minutes);
        }
        function disable(): void {
            root.disable();
        }
        function isActive(): bool {
            return root.active;
        }
    }
}
