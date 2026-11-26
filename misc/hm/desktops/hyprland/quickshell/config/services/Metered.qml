pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Metered connections (phone hotspot: Android announces it over DHCP, and
// NetworkManager marks it "yes (guessed)"; or set by hand per connection).
// While the connection carrying the default route is metered, background
// downloads are paused, and the bar's network icon shows a small badge.
//
// The only automatic download here is the weekly nix-index database sync
// (a user timer); it's stopped while metered and started again afterwards
// (it's Persistent, so a missed run happens then).
Singleton {
    id: root

    property bool metered: false
    readonly property var pausedUnits: ["nix-index-database-sync.timer"]
    // The first reading after startup has been applied.
    property bool known: false

    // The units outlive the shell, so whether they were paused isn't kept
    // here: the state is applied on the first reading and every change.
    // Not metered: start any of them that's enabled but not running (e.g.
    // stopped by an earlier shell instance before a restart); idempotent.
    function apply() {
        if (metered)
            Quickshell.execDetached(["systemctl", "--user", "stop", ...pausedUnits]);
        else
            Quickshell.execDetached(["sh", "-c", "for u; do systemctl --user -q is-enabled \"$u\" && ! systemctl --user -q is-active \"$u\" && systemctl --user start \"$u\"; done; exit 0", "sh", ...pausedUnits]);
    }

    onMeteredChanged: if (known)
        apply()

    function check() {
        if (reader.running)
            again = true;
        else
            reader.running = true;
    }
    property bool again: false

    // Metered state of the device with the default route.
    Process {
        id: reader
        command: ["sh", "-c", "dev=$(ip route show default 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == \"dev\") { print $(i + 1); exit }}'); [ -n \"$dev\" ] && nmcli -g GENERAL.METERED device show \"$dev\""]
        stdout: StdioCollector {
            onStreamFinished: {
                root.metered = text.trim().startsWith("yes");
                if (!root.known) {
                    root.known = true;
                    root.apply();
                }
            }
        }
        onExited: if (root.again) {
            root.again = false;
            running = true;
        }
    }

    // NetworkManager prints a line on every state change: re-check then
    // (debounced: connecting prints a burst).
    Process {
        id: monitor
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: _ => debounce.restart()
        }
        onExited: retry.restart()
    }

    Timer {
        id: debounce
        interval: 1500
        onTriggered: root.check()
    }

    Timer {
        id: retry
        interval: 5000
        onTriggered: monitor.running = true
    }

    Component.onCompleted: check()
}
