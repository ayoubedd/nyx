import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.common
import qs.services
import "search.js" as Search

// Launcher: apps, commands, calculator, windows, clipboard history, emoji.
//
//   qs -c nyx ipc call launcher toggle          search (apps + commands)
//   qs -c nyx ipc call launcher clipboard       clipboard history
//   qs -c nyx ipc call launcher emoji           emoji picker
//   qs -c nyx ipc call launcher windows         window switcher
//
// Keys: ↑↓ (Ctrl+N/P) select · ↵ primary action · Ctrl+↵ secondary ·
// Ctrl+K all actions · Shift+Del remove · Tab / Shift+Tab switch view ·
// Backspace on an empty query goes back · Esc back / close.
// In search, ">cmd" runs a shell command; math shows a result.
Scope {
    id: root

    property bool open: false
    property string mode: "search" // search | clipboard | emoji | windows
    property string openedMode: "search"
    property string query: ""
    property int current: 0
    property string targetClass: "" // focused window when opened (paste keys)
    property string armed: "" // "<key>/<action>" waiting for a second ↵
    property bool actionsOpen: false
    property int actionIndex: 0

    readonly property var modes: [
        {
            id: "search",
            label: "Search",
            icon: "search",
            placeholder: "Search apps and commands…"
        },
        {
            id: "clipboard",
            label: "Clipboard",
            icon: "content_paste",
            placeholder: "Search clipboard history…"
        },
        {
            id: "emoji",
            label: "Emoji",
            icon: "mood",
            placeholder: "Search emoji…"
        },
        {
            id: "windows",
            label: "Windows",
            icon: "tab",
            placeholder: "Search open windows…"
        }
    ]
    readonly property var modeInfo: modes.find(m => m.id === mode) ?? modes[0]

    // ---- open / close ------------------------------------------------------

    function show(m) {
        if (!modes.some(x => x.id === m))
            m = "search";
        Ui.closeAll();
        Notifs.centerOpen = false;
        const t = Hyprland.activeToplevel;
        targetClass = t?.wayland?.appId || t?.lastIpcObject?.class || "";
        openedMode = m;
        setMode(m, "");
        TunedProfiles.refresh();
        open = true;
    }

    function close() {
        open = false;
        actionsOpen = false;
        armed = "";
    }

    function toggle(m) {
        if (open && mode === m)
            close();
        else
            show(m);
    }

    function setMode(m, q) {
        mode = m;
        query = q ?? "";
        armed = "";
        actionsOpen = false;
        if (m === "clipboard")
            Clipboard.refresh();
        if (m === "windows" || m === "search")
            Hyprland.refreshToplevels();
        selectFirst();
    }

    function cycleMode(delta) {
        const i = modes.findIndex(m => m.id === mode);
        setMode(modes[(i + delta + modes.length) % modes.length].id, "");
    }

    // Esc / Backspace-on-empty: back to search if we came from there.
    function back() {
        if (actionsOpen)
            actionsOpen = false;
        else if (mode !== openedMode)
            setMode(openedMode, "");
        else
            close();
    }

    // Run `fn` once the launcher has closed and given the keyboard back.
    function later(fn, delay) {
        laterTimer.fn = fn;
        laterTimer.interval = delay ?? 150;
        laterTimer.restart();
    }

    Timer {
        id: laterTimer
        property var fn: null
        onTriggered: {
            const f = fn;
            fn = null;
            if (f)
                f();
        }
    }

    function ipc(args, delay) {
        later(() => Quickshell.execDetached(["qs", "-c", "nyx", "ipc", "call", ...args]), delay ?? 220);
    }

    // ---- selection ---------------------------------------------------------

    // Only built while the launcher is on screen.
    readonly property var items: !win.visible ? [] : mode === "clipboard" ? clipboardItems() : mode === "emoji" ? emojiItems() : mode === "windows" ? windowItems() : searchItems()
    readonly property var selected: items[current] ?? null
    readonly property var selectedActions: selected?.actions ?? []

    // Keep the selected entry across list updates (e.g. after deleting a
    // clipboard entry the next one is selected); a new query starts at the top.
    property string selectedKey: ""
    property string itemsQuery: ""

    onItemsChanged: {
        if (query !== itemsQuery) {
            itemsQuery = query;
            selectFirst();
            return;
        }
        const i = items.findIndex(it => !it.header && it.key === selectedKey);
        current = i >= 0 ? i : Math.min(current, lastSelectable());
        if (items[current]?.header)
            selectFirst();
    }

    onCurrentChanged: {
        selectedKey = items[current]?.key ?? "";
        armed = "";
        actionsOpen = false;
        // Keep the selection in view (the emoji grid does its own).
        if (mode === "emoji")
            return;
        const view = mode === "clipboard" ? clipList : list;
        if (current <= 1)
            view.positionViewAtBeginning();
        else
            view.positionViewAtIndex(current, ListView.Contain);
    }

    function selectFirst() {
        const i = items.findIndex(it => !it.header);
        current = Math.max(0, i);
        selectedKey = items[current]?.key ?? "";
    }

    function lastSelectable() {
        for (let i = items.length - 1; i >= 0; i--)
            if (!items[i].header)
                return i;
        return 0;
    }

    function move(delta) {
        if (items.length === 0)
            return;
        let i = current;
        const step = delta > 0 ? 1 : -1;
        for (let n = Math.abs(delta); n > 0; n--) {
            let j = i + step;
            while (j >= 0 && j < items.length && items[j].header)
                j += step;
            if (j < 0 || j >= items.length)
                break;
            i = j;
        }
        current = i;
    }

    // ---- actions -----------------------------------------------------------
    // action: { label, icon, run, stay (keep open), confirm (2nd ↵), remove }

    // Actions with `confirm` need a second activation of the *same* action.
    // From the Ctrl+K menu the menu stays open with that row asking for
    // confirmation (closing it would hand the next ↵ to the primary action).
    function runAction(item, action, fromMenu) {
        if (!item || !action)
            return;
        if (action.confirm) {
            const key = `${item.key}/${action.label}`;
            if (armed !== key) {
                armed = key;
                if (!fromMenu)
                    actionsOpen = false;
                return;
            }
        }
        armed = "";
        actionsOpen = false;
        if (!action.stay)
            close();
        action.run();
    }

    function runRemove() {
        const a = selectedActions.find(x => x.remove);
        if (!a)
            return;
        // Select the next entry once this one is gone.
        const next = items[current + 1] ?? items[current - 1];
        selectedKey = next && !next.header ? next.key : "";
        runAction(selected, a);
    }

    // ---- apps --------------------------------------------------------------

    readonly property var apps: {
        const seen = new Set();
        return DesktopEntries.applications.values.filter(e => !e.noDisplay && e.name && !seen.has(e.id) && seen.add(e.id)).sort((a, b) => a.name.localeCompare(b.name));
    }

    function desktopId(e) {
        return e.id.endsWith(".desktop") ? e.id : `${e.id}.desktop`;
    }

    // Through uwsm, like the keybinds, so apps get their own systemd scope.
    function launch(e, action) {
        LauncherStore.record("app", e.id);
        if (e.runInTerminal)
            Quickshell.execDetached(["uwsm", "app", "--", "kitty", "-e", ...(action?.command ?? e.command)]);
        else
            Quickshell.execDetached(["uwsm", "app", "--", action ? `${desktopId(e)}:${action.id}` : desktopId(e)]);
    }

    function appItem(e, section) {
        const pinned = LauncherStore.isPinned(e.id);
        const actions = [
            {
                label: "Open",
                icon: "open_in_new",
                run: () => launch(e)
            }
        ];
        for (const a of e.actions)
            actions.push({
                label: a.name,
                icon: "arrow_outward",
                run: () => launch(e, a)
            });
        actions.push({
            label: pinned ? "Unpin" : "Pin to top",
            icon: "keep",
            stay: true,
            run: () => LauncherStore.togglePin(e.id)
        });
        if (pinned && section === "pinned") {
            actions.push({
                label: "Move up",
                icon: "arrow_upward",
                stay: true,
                run: () => LauncherStore.movePin(e.id, -1)
            });
            actions.push({
                label: "Move down",
                icon: "arrow_downward",
                stay: true,
                run: () => LauncherStore.movePin(e.id, 1)
            });
        }
        if (LauncherStore.frecency("app", e.id) > 0)
            actions.push({
                label: "Reset ranking",
                icon: "restart_alt",
                stay: true,
                remove: section === "recent",
                run: () => LauncherStore.forget("app", e.id)
            });
        return {
            key: `app:${e.id}`,
            title: e.name,
            subtitle: e.genericName && e.genericName !== e.name ? e.genericName : e.comment,
            appIcon: e.icon || "application-x-executable",
            accessory: pinned ? "Pinned" : "Application",
            actions: actions
        };
    }

    // ---- commands ----------------------------------------------------------

    function command(id, title, icon, subtitle, run, extra) {
        return Object.assign({
            key: `cmd:${id}`,
            cmdId: id,
            title: title,
            subtitle: subtitle,
            icon: icon,
            accessory: "Command",
            keywords: "",
            actions: [
                {
                    label: extra?.label ?? "Run",
                    icon: "play_arrow",
                    stay: !!extra?.stay,
                    confirm: !!extra?.confirm,
                    run: () => {
                        LauncherStore.record("cmd", id);
                        run();
                    }
                }
            ]
        }, extra ?? {});
    }

    function toggleCommand(id, title, icon, on, run, keywords) {
        return command(id, title, icon, on ? "On" : "Off", run, {
            label: on ? "Turn off" : "Turn on",
            tint: on ? Theme.accent : undefined,
            keywords: `toggle ${keywords ?? ""}`
        });
    }

    function commands() {
        const bt = Bluetooth.defaultAdapter;
        return [command("clipboard", "Clipboard History", "content_paste", "Browse and paste copied items", () => setMode("clipboard", ""), {
                stay: true,
                label: "Open",
                keywords: "copy paste history cliphist"
            }), command("emoji", "Emoji Picker", "mood", "Search and paste emoji", () => setMode("emoji", ""), {
                stay: true,
                label: "Open",
                keywords: "emoticon smiley symbols"
            }), command("windows", "Switch Windows", "tab", "Jump to an open window", () => setMode("windows", ""), {
                stay: true,
                label: "Open",
                keywords: "window switcher focus alt tab"
            }), command("overview", "Workspace Overview", "grid_view", "All workspaces with live previews", () => ipc(["overview", "toggle"]), {
                keywords: "expose mission control"
            }), command("screenshot", "Take Screenshot", "screenshot_region", "Area, window or screen", () => ipc(["screenshot", "open"], 300), {
                keywords: "capture screen grab print snip"
            }), command("colorpicker", "Pick Color", "colorize", "Copy a color from the screen", () => later(() => Quickshell.execDetached(["hyprpicker", "-a"]), 250), {
                keywords: "eyedropper hex colour"
            }), command("notifications", "Notification Center", "notifications", "Controls and notifications", () => later(() => Notifs.centerOpen = true), {
                label: "Open",
                keywords: "control center"
            }), toggleCommand("dnd", "Do Not Disturb", "do_not_disturb_on", Notifs.dnd, () => Notifs.dnd = !Notifs.dnd, "dnd focus silence notifications"), toggleCommand("caffeine", "Keep Awake", "coffee", Caffeine.active, () => Caffeine.toggle(), "caffeine sleep idle inhibit"), toggleCommand("nightlight", "Night Light", "nightlight", NightLight.on, () => NightLight.toggle(), "warm blue light hyprsunset"), toggleCommand("wifi", "Wi-Fi", "wifi", Networking.wifiEnabled, () => Networking.wifiEnabled = !Networking.wifiEnabled, "wireless network wlan"), toggleCommand("bluetooth", "Bluetooth", "bluetooth", bt?.enabled ?? false, () => {
                if (bt)
                    bt.enabled = !bt.enabled;
            }, "bt"), command("lock", "Lock Screen", "lock", "", () => Quickshell.execDetached(["loginctl", "lock-session"]), {
                keywords: "screen lock"
            }), command("suspend", "Sleep", "bedtime", "Suspend the computer", () => Quickshell.execDetached(["systemctl", "suspend"]), {
                keywords: "suspend"
            }), command("logout", "Log Out", "logout", "End the session", () => Quickshell.execDetached(["uwsm", "stop"]), {
                confirm: true,
                keywords: "sign out exit quit session"
            }), command("reboot", "Restart", "restart_alt", "Restart the computer", () => Quickshell.execDetached(["systemctl", "reboot"]), {
                confirm: true,
                keywords: "reboot"
            }), command("poweroff", "Shut Down", "power_settings_new", "Power off the computer", () => Quickshell.execDetached(["systemctl", "poweroff"]), {
                confirm: true,
                keywords: "power off shutdown halt"
            }), command("clearclipboard", "Clear Clipboard History", "delete_sweep", "Delete every saved clipboard entry", () => Clipboard.wipe(), {
                confirm: true,
                keywords: "wipe clipboard cliphist"
            }), command("profile-auto", "Automatic Power Profile", "auto_mode", TunedProfiles.automatic ? `Active · ${TunedProfiles.label(TunedProfiles.autoProfile)}` : `Switch back to ${TunedProfiles.label(TunedProfiles.autoProfile)} for this power source`, () => TunedProfiles.setAutomatic(), {
                label: "Use automatic",
                tint: TunedProfiles.automatic ? Theme.accent : undefined,
                keywords: "power profile tuned auto battery ac"
            })].concat(TunedProfiles.profiles.map(p => command(`profile-${p.id}`, `${p.label} Profile`, p.icon, TunedProfiles.current === p.id ? `Active · ${p.detail}` : p.detail, () => TunedProfiles.set(p.id), {
                    label: "Switch",
                    tint: TunedProfiles.current === p.id ? Theme.accent : undefined,
                    keywords: `power profile tuned ${p.id}`
                })));
    }

    // ---- windows -----------------------------------------------------------

    function address(t) {
        const a = t?.address ?? "";
        return a.startsWith("0x") ? a : `0x${a}`;
    }

    function appIdOf(t) {
        return t?.wayland?.appId || t?.lastIpcObject?.class || "";
    }

    readonly property string noWarpScript: `
        orig=$(hyprctl -j getoption cursor:no_warps | jq -r 'if has("bool") then (if .bool then 1 else 0 end) else (.int // 0) end')
        hyprctl eval 'hl.config({ cursor = { no_warps = true } })' >/dev/null
        for d in "$@"; do
            hyprctl dispatch "$d" >/dev/null
        done
        sleep 0.3
        if [ "$orig" = 1 ]; then v=true; else v=false; fi
        hyprctl eval "hl.config({ cursor = { no_warps = $v } })" >/dev/null
    `

    function closeWindow(t) {
        const focused = Hyprland.activeToplevel;
        const d = [`hl.dsp.focus({ window = "address:${address(t)}" })`, `hl.dsp.window.close()`];
        if (focused && focused !== t)
            d.push(`hl.dsp.focus({ window = "address:${address(focused)}" })`);
        Quickshell.execDetached(["sh", "-c", noWarpScript, "sh", ...d]);
        refreshWindows.restart();
    }

    Timer {
        id: refreshWindows
        interval: 400
        onTriggered: Hyprland.refreshToplevels()
    }

    function windowItem(t) {
        const app = appIdOf(t);
        const entry = DesktopEntries.heuristicLookup(app);
        const ws = t.workspace;
        return {
            key: `win:${address(t)}`,
            title: t.title || entry?.name || app,
            subtitle: entry?.name || app,
            appIcon: entry?.icon || app,
            accessory: !ws ? "" : ws.id < 0 ? `Special: ${ws.name.replace(/^special:/, "")}` : `Workspace ${ws.id}`,
            actions: [
                {
                    label: "Switch to window",
                    icon: "open_in_new",
                    run: () => later(() => Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address(t)}" })`), 80)
                },
                {
                    label: "Close window",
                    icon: "close",
                    stay: true,
                    remove: true,
                    run: () => closeWindow(t)
                }
            ]
        };
    }

    // Most recently focused first.
    readonly property var windows: Hyprland.toplevels.values.filter(t => t.workspace).slice().sort((a, b) => (a.lastIpcObject?.focusHistoryID ?? 99) - (b.lastIpcObject?.focusHistoryID ?? 99))

    function windowItems() {
        const q = query.trim();
        if (!q)
            return windows.map(windowItem);
        return windows.map(t => ({
                    t: t,
                    s: Search.score(q, [[t.title, 1], [appIdOf(t), 0.9], [DesktopEntries.heuristicLookup(appIdOf(t))?.name ?? "", 0.9]])
                })).filter(x => x.s > 0).sort((a, b) => b.s - a.s).map(x => windowItem(x.t));
    }

    // ---- search (root) -----------------------------------------------------

    function header(title) {
        return {
            header: true,
            key: `header:${title}`,
            title: title
        };
    }

    function searchItems() {
        const q = query.trim();

        // ">cmd": run a shell command.
        if (q.startsWith(">")) {
            const cmd = q.slice(1).trim();
            if (!cmd)
                return [header("Type a command to run")];
            return [header("Shell"),
                {
                    key: "run",
                    title: cmd,
                    mono: true,
                    subtitle: "",
                    icon: "terminal",
                    accessory: "Shell command",
                    actions: [
                        {
                            label: "Run in terminal",
                            icon: "terminal",
                            run: () => Quickshell.execDetached(["uwsm", "app", "--", "kitty", "--hold", "sh", "-c", cmd])
                        },
                        {
                            label: "Run in background",
                            icon: "play_arrow",
                            run: () => Quickshell.execDetached(["uwsm", "app", "--", "sh", "-c", cmd])
                        }
                    ]
                }];
        }

        if (!q) {
            const out = [];
            const byId = id => apps.find(e => e.id === id);
            const pinned = LauncherStore.pinned.map(byId).filter(e => e);
            if (pinned.length) {
                out.push(header("Pinned"));
                for (const e of pinned)
                    out.push(appItem(e, "pinned"));
            }
            const recent = LauncherStore.top("app", 6).filter(id => !LauncherStore.isPinned(id)).map(byId).filter(e => e).slice(0, 5);
            if (recent.length) {
                out.push(header("Recent"));
                for (const e of recent)
                    out.push(appItem(e, "recent"));
            }
            out.push(header("Applications"));
            for (const e of apps)
                if (!LauncherStore.isPinned(e.id) && !recent.includes(e))
                    out.push(appItem(e, "all"));
            out.push(header("Commands"));
            return out.concat(commands());
        }

        const out = [];

        const value = Search.calculate(q);
        if (value !== null) {
            const shown = Search.formatNumber(value);
            const plain = Search.plainNumber(value);
            out.push(header("Calculator"));
            out.push({
                key: "calc",
                title: shown,
                subtitle: q,
                icon: "calculate",
                tint: Theme.accent,
                accessory: "Calculator",
                actions: [
                    {
                        label: "Copy result",
                        icon: "content_copy",
                        run: () => Clipboard.useText(plain, "", false)
                    },
                    {
                        label: "Paste result",
                        icon: "content_paste",
                        run: () => Clipboard.useText(plain, root.targetClass, true)
                    }
                ]
            });
        }

        const results = [];
        for (const e of apps) {
            let s = Search.score(q, [[e.name, 1], [e.genericName, 0.75], [e.keywords.join(" "), 0.65], [e.id, 0.6], [e.comment, 0.4]]);
            if (s > 0)
                results.push({
                    s: s + Math.min(15, LauncherStore.frecency("app", e.id)) + (LauncherStore.isPinned(e.id) ? 5 : 0),
                    item: () => appItem(e, "search")
                });
            for (const a of e.actions) {
                const sa = Search.score(q, [[`${e.name} ${a.name}`, 0.85], [a.name, 0.8]]);
                if (sa > 0)
                    results.push({
                        s: sa,
                        item: () => ({
                                key: `action:${e.id}:${a.id}`,
                                title: a.name,
                                subtitle: e.name,
                                appIcon: e.icon || "application-x-executable",
                                accessory: "App action",
                                actions: [
                                    {
                                        label: "Run",
                                        icon: "arrow_outward",
                                        run: () => launch(e, a)
                                    }
                                ]
                            })
                    });
            }
        }
        for (const c of commands()) {
            const s = Search.score(q, [[c.title, 1], [c.keywords, 0.7], [c.subtitle, 0.4]]);
            if (s > 0)
                results.push({
                    s: s + Math.min(15, LauncherStore.frecency("cmd", c.cmdId)),
                    item: () => c
                });
        }
        for (const t of windows) {
            const s = Search.score(q, [[t.title, 0.8], [appIdOf(t), 0.7]]);
            if (s > 0)
                results.push({
                    s: s * 0.85,
                    item: () => windowItem(t)
                });
        }
        results.sort((a, b) => b.s - a.s);
        if (results.length) {
            out.push(header("Results"));
            for (const r of results.slice(0, 30))
                out.push(r.item());
        }

        // Fallbacks: always offered at the end.
        out.push(header(`Use “${q}” with…`));
        out.push({
            key: "fallback:web",
            title: "Search the web",
            subtitle: q,
            icon: "travel_explore",
            accessory: "DuckDuckGo",
            actions: [
                {
                    label: "Search",
                    icon: "travel_explore",
                    run: () => Quickshell.execDetached(["xdg-open", `https://duckduckgo.com/?q=${encodeURIComponent(q)}`])
                }
            ]
        });
        out.push({
            key: "fallback:emoji",
            title: "Search emoji",
            subtitle: q,
            icon: "mood",
            accessory: "Emoji",
            actions: [
                {
                    label: "Search",
                    icon: "mood",
                    stay: true,
                    run: () => setMode("emoji", q)
                }
            ]
        });
        out.push({
            key: "fallback:clipboard",
            title: "Search clipboard history",
            subtitle: q,
            icon: "content_paste_search",
            accessory: "Clipboard",
            actions: [
                {
                    label: "Search",
                    icon: "content_paste_search",
                    stay: true,
                    run: () => setMode("clipboard", q)
                }
            ]
        });
        return out;
    }

    // ---- clipboard ---------------------------------------------------------

    function clipboardItems() {
        const words = query.toLowerCase().split(/\s+/).filter(w => w);
        return Clipboard.entries.filter(e => words.every(w => e.preview.toLowerCase().includes(w))).map(e => {
            const isLink = !e.isImage && /^\s*https?:\/\/\S+\s*$/.test(e.preview);
            return {
                key: `clip:${e.id}`,
                entry: e,
                title: e.isImage ? "Image" : e.preview.replace(/\s+/g, " ").trim() || "(whitespace)",
                subtitle: "",
                icon: e.isImage ? "image" : isLink ? "link" : "notes",
                accessory: e.isImage ? e.imageInfo : "",
                actions: [
                    {
                        label: "Paste",
                        icon: "content_paste",
                        run: () => Clipboard.use(e, root.targetClass, true)
                    },
                    {
                        label: "Copy",
                        icon: "content_copy",
                        run: () => Clipboard.use(e, "", false)
                    },
                    {
                        label: "Delete entry",
                        icon: "delete",
                        stay: true,
                        remove: true,
                        run: () => Clipboard.remove(e)
                    },
                    {
                        label: "Clear history",
                        icon: "delete_sweep",
                        stay: true,
                        confirm: true,
                        run: () => Clipboard.wipe()
                    }
                ]
            };
        });
    }

    // ---- emoji -------------------------------------------------------------

    function emojiItem(e, recent) {
        return {
            key: `emoji:${e.char}${recent ? ":recent" : ""}`,
            char: e.char,
            name: e.name,
            group: e.group,
            keywords: e.keywords,
            recent: recent,
            actions: [
                {
                    label: "Paste",
                    icon: "content_paste",
                    run: () => {
                        LauncherStore.record("emoji", e.char);
                        Clipboard.useText(e.char, root.targetClass, true);
                    }
                },
                {
                    label: "Copy",
                    icon: "content_copy",
                    run: () => {
                        LauncherStore.record("emoji", e.char);
                        Clipboard.useText(e.char, "", false);
                    }
                },
                {
                    label: "Copy name",
                    icon: "text_fields",
                    run: () => Clipboard.useText(e.name, "", false)
                }
            ]
        };
    }

    function emojiItems() {
        const q = query.trim();
        if (!q) {
            const recent = LauncherStore.recent("emoji", 2 * emojiView.columns).map(c => Emoji.byChar(c)).filter(e => e);
            return recent.map(e => emojiItem(e, true)).concat(Emoji.list.map(e => emojiItem(e, false)));
        }
        return Emoji.list.map(e => ({
                    e: e,
                    s: Search.score(q, [[e.name, 1], [e.keywords, 0.8]]) + Math.min(10, LauncherStore.frecency("emoji", e.char))
                })).filter(x => x.s > 0).sort((a, b) => b.s - a.s).slice(0, 400).map(x => emojiItem(x.e, false));
    }

    // ---- empty states ------------------------------------------------------

    readonly property string emptyText: {
        if (items.length > 0)
            return "";
        if (mode === "clipboard") {
            if (!Clipboard.available)
                return "cliphist isn't installed yet: rebuild to enable clipboard history";
            return query ? "No matching clipboard entries" : Clipboard.loading ? "" : "Clipboard history is empty";
        }
        if (mode === "emoji")
            return !Emoji.available ? "Emoji data is missing: rebuild (~/.local/share/nyx/emoji.json)" : "No emoji found";
        if (mode === "windows")
            return query ? "No matching windows" : "No open windows";
        return "No results";
    }

    // ---- IPC ---------------------------------------------------------------

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle("search");
        }
        function open(mode: string): void {
            root.show(mode);
        }
        function close(): void {
            root.close();
        }
        function clipboard(): void {
            root.toggle("clipboard");
        }
        function emoji(): void {
            root.toggle("emoji");
        }
        function windows(): void {
            root.toggle("windows");
        }
    }

    // ---- window ------------------------------------------------------------

    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.open || box.opacity > 0

        // No anchors: the compositor centers the surface on the screen.
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nyx-launcher"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"
        implicitWidth: 760
        implicitHeight: 500

        HyprlandFocusGrab {
            windows: [win]
            active: root.open
            onCleared: root.close()
        }

        Connections {
            target: root
            function onOpenChanged() {
                if (root.open)
                    Qt.callLater(() => input.forceActiveFocus());
            }
        }

        Rectangle {
            id: box
            anchors.fill: parent
            radius: 18
            color: Theme.background
            border.width: 1
            border.color: Theme.surfaceHigh
            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.97

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // ---- search bar ----
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 10

                    // Current view (click: back to search).
                    MouseArea {
                        id: modeChip
                        implicitWidth: chipRow.implicitWidth + (root.mode === "search" ? 0 : 20)
                        implicitHeight: 28
                        hoverEnabled: true
                        cursorShape: root.mode === "search" ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: if (root.mode !== "search")
                            root.setMode("search", "")

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            visible: root.mode !== "search"
                            color: modeChip.containsMouse ? Theme.glassTileHover : Theme.glassTile
                        }

                        Row {
                            id: chipRow
                            anchors.centerIn: parent
                            spacing: 6

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: root.modeInfo.icon
                                size: 20
                                color: root.mode === "search" ? Theme.foregroundDim : Theme.foreground
                            }

                            Text {
                                visible: root.mode !== "search"
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.modeInfo.label
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Font.DemiBold
                                color: Theme.foreground
                            }
                        }
                    }

                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        text: root.query
                        onTextChanged: root.query = text
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 3
                        color: Theme.foreground
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.background
                        clip: true
                        focus: true

                        Text {
                            visible: !input.text
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.modeInfo.placeholder
                            font: input.font
                            color: Theme.foregroundDim
                        }

                        Keys.onPressed: event => {
                            const ctrl = event.modifiers & Qt.ControlModifier;
                            const shift = event.modifiers & Qt.ShiftModifier;
                            const emoji = root.mode === "emoji";
                            const cols = emojiView.columns;

                            if (root.actionsOpen) {
                                const n = root.selectedActions.length;
                                if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_N)) {
                                    root.actionIndex = Math.min(n - 1, root.actionIndex + 1);
                                    root.armed = "";
                                } else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_P)) {
                                    root.actionIndex = Math.max(0, root.actionIndex - 1);
                                    root.armed = "";
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                                    root.runAction(root.selected, root.selectedActions[root.actionIndex], true);
                                else if (event.key === Qt.Key_Escape || (ctrl && event.key === Qt.Key_K)) {
                                    root.actionsOpen = false;
                                    root.armed = "";
                                } else
                                    return;
                                event.accepted = true;
                                return;
                            }

                            if (event.key === Qt.Key_Escape)
                                root.back();
                            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                                root.runAction(root.selected, root.selectedActions[ctrl ? 1 : 0]);
                            else if (ctrl && event.key === Qt.Key_K) {
                                if (root.selectedActions.length > 0) {
                                    root.actionIndex = 0;
                                    root.actionsOpen = true;
                                }
                            } else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_N))
                                root.move(emoji ? cols : 1);
                            else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_P))
                                root.move(emoji ? -cols : -1);
                            else if (emoji && event.key === Qt.Key_Right)
                                root.move(1);
                            else if (emoji && event.key === Qt.Key_Left)
                                root.move(-1);
                            else if (event.key === Qt.Key_PageDown)
                                root.move(emoji ? cols * 4 : 8);
                            else if (event.key === Qt.Key_PageUp)
                                root.move(emoji ? -cols * 4 : -8);
                            else if (event.key === Qt.Key_Tab)
                                root.cycleMode(1);
                            else if (event.key === Qt.Key_Backtab)
                                root.cycleMode(-1);
                            else if (shift && event.key === Qt.Key_Delete)
                                root.runRemove();
                            else if (event.key === Qt.Key_Backspace && !input.text && root.mode !== root.openedMode)
                                root.back();
                            else
                                return;
                            event.accepted = true;
                        }
                    }

                    Text {
                        visible: root.mode === "clipboard" && Clipboard.entries.length > 0
                        text: `${Clipboard.entries.length} items`
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.glassBorder
                }

                // ---- content ----
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Component {
                        id: rowDelegate

                        ResultRow {
                            required property var modelData
                            item: modelData
                            width: ListView.view.width
                            selected: index === root.current
                            notice: root.armed.startsWith(`${modelData.key}/`) ? "Press ↵ again to confirm" : ""
                            onHovered: i => root.current = i
                            onActivated: i => {
                                root.current = i;
                                root.runAction(root.selected, root.selectedActions[0]);
                            }
                        }
                    }

                    // Search / windows: one list.
                    ListView {
                        id: list
                        visible: root.mode === "search" || root.mode === "windows"
                        anchors.fill: parent
                        anchors.margins: 8
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: visible ? root.items : []
                        delegate: rowDelegate
                        currentIndex: root.current
                        highlightFollowsCurrentItem: false
                    }

                    // Clipboard: list + preview.
                    RowLayout {
                        // Nothing to list: only the empty-state message shows.
                        visible: root.mode === "clipboard" && root.items.length > 0
                        anchors.fill: parent
                        spacing: 0

                        ListView {
                            id: clipList
                            Layout.preferredWidth: parent.width * 0.46
                            Layout.fillHeight: true
                            Layout.margins: 8
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            model: parent.visible ? root.items : []
                            delegate: rowDelegate
                            currentIndex: root.current
                            highlightFollowsCurrentItem: false
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: Theme.glassBorder
                        }

                        ClipboardPreview {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            entry: root.mode === "clipboard" ? (root.selected?.entry ?? null) : null
                        }
                    }

                    EmojiGrid {
                        id: emojiView
                        visible: root.mode === "emoji"
                        anchors.fill: parent
                        anchors.margins: 10
                        model: visible ? root.items : []
                        current: root.current
                        browsing: !root.query
                        onHovered: i => root.current = i
                        onActivated: i => {
                            root.current = i;
                            root.runAction(root.selected, root.selectedActions[0]);
                        }
                    }

                    Text {
                        visible: root.emptyText !== ""
                        anchors.centerIn: parent
                        width: parent.width - 80
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: root.emptyText
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        color: Theme.foregroundDim
                    }

                    // Ctrl+K: every action of the selected entry.
                    Rectangle {
                        id: actionMenu
                        visible: root.actionsOpen
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        width: 270
                        height: actionColumn.implicitHeight + 12
                        radius: 12
                        color: Theme.surface
                        border.width: 1
                        border.color: Theme.glassBorder

                        Column {
                            id: actionColumn
                            x: 6
                            y: 6
                            width: parent.width - 12

                            Repeater {
                                model: root.actionsOpen ? root.selectedActions : []

                                MouseArea {
                                    id: actionRow
                                    required property var modelData
                                    required property int index

                                    width: actionColumn.width
                                    height: 32
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    readonly property bool confirming: root.armed === `${root.selected?.key}/${modelData.label}`

                                    onPositionChanged: if (root.actionIndex !== index) {
                                        root.actionIndex = index;
                                        root.armed = "";
                                    }
                                    onClicked: root.runAction(root.selected, modelData, true)

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 8
                                        color: actionRow.index === root.actionIndex ? Theme.surfaceHigh : "transparent"
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 10

                                        Icon {
                                            name: actionRow.modelData.icon ?? "chevron_right"
                                            size: 16
                                            color: actionRow.modelData.confirm || actionRow.modelData.remove ? Theme.urgent : Theme.foreground
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: actionRow.confirming ? `${actionRow.modelData.label}?` : actionRow.modelData.label
                                            elide: Text.ElideRight
                                            font.family: Theme.font
                                            font.pixelSize: Theme.fontSize - 1
                                            color: actionRow.modelData.confirm || actionRow.modelData.remove ? Theme.urgent : Theme.foreground
                                        }

                                        Text {
                                            text: actionRow.confirming ? "↵ again to confirm" : actionRow.index === 0 ? "↵" : actionRow.index === 1 ? "Ctrl ↵" : actionRow.modelData.remove ? "Shift Del" : ""
                                            font.family: Theme.font
                                            font.pixelSize: Theme.fontSize - 3
                                            color: Theme.foregroundDim
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.glassBorder
                }

                // ---- footer ----
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    Layout.leftMargin: 10
                    Layout.rightMargin: 12
                    spacing: 4

                    // View tabs.
                    Repeater {
                        model: root.modes

                        MouseArea {
                            id: tab
                            required property var modelData
                            readonly property bool active: root.mode === modelData.id

                            implicitWidth: tabRow.implicitWidth + 16
                            implicitHeight: 26
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setMode(modelData.id, "")

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: tab.active ? Theme.glassTileHover : tab.containsMouse ? Theme.glassTile : "transparent"
                            }

                            Row {
                                id: tabRow
                                anchors.centerIn: parent
                                spacing: 5

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: tab.modelData.icon
                                    filled: tab.active
                                    size: 14
                                    color: tab.active ? Theme.foreground : Theme.foregroundDim
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: tab.modelData.label
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSize - 3
                                    font.weight: tab.active ? Font.DemiBold : Font.Normal
                                    color: tab.active ? Theme.foreground : Theme.foregroundDim
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Primary action + actions menu hint.
                    Hint {
                        visible: root.selectedActions.length > 0
                        label: root.selectedActions[0]?.label ?? ""
                        keys: "↵"
                    }

                    Rectangle {
                        visible: root.selectedActions.length > 1
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 14
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        color: Theme.glassBorder
                    }

                    Hint {
                        visible: root.selectedActions.length > 1
                        label: "Actions"
                        keys: "Ctrl K"
                    }
                }
            }
        }
    }

    // Footer key hint: "Open [↵]".
    component Hint: Row {
        property string label
        property string keys
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.label
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: Theme.foreground
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: keyText.implicitWidth + 10
            height: 18
            radius: 5
            color: Theme.glassTile

            Text {
                id: keyText
                anchors.centerIn: parent
                text: parent.parent.keys
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 4
                color: Theme.foregroundDim
            }
        }
    }
}
