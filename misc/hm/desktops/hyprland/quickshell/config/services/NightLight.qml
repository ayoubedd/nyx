pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Night light via the running hyprsunset (services.hyprsunset in
// hyprland.nix), controlled through `hyprctl hyprsunset ...`.
//
// The schedule lives here (hyprsunset has no profiles any more):
//   off      only manual
//   sunset   on at sunset, off at sunrise; today's times come from the
//            weather lookup (Weather.qml, by IP location), remembered for
//            offline starts; 19:00-07:00 until the first lookup
//   custom   on at `from`, off at `to` (may cross midnight)
// It turns on with `nightTemp`, the warmth you last chose. A manual change
// lasts until the schedule's next switch, like before.
// Settings: $XDG_STATE_HOME/nyx/nightlight.json.
//
//   qs -c nyx ipc call nightlight toggle
Singleton {
    id: root

    readonly property int neutral: 6000 // K; hyprsunset's identity
    readonly property int warmest: 2500 // K; slider limit

    property int temperature: neutral
    readonly property bool on: temperature < neutral - 50

    // 0 (neutral) .. 1 (warmest), for the slider.
    readonly property real warmth: Math.max(0, Math.min(1, (neutral - temperature) / (neutral - warmest)))

    // ---- settings (saved) ----
    property string mode: "custom" // "off" | "sunset" | "custom"
    property int from: 21 * 60 // custom: minutes after midnight
    property int to: 7 * 60 + 30
    property int nightTemp: 4000 // K when it turns on
    property int lastSunrise: -1 // remembered from the weather lookup
    property int lastSunset: -1

    // Effective sunset/sunrise (weather > remembered > fallback).
    readonly property int sunrise: Weather.sunrise >= 0 ? Weather.sunrise : lastSunrise >= 0 ? lastSunrise : 7 * 60
    readonly property int sunset: Weather.sunset >= 0 ? Weather.sunset : lastSunset >= 0 ? lastSunset : 19 * 60
    readonly property bool sunKnown: Weather.sunset >= 0 || lastSunset >= 0

    // Today's on/off times for the current mode (-1 = no schedule).
    readonly property int onAt: mode === "sunset" ? sunset : mode === "custom" ? from : -1
    readonly property int offAt: mode === "sunset" ? sunrise : mode === "custom" ? to : -1

    property real now: Date.now()
    readonly property bool scheduledOn: {
        if (onAt < 0)
            return false;
        const d = new Date(now);
        const m = d.getHours() * 60 + d.getMinutes();
        return onAt <= offAt ? m >= onAt && m < offAt : m >= onAt || m < offAt;
    }

    function clockText(minutes) {
        return `${String(Math.floor(minutes / 60)).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`;
    }

    // "On until 07:12" / "Turns on at 17:43" / "" (no schedule).
    readonly property string scheduleText: {
        if (onAt < 0)
            return "";
        return scheduledOn ? `Scheduled until ${clockText(offAt)}` : `Turns on at ${clockText(onAt)}`;
    }

    function setTemperature(k) {
        temperature = Math.round(Math.max(warmest, Math.min(neutral, k)) / 50) * 50;
        pending.restart();
    }

    function setWarmth(v) {
        setTemperature(neutral - v * (neutral - warmest));
        // Remember the chosen warmth for the next time it turns on.
        if (on)
            nightTemp = temperature;
        markManual();
    }

    function toggle() {
        setTemperature(on ? neutral : nightTemp);
        markManual();
    }

    // ---- manual override ----
    // A manual change is saved with its time, so a quickshell restart (or
    // hot reload) keeps it until the schedule's next switch instead of
    // snapping back to the schedule.
    property real manualAt: 0 // ms; 0 = following the schedule
    property int manualTemp: neutral

    function markManual() {
        manualAt = Date.now();
        manualTemp = temperature;
        save();
    }

    // Did an on/off switch time of the schedule pass between t0 and t1 (ms)?
    function switchedBetween(t0, t1) {
        for (const minutes of [onAt, offAt]) {
            if (minutes < 0)
                continue;
            const d = new Date(t0);
            d.setHours(Math.floor(minutes / 60), minutes % 60, 0, 0);
            if (d.getTime() <= t0)
                d.setDate(d.getDate() + 1);
            if (d.getTime() <= t1)
                return true;
        }
        return false;
    }

    function setMode(m) {
        mode = m;
        apply();
        save();
    }

    function setTimes(f, t) {
        from = f;
        to = t;
        apply();
        save();
    }

    // Match the schedule now (when it changes or flips). Drops a manual
    // override.
    function apply() {
        manualAt = 0;
        if (onAt < 0)
            return;
        setTemperature(scheduledOn ? nightTemp : neutral);
    }

    // On start: keep a manual change the schedule hasn't switched past yet.
    function restore() {
        if (manualAt > 0 && onAt >= 0 && !switchedBetween(manualAt, Date.now()))
            setTemperature(manualTemp);
        else if (manualAt > 0 && onAt < 0)
            setTemperature(manualTemp); // "off" mode: manual only
        else {
            apply();
            save();
        }
    }

    function refresh() {
        read.running = true;
    }

    // The schedule flips: switch, overriding a manual change made before the
    // switch time. scheduledOn also flips when the times themselves change
    // (sun times arriving from Weather, a refresh); a manual change made
    // after the last real switch time is kept then (same test as restore()).
    onScheduledOnChanged: if (restored) {
        if (manualAt > 0 && !switchedBetween(manualAt, Date.now()))
            return;
        apply();
        save();
    }

    // Remember today's sun times for offline starts.
    Connections {
        target: Weather
        function onSunsetChanged() {
            if (Weather.sunset >= 0 && Weather.sunrise >= 0 && (Weather.sunset !== root.lastSunset || Weather.sunrise !== root.lastSunrise)) {
                root.lastSunset = Weather.sunset;
                root.lastSunrise = Weather.sunrise;
                root.save();
            }
        }
    }

    Timer {
        running: true
        interval: 60000
        repeat: true
        onTriggered: root.now = Date.now()
    }

    // ---- hyprsunset ----

    // Coalesce slider drags into one hyprctl call per ~80ms.
    Timer {
        id: pending
        interval: 80
        onTriggered: {
            if (root.temperature >= root.neutral)
                Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
            else
                Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(root.temperature)]);
        }
    }

    Process {
        id: read
        command: ["hyprctl", "hyprsunset", "temperature"]
        // hyprctl prints the value without a trailing newline, so collect the
        // whole output (a SplitParser would never see a complete line).
        stdout: StdioCollector {
            onStreamFinished: {
                const k = parseInt(text);
                if (k > 0 && !pending.running)
                    root.temperature = k;
            }
        }
    }

    // Stay in sync (another tool may change it): every 30s while the control
    // center is open, every 5 min otherwise; not while locked (re-reads on
    // unlock). The schedule tick above keeps running, so a scheduled switch
    // still happens behind the lock screen.
    Timer {
        running: !Ui.locked
        interval: Notifs.centerOpen ? 30000 : 300000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // ---- persistence ----
    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/nightlight.json`
    property bool restored: false

    function save() {
        if (!restored)
            return;
        store.setText(JSON.stringify({
            mode: mode,
            from: from,
            to: to,
            nightTemp: nightTemp,
            lastSunrise: lastSunrise,
            lastSunset: lastSunset,
            manualAt: manualAt,
            manualTemp: manualTemp
        }));
    }

    FileView {
        id: store
        path: root.stateFile
        printErrors: false
        atomicWrites: true

        onLoaded: {
            try {
                const s = JSON.parse(text());
                root.mode = s.mode ?? root.mode;
                root.from = s.from ?? root.from;
                root.to = s.to ?? root.to;
                root.nightTemp = s.nightTemp ?? root.nightTemp;
                root.lastSunrise = s.lastSunrise ?? -1;
                root.lastSunset = s.lastSunset ?? -1;
                root.manualAt = s.manualAt ?? 0;
                root.manualTemp = s.manualTemp ?? root.neutral;
            } catch (e) {}
            root.restored = true;
            root.restore();
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
            root.restore();
        }
    }

    IpcHandler {
        target: "nightlight"

        function toggle(): void {
            root.toggle();
        }
        function set(kelvin: int): void {
            root.setTemperature(kelvin);
            root.markManual();
        }
        function isOn(): bool {
            return root.on;
        }
        function status(): string {
            return `${root.on ? "on" : "off"} ${root.temperature}K · mode ${root.mode} · ${root.scheduleText} · sun ${root.clockText(root.sunrise)}-${root.clockText(root.sunset)}`;
        }
    }
}
