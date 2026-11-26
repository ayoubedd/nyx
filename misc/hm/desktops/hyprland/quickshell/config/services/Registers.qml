pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Vim-style named clipboard registers a-z (UI: overlays/RegisterPanel.qml).
//
//   store(r)  current clipboard -> register r   (text or image, any type)
//   put(r)    register r -> clipboard            (nothing is typed)
//   clear(r)
//
// Kept in RAM only: $XDG_RUNTIME_DIR/nyx-registers (tmpfs, mode 700), so
// registers survive a quickshell restart but not a logout/reboot, and never
// touch the disk. Each register is <r>.data (the raw clipboard bytes) +
// <r>.type (its mime type).
//
//   qs -c nyx ipc call registers store a
//   qs -c nyx ipc call registers put a
Singleton {
    id: root

    readonly property string dir: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/nyx-registers`
    readonly property string names: "abcdefghijklmnopqrstuvwxyz"

    // name -> { name, type, size, preview, isImage }
    property var registers: ({})
    readonly property var filled: Object.keys(registers).sort().map(k => registers[k])

    function valid(r) {
        return typeof r === "string" && r.length === 1 && names.includes(r);
    }

    function store(r) {
        if (!valid(r))
            return;
        run(["sh", "-c", storeScript, "sh", dir, r], `Stored in "${r}`);
    }

    function put(r) {
        if (!valid(r) || !registers[r])
            return;
        run(["sh", "-c", `wl-copy -t "$(cat "$1/$2.type")" < "$1/$2.data"`, "sh", dir, r], "");
    }

    function clear(r) {
        if (!valid(r))
            return;
        run(["sh", "-c", `rm -f "$1/$2.data" "$1/$2.type"`, "sh", dir, r], "");
    }

    function refresh() {
        if (lister.running)
            again = true;
        else
            lister.running = true;
    }
    property bool again: false

    // Pick what to keep from the clipboard: an image if it offers PNG (a
    // copied image often also offers a text name), else UTF-8 text, else
    // whatever it offers first.
    readonly property string storeScript: `
        dir=$1 r=$2
        mkdir -p -m 700 "$dir"
        types=$(wl-paste --list-types 2>/dev/null)
        [ -n "$types" ] || exit 3
        pick() { printf '%s\\n' "$types" | grep -m1 -x "$1"; }
        type=$(pick 'image/png' || pick 'text/plain;charset=utf-8' || pick 'UTF8_STRING' || pick 'text/plain' || pick 'image/.*' || printf '%s\\n' "$types" | head -1)
        wl-paste -n -t "$type" > "$dir/$r.data.tmp" || exit 4
        mv "$dir/$r.data.tmp" "$dir/$r.data"
        printf '%s' "$type" > "$dir/$r.type"
    `

    // One line per register: name, type, size, preview (text only).
    Process {
        id: lister
        command: ["sh", "-c", `
            for t in "$1"/*.type; do
                [ -e "$t" ] || continue
                r=$(basename "$t" .type)
                f="$1/$r.data"
                [ -e "$f" ] || continue
                type=$(cat "$t")
                size=$(stat -c %s "$f")
                case "$type" in
                    text/*|UTF8_STRING|STRING|TEXT) preview=$(head -c 400 "$f" | tr '\\n\\t\\r' '   ') ;;
                    *) preview="" ;;
                esac
                printf '%s\\t%s\\t%s\\t%s\\n' "$r" "$type" "$size" "$preview"
            done`, "sh", root.dir]
        stdout: StdioCollector {
            onStreamFinished: {
                const regs = {};
                for (const line of text.split("\n")) {
                    const f = line.split("\t");
                    if (f.length < 3 || !root.valid(f[0]))
                        continue;
                    regs[f[0]] = {
                        name: f[0],
                        type: f[1],
                        size: Number(f[2]),
                        preview: f.slice(3).join("\t").trim(),
                        isImage: f[1].startsWith("image/")
                    };
                }
                root.registers = regs;
            }
        }
        onExited: if (root.again) {
            root.again = false;
            running = true;
        }
    }

    Process {
        id: actionProc
        property string done: ""
        onExited: code => {
            if (code === 3)
                root.lastError = "The clipboard is empty";
            else if (code !== 0)
                root.lastError = "Couldn't read the clipboard";
            else
                root.lastError = "";
            root.refresh();
            root.nextAction();
        }
    }
    property string lastError: ""

    // Actions run one at a time, in order (a busy Process ignores a new
    // command, so a quick second store/put/clear would be lost).
    property var actionQueue: []

    function run(cmd, done) {
        actionQueue = [...actionQueue, {
                cmd,
                done
            }];
        nextAction();
    }

    function nextAction() {
        if (actionProc.running || actionQueue.length === 0)
            return;
        const a = actionQueue[0];
        actionQueue = actionQueue.slice(1);
        actionProc.command = a.cmd;
        actionProc.done = a.done;
        actionProc.running = true;
    }

    Component.onCompleted: refresh()

    function sizeText(bytes) {
        return bytes < 1024 ? `${bytes} B` : bytes < 1048576 ? `${Math.round(bytes / 1024)} KB` : `${(bytes / 1048576).toFixed(1)} MB`;
    }

    IpcHandler {
        target: "registers"

        function store(name: string): void {
            root.store(name);
        }
        function put(name: string): void {
            root.put(name);
        }
        function clear(name: string): void {
            root.clear(name);
        }
        function list(): string {
            return root.filled.map(r => `${r.name}\t${r.type}\t${r.isImage ? root.sizeText(r.size) : r.preview.slice(0, 60)}`).join("\n");
        }
    }
}
