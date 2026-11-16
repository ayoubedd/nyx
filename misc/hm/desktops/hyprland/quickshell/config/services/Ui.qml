pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.components

// Shared UI state: which bar window (dropdown) is open, and the bar windows
// themselves so focus grabs can let clicks on the bar through.
Singleton {
    id: root

    property var active: null // open Dropdown, if any
    property var bars: [] // PanelWindows of the bar, one per screen

    function open(dropdown) {
        if (active && active !== dropdown)
            active.shown = false;
        Notifs.centerOpen = false;
        active = dropdown;
        dropdown.shown = true;
    }

    function closeAll() {
        if (active)
            active.shown = false;
        active = null;
    }

    // Ask the bar on `screen` to toggle one of its menus (the widgets listen).
    signal menuRequested(string name, string screen)

    // qs -c nyx ipc call bar toggle <sound|network|bluetooth|battery>
    // Opens the menu on the focused monitor's bar.
    IpcHandler {
        target: "bar"

        function toggle(name: string): void {
            root.menuRequested(name, Hyprland.focusedMonitor?.name ?? "");
        }
    }

    function registerBar(bar) {
        bars = [...bars, bar];
    }

    function unregisterBar(bar) {
        bars = bars.filter(b => b !== bar);
    }
}
