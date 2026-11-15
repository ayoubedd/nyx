pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Notification daemon (replaces swaync) + shared notification-center state.
//
// Persistence (~/.local/state/nyx/notifications.json): Do Not Disturb and the
// notification history (last 50, up to 7 days) survive quickshell restarts.
// Live notifications belong to the app that sent them, so after a restart
// they come back as read-only history entries: same card, dismissable, no
// action buttons. In-memory images can't be saved; app icons and image files
// can. Hot reloads keep live notifications (keepOnReload), and their saved
// copies are skipped so nothing is shown twice.
Singleton {
    id: root

    property bool dnd: false
    property bool centerOpen: false

    // Notifications currently shown as popups (a subset of `list`).
    property var popups: []

    // Restored, read-only entries (notification-shaped plain objects).
    property var history: []

    // Newest first: live notifications, then restored history.
    readonly property var list: server.trackedNotifications.values.slice().reverse().concat(history)
    readonly property int count: list.length

    // Grouped by app, newest group first (macOS-style stacks):
    // [{ key, appName, notifications: [newest, ...] }]
    readonly property var groups: {
        const map = new Map();
        for (const n of list) {
            const key = n.desktopEntry || n.appName || "unknown";
            if (!map.has(key))
                map.set(key, {
                    key: key,
                    appName: n.appName || "Notification",
                    notifications: []
                });
            map.get(key).notifications.push(n);
        }
        return [...map.values()];
    }

    // Keys of groups the user fanned out. Collapses again when the center closes.
    property var expanded: []

    function isExpanded(key) {
        return expanded.includes(key);
    }

    function setExpanded(key, on) {
        const rest = expanded.filter(k => k !== key);
        expanded = on ? [...rest, key] : rest;
    }

    function clearGroup(key) {
        const group = groups.find(g => g.key === key);
        for (const n of group?.notifications.slice() ?? [])
            n.dismiss();
        setExpanded(key, false);
    }

    // Ticks so "5m ago" labels stay fresh.
    property real now: Date.now()
    property var receivedAt: ({})

    function toggleCenter() {
        centerOpen = !centerOpen;
    }

    function clearAll() {
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
        history = [];
    }

    function hidePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function timeAgo(n) {
        const t = receivedAt[n.id];
        if (!t)
            return "";
        const mins = Math.floor((now - t) / 60000);
        if (mins < 1)
            return "now";
        if (mins < 60)
            return `${mins}m ago`;
        const hours = Math.floor(mins / 60);
        return hours < 24 ? `${hours}h ago` : Qt.formatDateTime(new Date(t), "ddd HH:mm");
    }

    onCenterOpenChanged: {
        if (centerOpen) {
            popups = [];
            Ui.closeAll();
        } else {
            expanded = [];
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = Date.now()
    }

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            root.receivedAt[n.id] = Date.now();
            root.now = Date.now();

            const silenced = root.dnd && n.urgency !== NotificationUrgency.Critical;
            if (!root.centerOpen && !silenced)
                root.popups = [n, ...root.popups];

            n.closed.connect(() => root.hidePopup(n));
        }
    }

    // ---- persistence ------------------------------------------------------
    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/notifications.json`
    readonly property int keepCount: 50
    readonly property real keepAge: 7 * 86400000 // ms

    // Don't write until the saved state has been read (would wipe it).
    property bool restored: false
    property int historySerial: 0

    // Only real files survive a restart (not image://… in-memory pixmaps).
    function persistableImage(src) {
        return src && (src.startsWith("/") || src.startsWith("file://")) ? src : "";
    }

    function makeEntry(e) {
        const entry = {
            id: `h${historySerial++}`,
            appName: e.appName || "",
            summary: e.summary || "",
            body: e.body || "",
            appIcon: e.appIcon || "",
            image: e.image || "",
            desktopEntry: e.desktopEntry || "",
            urgency: e.urgency ?? NotificationUrgency.Normal,
            actions: [],
            resident: false,
            transient: false,
            expireTimeout: -1,
            restored: true
        };
        entry.dismiss = () => root.removeHistory(entry);
        entry.expire = entry.dismiss;
        root.receivedAt[entry.id] = e.time || Date.now();
        return entry;
    }

    function removeHistory(entry) {
        history = history.filter(h => h !== entry);
    }

    function restore(json) {
        try {
            const data = JSON.parse(json);
            dnd = !!data.dnd;
            const liveIds = new Set(server.trackedNotifications.values.map(n => n.id));
            const cutoff = Date.now() - keepAge;
            const entries = [];
            for (const e of data.notifications ?? []) {
                if (!(e.time > cutoff))
                    continue;
                if (e.liveId && liveIds.has(e.liveId)) {
                    // Still live after a hot reload: just recover its timestamp.
                    receivedAt[e.liveId] = e.time;
                    continue;
                }
                entries.push(makeEntry(e));
            }
            history = entries.slice(0, keepCount);
        } catch (err) {
            console.warn("notifications: could not read saved state:", err);
        }
        restored = true;
    }

    function save() {
        if (!restored)
            return;
        const live = server.trackedNotifications.values.slice().reverse().map(n => ({
                    liveId: n.id,
                    time: receivedAt[n.id] ?? Date.now(),
                    appName: n.appName,
                    summary: n.summary,
                    body: n.body,
                    appIcon: n.appIcon,
                    image: persistableImage(n.image),
                    desktopEntry: n.desktopEntry,
                    urgency: n.urgency
                }));
        const past = history.map(h => ({
                    time: receivedAt[h.id],
                    appName: h.appName,
                    summary: h.summary,
                    body: h.body,
                    appIcon: h.appIcon,
                    image: h.image,
                    desktopEntry: h.desktopEntry,
                    urgency: h.urgency
                }));
        store.setText(JSON.stringify({
            version: 1,
            dnd: dnd,
            notifications: live.concat(past).slice(0, keepCount)
        }, null, 1));
    }

    // Debounced: a burst of notifications means one write.
    Timer {
        id: saveTimer
        interval: 500
        onTriggered: root.save()
    }

    onListChanged: if (restored)
        saveTimer.restart()
    onDndChanged: if (restored)
        saveTimer.restart()

    FileView {
        id: store
        path: root.stateFile
        printErrors: false
        atomicWrites: true

        onLoaded: root.restore(text())
        // First run: no file yet; create the directory for the first save.
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }

    // qs -c nyx ipc call notifications <toggle|clear|toggleDnd>
    IpcHandler {
        target: "notifications"

        function toggle(): void {
            root.toggleCenter();
        }
        function clear(): void {
            root.clearAll();
        }
        function toggleDnd(): void {
            root.dnd = !root.dnd;
        }
    }
}
