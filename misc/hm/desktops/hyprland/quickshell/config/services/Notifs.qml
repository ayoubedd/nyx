pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
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

    // ---- Do Not Disturb -------------------------------------------------
    // On when any of: turned on by hand, inside the schedule, or (optionally)
    // while the screen is being shared (Privacy.screen). Turning it off
    // during an automatic period snoozes that period until it ends; the next
    // one applies again. All of it is saved with the notification history.
    property bool dndManual: false
    property bool dndScheduleOn: false
    property int dndFrom: 22 * 60 // minutes after midnight
    property int dndTo: 7 * 60
    property bool dndWhileSharing: true
    property bool dndSnoozed: false // user turned an automatic period off
    // When that snooze runs out at the latest (epoch ms): the end of the
    // scheduled period it was taken in, so a restart can restore it without
    // it spilling into the next period. Saved with the rest.
    property real dndSnoozeUntil: 0

    readonly property bool dndInSchedule: {
        const d = new Date(now);
        const m = d.getHours() * 60 + d.getMinutes();
        return dndFrom <= dndTo ? m >= dndFrom && m < dndTo : m >= dndFrom || m < dndTo;
    }
    readonly property bool dndSharing: dndWhileSharing && Privacy.screen
    readonly property bool dndAuto: (dndScheduleOn && dndInSchedule) || dndSharing
    readonly property bool dnd: dndManual || (dndAuto && !dndSnoozed)

    // Why it's on (for the UI): "" when off.
    readonly property string dndReason: {
        if (!dnd)
            return "";
        if (dndManual)
            return "On";
        if (dndSharing)
            return "While sharing your screen";
        return `Scheduled until ${clockText(dndTo)}`;
    }

    function clockText(minutes) {
        return `${String(Math.floor(minutes / 60)).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`;
    }

    function toggleDnd() {
        if (dnd) {
            dndManual = false;
            if (dndAuto) {
                dndSnoozeUntil = snoozeEnd();
                dndSnoozed = true;
            }
        } else {
            dndManual = true;
        }
    }

    // End of the current automatic period: the next dndTo for a schedule,
    // otherwise (screen sharing) a few hours as an upper bound.
    function snoozeEnd() {
        const now = new Date();
        if (dndScheduleOn && dndInSchedule) {
            const end = new Date(now);
            end.setHours(Math.floor(dndTo / 60), dndTo % 60, 0, 0);
            if (end <= now)
                end.setDate(end.getDate() + 1);
            return end.getTime();
        }
        return now.getTime() + 4 * 3600000;
    }

    // An automatic period ended: the snooze is used up.
    onDndAutoChanged: if (!dndAuto)
        dndSnoozed = false
    onDndSnoozedChanged: {
        if (!dndSnoozed)
            dndSnoozeUntil = 0;
        if (restored)
            saveTimer.restart();
    }

    // ---- per-app rules ----
    // key (desktop entry / app name, as used for grouping) ->
    //   { rule: "silent" (center only, no popup) | "mute" (dropped), name }
    // Critical notifications ignore both, so nothing urgent can be muted.
    // Saved with the rest of the notification state.
    property var appRules: ({})

    function appKey(n) {
        return n?.desktopEntry || n?.appName || "unknown";
    }

    function appRule(n) {
        return appRules[appKey(n)]?.rule ?? "";
    }

    function setAppRule(key, rule, name) {
        const r = Object.assign({}, appRules);
        if (rule)
            r[key] = {
                rule: rule,
                name: name || r[key]?.name || key
            };
        else
            delete r[key];
        appRules = r;
        if (restored)
            saveTimer.restart();
    }

    property bool centerOpen: false
    // Detail view shown over the notification center ("" = none), e.g.
    // "caffeine" (ControlCenter.qml). Reset when the center closes.
    property string centerDetail: ""

    // ---- clicking a notification brings its app forward -------------------
    // Apps focus themselves through xdg-activation, which needs a token the
    // notification server would have to hand them (quickshell doesn't), and
    // Hyprland ignores tokenless requests (misc:focus_on_activate is off, so
    // apps can't steal focus). So the shell focuses the app's window itself:
    // the most recently used window whose class matches the notification's
    // desktop entry / app name.
    function appWindow(n) {
        const entry = DesktopEntries.heuristicLookup(n.desktopEntry || n.appName || "");
        const keys = [n.desktopEntry, n.appName, entry?.id, entry?.startupClass, entry?.name].filter(s => s).map(s => s.toLowerCase().replace(/\.desktop$/, ""));
        if (keys.length === 0)
            return null;
        const matches = Hyprland.toplevels.values.filter(t => {
            const cls = (t.lastIpcObject?.class || t.wayland?.appId || "").toLowerCase();
            // "org.gnome.Nautilus" also matches an app called "nautilus".
            return cls && keys.some(k => cls === k || cls.endsWith(`.${k}`) || k.endsWith(`.${cls}`));
        });
        return matches.sort((a, b) => (a.lastIpcObject?.focusHistoryID ?? 99) - (b.lastIpcObject?.focusHistoryID ?? 99))[0] ?? null;
    }

    function focusApp(n) {
        const t = appWindow(n);
        if (!t)
            return;
        const a = HyprDispatch.address(t);
        // The center holds the keyboard; Hyprland won't focus a window until
        // it lets go, so close it first.
        centerOpen = false;
        focusLater.address = a;
        focusLater.restart();
    }

    Timer {
        id: focusLater
        property string address: ""
        interval: 80
        onTriggered: Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address}" })`)
    }

    function openCenterAt(detail) {
        centerDetail = detail;
        centerOpen = true;
    }

    // Notifications currently shown as popups (a subset of `list`).
    property var popups: []

    // Restored, read-only entries (notification-shaped plain objects).
    property var history: []

    // Newest first: live notifications, then restored history.
    readonly property var list: server.trackedNotifications.values.slice().reverse().concat(history)
    readonly property int count: list.length

    // Grouped by app, newest group first (macOS-style stacks):
    // [{ key, appName, notifications: [newest, ...] }]
    function groupBy(notifications) {
        const map = new Map();
        for (const n of notifications) {
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

    readonly property var groups: groupBy(list)

    // The popups, stacked the same way (NotificationPopups.qml).
    readonly property var popupGroups: groupBy(popups)

    // Popup stacks the user fanned out (they stop auto-hiding while open).
    property var popupExpanded: []

    function isPopupExpanded(key) {
        return popupExpanded.includes(key);
    }

    function setPopupExpanded(key, on) {
        const rest = popupExpanded.filter(k => k !== key);
        popupExpanded = on ? [...rest, key] : rest;
    }

    // A popup stack timed out: the whole stack goes back into the center
    // (transient ones expire, as they would on their own). Critical ones
    // never time out, so they stay up (alone, if the rest went).
    function hidePopupGroup(key) {
        const group = popupGroups.find(g => g.key === key);
        for (const n of group?.notifications.slice() ?? []) {
            if (n.urgency === NotificationUrgency.Critical)
                continue;
            if (n.transient)
                n.expire();
            else
                hidePopup(n);
        }
        setPopupExpanded(key, false);
    }

    // ✕ on a popup stack: dismiss the notifications it shows.
    function dismissPopupGroup(key) {
        const group = popupGroups.find(g => g.key === key);
        for (const n of group?.notifications.slice() ?? [])
            n.dismiss();
        setPopupExpanded(key, false);
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

    // ---- repeats ------------------------------------------------------------
    // The same app posting the same summary + body again (within 10 min,
    // while the earlier one is still around) replaces it instead of adding
    // another: one notification with a counter ("×3"). A repeat only pops up
    // again if the earlier one was still showing as a popup.
    property var repeats: ({}) // notification id -> times seen
    readonly property real repeatWindow: 10 * 60000

    function repeatKey(n) {
        return `${n.appName}\u0000${n.summary}\u0000${n.body}`;
    }

    function repeatCount(n) {
        return repeats[n?.id] ?? 1;
    }

    // ---- the fullscreen app's own notifications ------------------------------
    // No popup from the app that's playing video fullscreen (it goes
    // straight to the center). Only while it plays: a fullscreen terminal or
    // editor is just how you work, and its notifications should pop up.
    // Critical ones always pop up.
    function fromFullscreenApp(n) {
        const t = ToplevelManager.activeToplevel;
        if (!t?.fullscreen || !Caffeine.fullscreenVideo)
            return false;
        const app = (t.appId ?? "").toLowerCase();
        const short = app.split(".").pop();
        if (!short)
            return false;
        const entry = (n.desktopEntry ?? "").toLowerCase().replace(/\.desktop$/, "");
        const name = (n.appName ?? "").toLowerCase();
        return entry === app || entry === short || entry.split(".").pop() === short || name === short || name.replace(/\s+/g, "") === short;
    }

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
        if (popups.length === 0)
            popupExpanded = [];
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
            popupExpanded = [];
            Ui.closeAll();
        } else {
            expanded = [];
            centerDetail = "";
        }
    }

    // Relative times ("5 min ago") and the DND schedule boundary. Keeps
    // ticking while locked (in-process, cheap), so scheduled DND starts and
    // ends on time behind the lock screen too.
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
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

            const critical = n.urgency === NotificationUrgency.Critical;
            const rule = critical ? "" : root.appRule(n);
            // Muted app: drop it (nothing in the center either).
            if (rule === "mute") {
                Qt.callLater(() => n.dismiss());
                return;
            }
            // Same text again from the same app: replace the earlier one.
            const key = root.repeatKey(n);
            const earlier = server.trackedNotifications.values.find(o => o !== n && root.repeatKey(o) === key && Date.now() - (root.receivedAt[o.id] ?? 0) < root.repeatWindow);
            let repeatSilent = false;
            if (earlier) {
                const counts = Object.assign({}, root.repeats);
                counts[n.id] = (counts[earlier.id] ?? 1) + 1;
                delete counts[earlier.id];
                root.repeats = counts;
                repeatSilent = !root.popups.includes(earlier);
            }

            // DND, an app set to "center only", a repeat that wasn't showing,
            // or the app that's fullscreen right now: no popup.
            const silenced = (root.dnd && !critical) || rule === "silent" || (!critical && (repeatSilent || root.fromFullscreenApp(n)));
            if (!root.centerOpen && !silenced)
                root.popups = [n, ...root.popups];
            if (earlier)
                Qt.callLater(() => earlier.dismiss());

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
            dndManual = !!data.dnd;
            const s = data.dndSchedule ?? {};
            dndScheduleOn = !!s.on;
            dndFrom = s.from ?? dndFrom;
            dndTo = s.to ?? dndTo;
            dndWhileSharing = data.dndWhileSharing ?? dndWhileSharing;
            if ((data.dndSnoozeUntil ?? 0) > Date.now()) {
                dndSnoozeUntil = data.dndSnoozeUntil;
                dndSnoozed = true;
            }
            appRules = data.appRules ?? {};
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
            dnd: dndManual,
            dndSchedule: {
                on: dndScheduleOn,
                from: dndFrom,
                to: dndTo
            },
            dndWhileSharing: dndWhileSharing,
            dndSnoozeUntil: dndSnoozed ? dndSnoozeUntil : 0,
            appRules: appRules,
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
    // DND settings (not the computed on/off state).
    onDndManualChanged: if (restored)
        saveTimer.restart()
    onDndScheduleOnChanged: if (restored)
        saveTimer.restart()
    onDndFromChanged: if (restored)
        saveTimer.restart()
    onDndToChanged: if (restored)
        saveTimer.restart()
    onDndWhileSharingChanged: if (restored)
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
        // Open the center on a detail view: sound | wifi | bluetooth |
        // display | nightlight | dnd | caffeine | power
        function openDetail(name: string): void {
            root.openCenterAt(name);
        }
        function clear(): void {
            root.clearAll();
        }
        function toggleDnd(): void {
            root.toggleDnd();
        }
        // app = desktop entry or app name; rule = silent | mute | "" (clear)
        function setAppRule(app: string, rule: string): void {
            root.setAppRule(app, rule, app);
        }
        function status(): string {
            const rules = Object.keys(root.appRules).map(k => `${k}=${root.appRules[k].rule}`).join(", ");
            const t = ToplevelManager.activeToplevel;
            return `${root.count} in center · ${root.popups.length} popups · dnd ${root.dnd} · center ${root.centerOpen ? "open" : "closed"} · fullscreen ${t?.fullscreen ? t.appId : "none"} · rules: ${rules || "none"}`;
        }
    }

    // Keybinds (hypr/binds.lua notifications submap: hl.dsp.global("nyx:<name>")).
    GlobalShortcut {
        appid: "nyx"
        name: "notifications-toggle"
        description: "Toggle the notification center"
        onPressed: root.toggleCenter()
    }
    GlobalShortcut {
        appid: "nyx"
        name: "notifications-clear"
        description: "Clear all notifications"
        onPressed: root.clearAll()
    }
    GlobalShortcut {
        appid: "nyx"
        name: "notifications-dnd"
        description: "Toggle Do Not Disturb"
        onPressed: root.toggleDnd()
    }
}
