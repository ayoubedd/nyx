pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Sending notifications from the shell's own services (Battery, Timers,
// Recorder, Removable…). They go through the session's notification server
// (Notifs.qml) like any app's, so DND, app rules and the center apply.
//
//   Notifier.send("Battery", "Battery low", "12% remaining.", {
//       icon: "battery-caution", urgency: "critical" });
//
//   Notifier.ask("Drives", "USB stick connected", "/run/media/…", {
//       icon: "drive-removable-media" },
//       { open: "Open", eject: "Eject" },
//       action => { if (action === "eject") … });
//
// urgency: "low" | "normal" (default) | "critical" (shows through DND).
Singleton {
    id: root

    function args(app, opts) {
        const o = opts ?? {};
        const a = ["notify-send", "-a", app, "-u", o.urgency ?? "normal"];
        if (o.icon)
            a.push("-i", o.icon);
        return a;
    }

    function send(app, summary, body, opts) {
        Quickshell.execDetached([...args(app, opts), "--", summary, body ?? ""]);
    }

    // With buttons: `actions` maps action id -> label; `onAction(id)` runs
    // when one is clicked (not when it's dismissed or times out). Each
    // notification gets its own waiting notify-send, so several can be
    // pending at once.
    function ask(app, summary, body, opts, actions, onAction) {
        const a = args(app, opts);
        for (const id of Object.keys(actions))
            a.push("-A", `${id}=${actions[id]}`);
        waiter.createObject(root, {
            command: [...a, "--wait", "--", summary, body ?? ""],
            handler: onAction
        });
    }

    Component {
        id: waiter

        Process {
            id: proc
            property var handler: null
            running: true
            stdout: SplitParser {
                onRead: line => {
                    const id = line.trim();
                    if (id && proc.handler)
                        proc.handler(id);
                }
            }
            onExited: proc.destroy()
        }
    }
}
