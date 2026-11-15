pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper state for the dashboard picker, driving the awww daemon.
//
// Two modes:
//   shuffle  the awww-wallpaper-reload user service rotates through
//            ~/Pictures/Wallpapers every 15 min (scripts/reload-wallpaper)
//   pinned   a picked wallpaper, saved to ~/.local/state/nyx/wallpaper; the
//            rotation service is stopped, and at login the script just shows
//            the pinned image instead of rotating.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string dir: `${home}/Pictures/Wallpapers`
    readonly property string pinFile: `${Quickshell.env("XDG_STATE_HOME") || home + "/.local/state"}/nyx/wallpaper`
    readonly property string service: "awww-wallpaper-reload.service"

    property var images: [] // absolute paths
    property string current: "" // what awww is showing
    property bool shuffling: false

    function refresh() {
        scan.running = true;
    }

    function apply(path) {
        current = path;
        shuffling = false;
        Quickshell.execDetached(["sh", "-c", `
            mkdir -p "$(dirname "$2")"
            printf '%s\\n' "$1" > "$2"
            systemctl --user stop "$3"
            awww img -t grow --transition-duration 2 --transition-pos 0.5,0.5 "$1"
        `, "sh", path, pinFile, service]);
    }

    function setShuffle(on) {
        shuffling = on;
        if (on)
            Quickshell.execDetached(["sh", "-c", `rm -f "$1"; systemctl --user restart "$2"`, "sh", pinFile, service]);
        else if (current)
            apply(current);
    }

    // Wallpapers (top level, symlinks included), what's showing, and whether
    // the rotation service is running.
    Process {
        id: scan
        command: ["sh", "-c", `
            find -L "$1" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort
            echo "--"
            awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -1
            echo "--"
            systemctl --user is-active "$2" 2>/dev/null
        `, "sh", root.dir, root.service]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.split("--\n");
                root.images = (parts[0] || "").split("\n").filter(l => l.trim() !== "");
                root.current = (parts[1] || "").trim();
                root.shuffling = (parts[2] || "").trim() === "active";
            }
        }
    }
}
