pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history through cliphist (its wl-paste watchers record every
// copy; see ../../default.nix), plus "paste into the focused window".
//
// entries: [{ line, id, preview, isImage, imageInfo }] newest first.
// `line` is cliphist's raw "id<TAB>preview" line, which decode/delete take.
Singleton {
    id: root

    property var entries: []
    property bool available: true // false when the cliphist binary is missing
    property bool loading: false

    readonly property string cacheDir: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/nyx-clipboard`

    // Window classes that paste with Ctrl+Shift+V.
    readonly property var terminalClasses: ["kitty", "floating-terminal", "foot", "footclient", "alacritty", "com.mitchellh.ghostty", "org.wezfurlong.wezterm", "wezterm", "xterm", "konsole", "org.gnome.console", "com.raggesilver.blackbox"]

    function refresh() {
        loading = true;
        lister.running = false;
        lister.running = true;
    }

    function parse(text) {
        const out = [];
        for (const line of text.split("\n")) {
            const tab = line.indexOf("\t");
            if (tab < 0)
                continue;
            const preview = line.slice(tab + 1);
            // "[[ binary data 1.2 MiB png 1920x1080 ]]"
            const img = preview.match(/^\[\[ binary data (.+?) (png|jpe?g|gif|bmp|webp|tiff?|svg\S*) ?(\d+x\d+)? ?\]\]$/i);
            out.push({
                line: line,
                id: line.slice(0, tab),
                preview: preview,
                isImage: !!img,
                imageType: img ? img[2].toLowerCase() : "",
                imageInfo: img ? [img[3], img[2].toUpperCase(), img[1]].filter(s => s).join(" · ") : ""
            });
        }
        return out;
    }

    function pasteKeys(windowClass) {
        const c = (windowClass || "").toLowerCase();
        return terminalClasses.includes(c) ? "wtype -M ctrl -M shift -k v -m shift -m ctrl" : "wtype -M ctrl -k v -m ctrl";
    }

    // Copy an entry back to the clipboard; with `windowClass`, also paste it
    // into that (focused) window once the launcher has let go of the keyboard.
    function use(entry, windowClass, paste) {
        const keys = paste ? `sleep 0.15; ${pasteKeys(windowClass)}` : "true";
        Quickshell.execDetached(["sh", "-c", `printf '%s\\n' "$1" | cliphist decode | wl-copy && ${keys}`, "sh", entry.line]);
    }

    // Same for a plain string (emoji, calculator result).
    function useText(text, windowClass, paste) {
        const keys = paste ? `sleep 0.15; ${pasteKeys(windowClass)}` : "true";
        Quickshell.execDetached(["sh", "-c", `printf '%s' "$1" | wl-copy && ${keys}`, "sh", text]);
    }

    function remove(entry) {
        entries = entries.filter(e => e.id !== entry.id);
        if (entry.isImage) {
            const t = Object.assign({}, thumbs);
            delete t[entry.id];
            thumbs = t;
        }
        Quickshell.execDetached(["sh", "-c", `printf '%s\\n' "$1" | cliphist delete; rm -f "$2"`, "sh", entry.line, entry.isImage ? imagePath(entry) : ""]);
    }

    // Clears the history only; pinned entries stay. The decoded images go
    // too: cliphist restarts ids at 1 after a wipe, so a stale "1.png"
    // would otherwise show up as the next image's thumbnail.
    function wipe() {
        entries = [];
        thumbs = {};
        thumbQueue = [];
        Quickshell.execDetached(["sh", "-c", `cliphist wipe; rm -rf "$1"`, "sh", cacheDir]);
    }

    // Decoded image file for an entry (written on demand by ClipboardPreview
    // and the list thumbnails).
    function imagePath(entry) {
        return `${cacheDir}/${entry.id}.${entry.imageType === "jpeg" ? "jpg" : entry.imageType || "png"}`;
    }

    // ---- list thumbnails --------------------------------------------------
    // Rows ask for their image (requestThumb) when they're created, so only
    // what's on screen is decoded, one at a time. thumbs: entry id -> file.
    property var thumbs: ({})
    property var thumbQueue: []

    function requestThumb(entry) {
        if (!entry?.isImage || thumbs[entry.id] || thumbQueue.some(e => e.id === entry.id))
            return;
        thumbQueue = [...thumbQueue, entry];
        nextThumb();
    }

    function nextThumb() {
        if (thumbDecoder.running || thumbQueue.length === 0)
            return;
        const e = thumbQueue[0];
        thumbQueue = thumbQueue.slice(1);
        thumbDecoder.entry = e;
        thumbDecoder.target = imagePath(e);
        thumbDecoder.running = true;
    }

    Process {
        id: thumbDecoder
        property var entry: null
        property string target
        command: ["sh", "-c", `mkdir -p "$(dirname "$2")" && { [ -s "$2" ] || printf '%s\\n' "$1" | cliphist decode > "$2"; }`, "sh", entry?.line ?? "", target]
        onExited: code => {
            if (code === 0 && entry) {
                const t = Object.assign({}, root.thumbs);
                t[entry.id] = target;
                root.thumbs = t;
            }
            root.nextThumb();
        }
    }

    // ---- pinned entries ---------------------------------------------------
    // A pin is a copy of the entry's raw bytes (+ mime type and preview) in
    // $XDG_RUNTIME_DIR/nyx-clipboard-pins: RAM like the history, but outside
    // cliphist, so clearing the history keeps them. Gone after a reboot.
    // pins: [{ pinned, id, file, type, isImage, preview, imageInfo }]
    readonly property string pinsDir: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/nyx-clipboard-pins`
    property var pins: []

    function pin(entry) {
        const type = entry.isImage ? `image/${entry.imageType === "jpg" ? "jpeg" : entry.imageType || "png"}` : "text/plain;charset=utf-8";
        pinQueue = [...pinQueue, ["sh", "-c", `
            dir=$1; name=$(date +%s%N)
            mkdir -p -m 700 "$dir"
            printf '%s\\n' "$2" | cliphist decode > "$dir/$name.data" || exit 1
            printf '%s' "$3" > "$dir/$name.type"
            printf '%s' "$4" > "$dir/$name.preview"`, "sh", pinsDir, entry.line, type, entry.isImage ? entry.imageInfo : entry.preview]];
        nextPin();
    }

    // Pins run one at a time (a busy Process ignores a new command).
    property var pinQueue: []

    function nextPin() {
        if (pinProc.running || pinQueue.length === 0)
            return;
        pinProc.command = pinQueue[0];
        pinQueue = pinQueue.slice(1);
        pinProc.running = true;
    }

    function unpin(p) {
        pins = pins.filter(x => x.id !== p.id);
        Quickshell.execDetached(["sh", "-c", `rm -f "$1"/"$2".*`, "sh", pinsDir, p.id]);
    }

    function usePin(p, windowClass, paste) {
        const keys = paste ? `sleep 0.15; ${pasteKeys(windowClass)}` : "true";
        Quickshell.execDetached(["sh", "-c", `wl-copy -t "$2" < "$1" && ${keys}`, "sh", p.file, p.type]);
    }

    function refreshPins() {
        pinLister.running = true;
    }

    Process {
        id: pinProc
        onExited: {
            root.refreshPins();
            root.nextPin();
        }
    }

    // Newest first: "<name>\t<type>\t<preview>" per pin.
    Process {
        id: pinLister
        command: ["sh", "-c", `
            for t in $(ls -r "$1"/*.type 2>/dev/null); do
                n=$(basename "$t" .type)
                [ -e "$1/$n.data" ] || continue
                printf '%s\\t%s\\t%s\\n' "$n" "$(cat "$t")" "$(tr '\\n\\t' '  ' < "$1/$n.preview" 2>/dev/null)"
            done`, "sh", root.pinsDir]
        stdout: StdioCollector {
            onStreamFinished: {
                root.pins = text.split("\n").filter(l => l.includes("\t")).map(l => {
                    const f = l.split("\t");
                    const isImage = f[1].startsWith("image/");
                    return {
                        pinned: true,
                        id: f[0],
                        file: `${root.pinsDir}/${f[0]}.data`,
                        type: f[1],
                        isImage: isImage,
                        preview: isImage ? "" : f.slice(2).join("\t"),
                        imageInfo: isImage ? f.slice(2).join("\t") : ""
                    };
                });
            }
        }
    }

    Component.onCompleted: refreshPins()

    Process {
        id: lister
        command: ["cliphist", "-preview-width", "400", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.entries = root.parse(text)
        }
        onExited: code => {
            root.loading = false;
            root.available = code !== 127;
        }
    }
}
