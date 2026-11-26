pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// USBGuard front end (machines/x1/security.nix): devices USBGuard blocked,
// for the prompt in overlays/UsbPrompt.qml.
//
// `usbguard watch` streams daemon events; on any event the blocked list is
// re-read (`usbguard list-devices --blocked`). The user's IPC access comes
// from services.usbguard.IPCAllowedUsers.
//
// pending: [{ id, vid, pid, name, vendor, serial, port, interfaces[],
//             kinds[], canType, suspicious }]
Singleton {
    id: root

    property var blocked: []
    property var dismissed: [] // device ids kept blocked this session
    readonly property var pending: blocked.filter(d => !dismissed.includes(d.id))
    property bool available: false // daemon reachable

    // ---- actions ---------------------------------------------------------

    function allowOnce(dev) {
        run(["usbguard", "allow-device", dev.id]);
    }

    // Appends a rule for this exact device (with its hash) to the rules file.
    function allowAlways(dev) {
        run(["usbguard", "allow-device", "-p", dev.id]);
    }

    // Leave it blocked (and stop asking until it is plugged in again).
    function keepBlocked(dev) {
        dismissed = [...dismissed, dev.id];
    }

    // Actions run one at a time, in order: a busy Process ignores a new
    // command, so a quick second Allow (another device) would be lost.
    property var actionQueue: []

    function run(cmd) {
        actionQueue = [...actionQueue, cmd];
        nextAction();
    }

    function nextAction() {
        if (actionProc.running || actionQueue.length === 0)
            return;
        actionProc.command = actionQueue[0];
        actionQueue = actionQueue.slice(1);
        actionProc.running = true;
    }

    function refresh() {
        if (lister.running)
            again = true;
        else
            lister.running = true;
    }
    property bool again: false

    // ---- parsing ---------------------------------------------------------

    // USB interface classes (bInterfaceClass) -> what the device can do.
    readonly property var classNames: ({
            "01": "Audio",
            "02": "Network/modem",
            "03": "Input",
            "05": "Physical",
            "06": "Camera/photos",
            "07": "Printer",
            "08": "Storage",
            "09": "Hub",
            "0a": "Network/modem",
            "0b": "Smart card",
            "0d": "Security",
            "0e": "Video",
            "0f": "Health",
            "10": "Audio/video",
            "11": "Billboard",
            "e0": "Wireless",
            "ef": "Misc",
            "fe": "Firmware update",
            "ff": "Vendor specific"
        })

    function kinds(interfaces) {
        const out = [];
        const add = k => {
            if (!out.includes(k))
                out.push(k);
        };
        for (const i of interfaces) {
            const [cls, sub, proto] = i.split(":");
            if (cls === "03" && proto === "01")
                add("Keyboard");
            else if (cls === "03" && proto === "02")
                add("Mouse");
            else if (cls === "03")
                add("Input");
            else if (cls === "e0" && sub === "01" && proto === "01")
                add("Bluetooth");
            else
                add(classNames[cls] ?? `Class ${cls}`);
        }
        return out;
    }

    // `id 1050:0407 serial "" name "..." hash "..." via-port "3-1"
    //  with-interface { 03:01:01 03:00:00 } with-connect-type "hotplug"`
    function parse(text) {
        const out = [];
        for (const raw of text.split("\n")) {
            const tab = raw.indexOf("\t");
            if (tab < 0)
                continue;
            const vendor = raw.slice(0, tab).trim();
            const line = raw.slice(tab + 1);
            const m = line.match(/^(\d+):\s+\w+\s+id\s+([0-9a-f]{4}):([0-9a-f]{4})/i);
            if (!m)
                continue;
            const str = key => ((line.match(new RegExp(`${key} "((?:[^"\\\\]|\\\\.)*)"`)) ?? [])[1] ?? "").replace(/\\(.)/g, "$1");
            const ifm = line.match(/with-interface\s+(\{[^}]*\}|\S+)/);
            const interfaces = ifm ? ifm[1].replace(/[{}]/g, " ").trim().split(/\s+/).filter(s => s) : [];
            const k = kinds(interfaces);
            const canType = k.includes("Keyboard") || interfaces.some(i => i.startsWith("03:00:"));
            // A keyboard that is also storage / network / vendor-specific is
            // the classic BadUSB disguise (a "flash drive" that types).
            const suspicious = k.includes("Keyboard") && k.some(x => ["Storage", "Network/modem", "Vendor specific", "Wireless"].includes(x));
            out.push({
                id: m[1],
                vid: m[2].toLowerCase(),
                pid: m[3].toLowerCase(),
                name: str("name"),
                serial: str("serial"),
                port: str("via-port"),
                connectType: str("with-connect-type"),
                vendor: vendor,
                interfaces: interfaces,
                kinds: k,
                canType: canType,
                suspicious: suspicious
            });
        }
        return out;
    }

    // ---- processes -------------------------------------------------------

    // Blocked devices, each prefixed with its manufacturer string from sysfs
    // (readable while the device is blocked): "<vendor>\t<usbguard line>".
    Process {
        id: lister
        command: ["bash", "-c", `
            out=$(usbguard list-devices --blocked) || exit 2
            [ -n "$out" ] || exit 0
            while IFS= read -r line; do
                if [[ $line =~ \\ id\\ ([0-9a-f]{4}):([0-9a-f]{4}) ]]; then
                    vid=\${BASH_REMATCH[1]} pid=\${BASH_REMATCH[2]}
                else
                    continue
                fi
                vendor=""
                for d in /sys/bus/usb/devices/*; do
                    [ -r "$d/idVendor" ] || continue
                    [ "$(<"$d/idVendor")" = "$vid" ] && [ "$(<"$d/idProduct")" = "$pid" ] || continue
                    [ "$(<"$d/authorized")" = 0 ] || continue
                    vendor=$(cat "$d/manufacturer" 2>/dev/null)
                    break
                done
                printf '%s\\t%s\\n' "$vendor" "$line"
            done <<<"$out"`]
        stdout: StdioCollector {
            onStreamFinished: root.blocked = root.parse(text)
        }
        onExited: code => {
            root.available = code === 0;
            if (root.again) {
                root.again = false;
                running = true;
            }
        }
    }

    // Any daemon event (insert, remove, policy change) -> re-read.
    Process {
        id: watcher
        running: true
        command: ["usbguard", "watch"]
        stdout: SplitParser {
            onRead: debounce.restart()
        }
        onExited: retry.restart() // daemon down / restarted
    }

    Timer {
        id: debounce
        interval: 200
        onTriggered: root.refresh()
    }

    Timer {
        id: retry
        interval: 30000
        onTriggered: {
            watcher.running = true;
            root.refresh();
        }
    }

    Process {
        id: actionProc
        onExited: {
            root.refresh();
            root.nextAction();
        }
    }

    Component.onCompleted: refresh()

    // qs -c nyx ipc call usbguard list   -> what the prompt sees
    IpcHandler {
        target: "usbguard"

        function list(): string {
            return JSON.stringify(root.pending, null, 1);
        }
    }
}
