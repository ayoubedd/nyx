pragma Singleton

import QtQuick
import Quickshell

// Hyprland dispatch helpers shared by the overview, launcher and others.
Singleton {
    id: root

    // "0x…" window address (Hyprland toplevels report it with or without
    // the prefix), for `address:` window selectors.
    function address(toplevel) {
        const a = toplevel?.address ?? "";
        return a.startsWith("0x") ? a : `0x${a}`;
    }

    // Run Hyprland dispatches in order with cursor warping off, so moving /
    // focusing / closing windows doesn't yank the mouse pointer to them.
    // One sequential script, so the option change can't race the
    // dispatches; the user's own cursor:no_warps value is restored after.
    // Runs are serialized with a lock, so an overlapping run can't read the
    // temporary "true" as the user's value and restore that.
    //   HyprDispatch.withoutWarps([`hl.dsp.focus({ window = "address:0x…" })`, ...])
    function withoutWarps(dispatches) {
        if (dispatches && dispatches.length > 0)
            Quickshell.execDetached(["sh", "-c", noWarpScript, "sh", ...dispatches]);
    }

    readonly property string noWarpScript: `
        exec 9>"\${XDG_RUNTIME_DIR:-/tmp}/nyx-nowarp.lock"
        flock 9
        orig=$(hyprctl -j getoption cursor:no_warps | jq -r 'if has("bool") then (if .bool then 1 else 0 end) else (.int // empty) end' 2>/dev/null)
        # Couldn't read the user's value (IPC hiccup, jq error): dispatch
        # without touching the option, rather than "restore" a guess later.
        case "$orig" in
            0|1) ;;
            *)
                for d in "$@"; do
                    hyprctl dispatch "$d" >/dev/null
                done
                exit 0
                ;;
        esac
        hyprctl eval 'hl.config({ cursor = { no_warps = true } })' >/dev/null
        for d in "$@"; do
            hyprctl dispatch "$d" >/dev/null
        done
        sleep 0.3
        if [ "$orig" = 1 ]; then v=true; else v=false; fi
        hyprctl eval "hl.config({ cursor = { no_warps = $v } })" >/dev/null
    `
}
