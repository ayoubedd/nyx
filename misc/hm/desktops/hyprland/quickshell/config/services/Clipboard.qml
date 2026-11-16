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
        Quickshell.execDetached(["sh", "-c", `printf '%s\\n' "$1" | cliphist delete`, "sh", entry.line]);
    }

    function wipe() {
        entries = [];
        Quickshell.execDetached(["cliphist", "wipe"]);
    }

    // Decoded image file for an entry (written on demand by ClipboardPreview).
    function imagePath(entry) {
        return `${cacheDir}/${entry.id}.${entry.imageType === "jpeg" ? "jpg" : entry.imageType || "png"}`;
    }

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
