pragma Singleton

import QtQuick
import Quickshell

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

    function registerBar(bar) {
        bars = [...bars, bar];
    }

    function unregisterBar(bar) {
        bars = bars.filter(b => b !== bar);
    }
}
