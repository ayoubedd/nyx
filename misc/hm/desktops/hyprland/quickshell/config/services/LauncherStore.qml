pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// What the launcher remembers: how often / how recently things were picked
// (frecency ranking for apps, commands and emoji) and pinned apps.
// Saved to $XDG_STATE_HOME/nyx/launcher.json.
Singleton {
    id: root

    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/launcher.json`

    // { "<kind>:<key>": { count, last } }   kind = app | cmd | emoji
    property var usage: ({})
    property var pinned: [] // app ids
    property bool restored: false

    function record(kind, key) {
        const id = `${kind}:${key}`;
        const u = Object.assign({}, usage);
        const prev = u[id] ?? {
            count: 0,
            last: 0
        };
        u[id] = {
            count: prev.count + 1,
            last: Date.now()
        };
        usage = u;
        saveTimer.restart();
    }

    function forget(kind, key) {
        const u = Object.assign({}, usage);
        delete u[`${kind}:${key}`];
        usage = u;
        saveTimer.restart();
    }

    // count weighted by recency: today x4, this week x2, this month x1, older x0.5
    function frecency(kind, key) {
        const u = usage[`${kind}:${key}`];
        if (!u)
            return 0;
        const days = (Date.now() - u.last) / 86400000;
        const w = days < 1 ? 4 : days < 7 ? 2 : days < 30 ? 1 : 0.5;
        return u.count * w;
    }

    // Most used keys of one kind, best first.
    function top(kind, n) {
        const prefix = `${kind}:`;
        return Object.keys(usage).filter(k => k.startsWith(prefix)).map(k => k.slice(prefix.length)).sort((a, b) => frecency(kind, b) - frecency(kind, a)).slice(0, n);
    }

    // Most recent keys of one kind.
    function recent(kind, n) {
        const prefix = `${kind}:`;
        return Object.keys(usage).filter(k => k.startsWith(prefix)).sort((a, b) => usage[b].last - usage[a].last).slice(0, n).map(k => k.slice(prefix.length));
    }

    function isPinned(id) {
        return pinned.includes(id);
    }

    function togglePin(id) {
        pinned = isPinned(id) ? pinned.filter(p => p !== id) : [...pinned, id];
        saveTimer.restart();
    }

    function movePin(id, delta) {
        const i = pinned.indexOf(id);
        const j = i + delta;
        if (i < 0 || j < 0 || j >= pinned.length)
            return;
        const p = pinned.slice();
        p.splice(i, 1);
        p.splice(j, 0, id);
        pinned = p;
        saveTimer.restart();
    }

    function restore(text) {
        try {
            const s = JSON.parse(text);
            usage = s.usage ?? {};
            pinned = s.pinned ?? [];
        } catch (e) {
            console.warn("launcher: unreadable state file", e);
        }
        restored = true;
    }

    Timer {
        id: saveTimer
        interval: 1000
        onTriggered: if (root.restored)
            store.setText(JSON.stringify({
                version: 1,
                usage: root.usage,
                pinned: root.pinned
            }))
    }

    FileView {
        id: store
        path: root.stateFile
        printErrors: false
        atomicWrites: true

        onLoaded: root.restore(text())
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }
}
