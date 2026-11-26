pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU and memory load for the bar's load pill (bar/LoadWidget.qml): it shows
// only while the machine is under sustained load.
//
//   CPU     shows after `cpuHigh` for `sustain` (a short spike doesn't count),
//           hides after `cpuLow` for `sustain`
//   memory  shows above `memHigh`, hides below `memLow`
// (The gaps between show/hide levels stop it flickering at a threshold.)
//
// Sampled every 5 s by reading /proc/stat and /proc/meminfo in-process (no
// processes started). Can be turned off (saved): `enabled`.
Singleton {
    id: root

    property bool enabled: true

    readonly property real cpuHigh: 0.70
    readonly property real cpuLow: 0.50
    readonly property real memHigh: 0.85
    readonly property real memLow: 0.80
    readonly property int sustain: 20000 // ms
    readonly property int interval: 5000

    property real cpu: 0 // 0..1, over the last interval
    property real mem: 0 // 0..1 used (MemTotal - MemAvailable)
    property real memUsed: 0 // bytes
    property real memTotal: 0

    property bool cpuAlert: false
    property bool memAlert: false
    readonly property bool alert: enabled && (cpuAlert || memAlert)

    property var lastCpu: null // [idle, total]
    property real highSince: 0 // when CPU went above cpuHigh (0 = it isn't)
    property real lowSince: 0 // when CPU went below cpuLow

    function sampleCpu(text) {
        const f = text.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = f[3] + (f[4] || 0);
        const total = f.reduce((a, b) => a + b, 0);
        if (lastCpu && total > lastCpu[1])
            cpu = 1 - (idle - lastCpu[0]) / (total - lastCpu[1]);
        lastCpu = [idle, total];

        const now = Date.now();
        highSince = cpu >= cpuHigh ? (highSince || now) : 0;
        lowSince = cpu < cpuLow ? (lowSince || now) : 0;
        if (!cpuAlert && highSince && now - highSince >= sustain)
            cpuAlert = true;
        else if (cpuAlert && lowSince && now - lowSince >= sustain)
            cpuAlert = false;
    }

    function sampleMem(text) {
        const kb = key => Number((new RegExp(`^${key}:\\s+(\\d+)`, "m").exec(text) ?? [])[1] ?? 0) * 1024;
        memTotal = kb("MemTotal");
        memUsed = memTotal - kb("MemAvailable");
        mem = memTotal > 0 ? memUsed / memTotal : 0;
        if (!memAlert && mem >= memHigh)
            memAlert = true;
        else if (memAlert && mem < memLow)
            memAlert = false;
    }

    FileView {
        id: stat
        path: "/proc/stat"
        printErrors: false
        onLoaded: root.sampleCpu(text())
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        printErrors: false
        onLoaded: root.sampleMem(text())
    }

    // Paused while locked; after resuming, the first CPU sample only sets the
    // baseline (lastCpu reset), so the lock period doesn't skew the reading.
    Timer {
        running: root.enabled && !Ui.locked
        interval: root.interval
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
        onRunningChanged: if (!running) {
            root.lastCpu = null;
            root.highSince = 0;
            root.lowSince = 0;
        }
    }

    onEnabledChanged: {
        if (!enabled) {
            cpuAlert = false;
            memAlert = false;
            lastCpu = null;
            highSince = 0;
        }
        save();
    }

    // ---- persistence ----
    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/load-indicator.json`
    property bool restored: false

    function save() {
        if (restored)
            store.setText(JSON.stringify({
                enabled: enabled
            }));
    }

    FileView {
        id: store
        path: root.stateFile
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.enabled = JSON.parse(text()).enabled ?? true;
            } catch (e) {}
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }

    IpcHandler {
        target: "load"

        function status(): string {
            return `cpu ${Math.round(root.cpu * 100)}%${root.cpuAlert ? " (alert)" : ""} · mem ${Math.round(root.mem * 100)}%${root.memAlert ? " (alert)" : ""} · pill ${root.alert ? "shown" : "hidden"}${root.enabled ? "" : " (off)"}`;
        }
    }
}
