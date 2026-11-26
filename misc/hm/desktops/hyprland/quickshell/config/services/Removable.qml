pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Mounted removable drives (USB sticks, SD cards): whatever udisks mounts
// under /run/media/$USER (the file manager, `udisksctl mount`).
//   - a notification when one is mounted, with Open / Eject;
//   - the bar's ⏏ (EjectWidget.qml) while any is mounted;
//   - eject() unmounts and powers the drive off, then says it's safe to
//     pull out (or why it couldn't, e.g. a file is still open).
// USBGuard (UsbPrompt.qml) decides whether a device may connect at all;
// this is only about "is it safe to remove".
Singleton {
    id: root

    readonly property string mediaRoot: `/run/media/${Quickshell.env("USER")}/`
    // [{ target, source, name }]
    property var drives: []

    function nameOf(target) {
        return target.slice(target.lastIndexOf("/") + 1).replace(/\\x20/g, " ");
    }

    function refresh() {
        if (lister.running)
            again = true;
        else
            lister.running = true;
    }
    property bool again: false

    // Current mounts under /run/media/$USER (raw: escapes like \x20).
    Process {
        id: lister
        command: ["findmnt", "-rn", "-o", "TARGET,SOURCE"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = [];
                for (const line of text.split("\n")) {
                    const [target, source] = line.split(" ");
                    if (target?.startsWith(root.mediaRoot) && source?.startsWith("/dev/"))
                        list.push({
                            target: target.replace(/\\x20/g, " "),
                            source: source,
                            name: root.nameOf(target)
                        });
                }
                const before = new Set(root.drives.map(d => d.target));
                root.drives = list;
                // Newly mounted (not on the first read at startup).
                if (root.started)
                    for (const d of list.filter(d => !before.has(d.target)))
                        root.announce(d);
                root.started = true;
            }
        }
        onExited: if (root.again) {
            root.again = false;
            running = true;
        }
    }
    property bool started: false

    // findmnt --poll prints a line per mount / unmount anywhere.
    Process {
        id: poll
        running: true
        command: ["findmnt", "--poll", "-rn", "-o", "ACTION,TARGET"]
        stdout: SplitParser {
            onRead: line => {
                if (line.includes(root.mediaRoot))
                    root.refresh();
            }
        }
        onExited: pollRetry.restart()
    }

    Timer {
        id: pollRetry
        interval: 5000
        onTriggered: poll.running = true
    }

    Component.onCompleted: refresh()

    // ---- notifications -----------------------------------------------------

    readonly property var noteOpts: ({
            icon: "drive-removable-media"
        })

    function notify(summary, body, urgency) {
        Notifier.send("Drives", summary, body, Object.assign({
            urgency: urgency
        }, noteOpts));
    }

    // "<name> connected" with Open / Eject.
    function announce(d) {
        Notifier.ask("Drives", `${d.name} connected`, d.target, noteOpts, {
            open: "Open",
            eject: "Eject"
        }, action => action === "open" ? Quickshell.execDetached(["xdg-open", d.target]) : root.eject(d));
    }

    // ---- eject ---------------------------------------------------------------

    property string ejecting: "" // target being ejected

    // Unmount, then power off the whole drive (its parent device, so the
    // stick can't be written to any more and the LED goes out).
    function eject(d) {
        // Still mounted? (an old notification's Eject may be clicked late)
        d = drives.find(x => x.target === d?.target);
        if (!d || ejector.running)
            return;
        ejecting = d.target;
        ejector.drive = d;
        // Exit 3: unmounted, but another partition of the same drive is
        // still mounted, so it isn't powered off and isn't safe to pull.
        // A failed power-off otherwise is fine (unmount already flushed it;
        // some card readers just don't support it).
        ejector.command = ["sh", "-c", "udisksctl unmount -b \"$1\" >/dev/null || exit 1; p=$(lsblk -no PKNAME \"$1\" 2>/dev/null); dev=\"/dev/${p:-${1#/dev/}}\"; lsblk -nro MOUNTPOINTS \"$dev\" 2>/dev/null | grep -q . && exit 3; udisksctl power-off -b \"$dev\" >/dev/null 2>&1; exit 0", "sh", d.source];
        ejector.running = true;
    }

    Process {
        id: ejector
        property var drive: null
        stderr: StdioCollector {
            id: ejectErr
        }
        onExited: code => {
            root.ejecting = "";
            if (code === 0)
                root.notify(`${drive.name} can be removed`, "It's safe to unplug it now.", "low");
            else if (code === 3)
                root.notify(`${drive.name} unmounted`, "Another partition on this drive is still mounted. Eject it too before unplugging.", "normal");
            else
                root.notify(`Couldn't eject ${drive.name}`, ejectErr.text.trim().includes("busy") ? "A file on it is still open. Close it and try again." : (ejectErr.text.trim() || "It's still in use."), "normal");
            root.refresh();
        }
    }
}
