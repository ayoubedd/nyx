import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.common
import qs.services
import qs.components

// CPU / GPU / memory / swap / disk / temperature, polled every 2s while
// visible, and the processes using the most CPU (this user's; can end them).
//
// Process CPU % is per core (100% = one full core, like top): the change in
// utime+stime from /proc/<pid>/stat between two samples.
//
// GPU sources, whichever exists:
//   Intel (i915)  render-engine busy time summed from /proc/*/fdinfo (the
//                 per-client DRM stats nvtop/gputop use; covers this user's
//                 processes), clock from gt/gt0/rps_*_freq_mhz
//   NVIDIA        nvidia-smi
//   AMD           gpu_busy_percent / mem_info_vram_* in sysfs
ColumnLayout {
    id: root

    property bool active: false

    property real cpu: 0
    property var lastCpu: null // [idle, total] from the previous sample
    property real memUsed: 0
    property real memTotal: 0
    property real swapUsed: 0
    property real swapTotal: 0
    property real diskUsed: 0
    property real diskTotal: 0
    property real temp: -1
    property real uptime: 0
    property string load: ""

    // GPU
    property string gpuKind: "" // "intel" | "nvidia" | "amd" | ""
    property string gpuName: ""
    property real gpuBusy: 0
    property var lastGpu: null // Intel: [renderNs, sampleMs]
    property int gpuFreq: 0 // MHz, current
    property int gpuFreqCap: 0 // MHz, current upper limit (power profile)
    property int gpuFreqMax: 0 // MHz, hardware max
    property real vramUsed: 0 // bytes (discrete GPUs)
    property real vramTotal: 0
    property real gpuTemp: -1

    // Processes
    readonly property int clockTicks: 100 // USER_HZ
    readonly property int pageSize: 4096
    property var lastProcs: null // { t, ticks: { pid: ticks } }
    property var procs: [] // top by CPU: [{ pid, name, cpu, mem }]
    property string armedPid: "" // "End" clicked once, waiting for confirm
    property var ending: ({}) // pid -> time TERM was sent

    function gib(bytes) {
        return (bytes / 1073741824).toFixed(1);
    }

    // Process names are 15-char kernel "comm" values; Nix wrappers show up as
    // ".librewolf-wrap". -> "librewolf"
    function cleanName(n) {
        return n.replace(/^\./, "").replace(/-wrap\w*$/, "");
    }

    function megabytes(bytes) {
        return bytes >= 1073741824 ? `${(bytes / 1073741824).toFixed(1)} GB` : `${Math.round(bytes / 1048576)} MB`;
    }

    // An unconfirmed "End?" cancels itself.
    onArmedPidChanged: if (armedPid)
        disarm.restart()

    Timer {
        id: disarm
        interval: 3000
        onTriggered: root.armedPid = ""
    }

    // SIGTERM first (lets the app save/quit cleanly); if it's still there
    // a few seconds later the row offers SIGKILL.
    function endProcess(p) {
        const force = (ending[p.pid] ?? 0) > 0 && Date.now() - ending[p.pid] > 3000;
        Quickshell.execDetached(["kill", force ? "-KILL" : "-TERM", String(p.pid)]);
        const e = Object.assign({}, ending);
        e[p.pid] = Date.now();
        ending = e;
        armedPid = "";
    }

    function parse(text) {
        const mem = {};
        let tempSeen = false;
        let gpuSeen = "";
        const ticks = {};
        const procInfo = {};
        for (const line of text.split("\n")) {
            const f = line.trim().split(/\s+/);
            switch (f[0]) {
            case "proc":
                // proc <pid> <utime+stime ticks> <rss pages> <name...>
                ticks[f[1]] = Number(f[2]);
                procInfo[f[1]] = {
                    rss: Number(f[3]) * root.pageSize,
                    name: f.slice(4).join(" ")
                };
                break;
            case "stat":
                {
                    // stat cpu user nice system idle iowait irq softirq steal ...
                    const v = f.slice(2).map(Number);
                    const idle = v[3] + (v[4] || 0);
                    const total = v.reduce((a, b) => a + b, 0);
                    if (root.lastCpu) {
                        const dt = total - root.lastCpu[1];
                        if (dt > 0)
                            root.cpu = 1 - (idle - root.lastCpu[0]) / dt;
                    }
                    root.lastCpu = [idle, total];
                    break;
                }
            case "mem":
                mem[f[1].replace(":", "")] = Number(f[2]) * 1024;
                break;
            case "temp":
                root.temp = Number(f[1]) / 1000;
                tempSeen = true;
                break;
            case "disk":
                root.diskTotal = Number(f[1]);
                root.diskUsed = Number(f[2]);
                break;
            case "uptime":
                root.uptime = Number(f[1]);
                break;
            case "load":
                root.load = f.slice(1).join("  ");
                break;
            case "intelfreq":
                // intelfreq <act> <cap> <max>
                gpuSeen = "intel";
                root.gpuFreq = Number(f[1]);
                root.gpuFreqCap = Number(f[2]);
                root.gpuFreqMax = Number(f[3]);
                break;
            case "intelbusy":
                {
                    // intelbusy <render ns, summed over clients>
                    const ns = Number(f[1]);
                    const now = Date.now();
                    if (root.lastGpu) {
                        const dtMs = now - root.lastGpu[1];
                        // A client exiting drops its total; skip that sample.
                        const dNs = ns - root.lastGpu[0];
                        if (dtMs > 0 && dNs >= 0)
                            root.gpuBusy = Math.min(1, dNs / (dtMs * 1e6));
                    }
                    root.lastGpu = [ns, now];
                    break;
                }
            case "nvidia":
                {
                    // nvidia <name...>, <util>, <mem used MiB>, <mem total MiB>, <temp>
                    const c = line.slice(7).split(",").map(s => s.trim());
                    gpuSeen = "nvidia";
                    root.gpuName = c[0];
                    root.gpuBusy = Number(c[1]) / 100;
                    root.vramUsed = Number(c[2]) * 1048576;
                    root.vramTotal = Number(c[3]) * 1048576;
                    root.gpuTemp = Number(c[4]);
                    break;
                }
            case "amd":
                // amd <busy%> <vram used> <vram total> <temp milli°C or ->
                gpuSeen = "amd";
                root.gpuBusy = Number(f[1]) / 100;
                root.vramUsed = Number(f[2]);
                root.vramTotal = Number(f[3]);
                root.gpuTemp = f[4] && f[4] !== "-" ? Number(f[4]) / 1000 : -1;
                break;
            }
        }
        if (mem.MemTotal) {
            root.memTotal = mem.MemTotal;
            root.memUsed = mem.MemTotal - mem.MemAvailable;
            root.swapTotal = mem.SwapTotal || 0;
            root.swapUsed = (mem.SwapTotal || 0) - (mem.SwapFree || 0);
        }
        // CPU per process since the last sample.
        const now = Date.now();
        if (root.lastProcs) {
            const dt = (now - root.lastProcs.t) / 1000;
            const list = [];
            for (const pid in ticks) {
                const before = root.lastProcs.ticks[pid];
                if (before === undefined || dt <= 0)
                    continue;
                list.push({
                    pid: pid,
                    name: procInfo[pid].name,
                    cpu: (ticks[pid] - before) / root.clockTicks / dt,
                    mem: procInfo[pid].rss
                });
            }
            root.procs = list.sort((a, b) => (b.cpu - a.cpu) || (b.mem - a.mem)).slice(0, 6);
            // Forget processes that are gone.
            const e = {};
            for (const pid in root.ending)
                if (ticks[pid] !== undefined)
                    e[pid] = root.ending[pid];
            root.ending = e;
        }
        root.lastProcs = {
            t: now,
            ticks: ticks
        };

        if (!tempSeen)
            root.temp = -1;
        root.gpuKind = gpuSeen;
        if (gpuSeen === "intel")
            root.gpuName = "Intel Graphics";
        else if (gpuSeen === "amd")
            root.gpuName = "AMD Radeon";
    }

    spacing: 8

    onActiveChanged: if (active) {
        lastCpu = null;
        lastGpu = null;
        lastProcs = null;
        procs = [];
        armedPid = "";
        sample.running = true;
    }

    Process {
        id: sample
        command: ["sh", "-c", `
            echo "stat $(head -1 /proc/stat)"
            awk '/^(MemTotal|MemAvailable|SwapTotal|SwapFree):/ { print "mem", $1, $2 }' /proc/meminfo
            for z in /sys/class/thermal/thermal_zone*; do
                [ "$(cat "$z/type")" = x86_pkg_temp ] && echo "temp $(cat "$z/temp")" && break
            done
            echo "disk $(df -B1 --output=size,used / | tail -1)"
            echo "uptime $(cut -d' ' -f1 /proc/uptime)"
            echo "load $(cut -d' ' -f1-3 /proc/loadavg)"

            # ---- this user's processes (shell builtins only: no fork per pid) ----
            # /proc/<pid>/stat: pid (comm) state ... utime(14) stime(15) ... rss(24)
            for f in /proc/[0-9]*/stat; do
                [ -O "$f" ] || continue
                read -r l < "$f" 2>/dev/null || continue
                pid=\${f#/proc/}; pid=\${pid%/stat}
                comm=\${l#*\\(}; comm=\${comm%\\)*}
                set -- \${l##*\\) }
                echo "proc $pid $(( \${12} + \${13} )) \${22} $comm"
            done

            # ---- GPU ----
            if command -v nvidia-smi >/dev/null 2>&1; then
                nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu \
                    --format=csv,noheader,nounits 2>/dev/null | head -1 | sed 's/^/nvidia /'
            fi
            for d in /sys/class/drm/card[0-9]*/device; do
                [ -r "$d/gpu_busy_percent" ] || continue
                t=$(cat "$d"/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)
                echo "amd $(cat "$d/gpu_busy_percent") $(cat "$d/mem_info_vram_used") $(cat "$d/mem_info_vram_total") \${t:--}"
                break
            done
            for gt in /sys/class/drm/card[0-9]*/gt/gt0; do
                [ -r "$gt/rps_act_freq_mhz" ] || continue
                echo "intelfreq $(cat "$gt/rps_act_freq_mhz") $(cat "$gt/rps_max_freq_mhz") $(cat "$gt/rps_RP0_freq_mhz")"
                grep -s -h -E '^drm-(driver|client-id|engine-render):' /proc/[0-9]*/fdinfo/* | awk '
                    /^drm-driver:/       { drv = $2 }
                    /^drm-client-id:/    { id = $2 }
                    /^drm-engine-render:/ { if (drv == "i915") r[id] = $2 }
                    END { s = 0; for (k in r) s += r[k]; printf "intelbusy %.0f\\n", s }'
                break
            done
        `]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Timer {
        running: root.active
        interval: 2000
        repeat: true
        onTriggered: sample.running = true
    }

    // Two columns of tiles (leaves room for the process list below).
    // Temperatures are shown as text inside the CPU/GPU tiles (no own bar).
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        StatRow {
            Layout.preferredWidth: 1
            icon: "developer_board"
            label: "CPU"
            value: `${Math.round(root.cpu * 100)}%` + (root.temp >= 0 ? `  ·  ${Math.round(root.temp)}°C` : "")
            fraction: root.cpu
        }

        StatRow {
            Layout.preferredWidth: 1
            visible: root.gpuKind !== ""
            icon: "videogame_asset"
            label: root.gpuKind === "intel" ? "GPU" : root.gpuName || "GPU"
            value: {
                const parts = [`${Math.round(root.gpuBusy * 100)}%`];
                if (root.gpuKind === "intel" && root.gpuFreq > 0)
                    parts.push(`${root.gpuFreq} MHz`);
                // Discrete GPUs report their own sensor; an Intel iGPU sits on
                // the CPU die and has none, so it shows the package temperature.
                const t = root.gpuTemp >= 0 ? root.gpuTemp : root.gpuKind === "intel" ? root.temp : -1;
                if (t >= 0)
                    parts.push(`${Math.round(t)}°C`);
                return parts.join("  ·  ");
            }
            fraction: root.gpuBusy
        }

        StatRow {
            Layout.preferredWidth: 1
            icon: "memory_alt"
            label: "Memory"
            value: `${root.gib(root.memUsed)} / ${root.gib(root.memTotal)} GiB`
            fraction: root.memTotal > 0 ? root.memUsed / root.memTotal : 0
        }

        StatRow {
            Layout.preferredWidth: 1
            icon: "hard_drive"
            label: "Disk  /"
            value: `${root.gib(root.diskUsed)} / ${root.gib(root.diskTotal)} GiB`
            fraction: root.diskTotal > 0 ? root.diskUsed / root.diskTotal : 0
        }

        StatRow {
            Layout.preferredWidth: 1
            visible: root.swapTotal > 0
            icon: "swap_horiz"
            label: "Swap"
            value: `${root.gib(root.swapUsed)} / ${root.gib(root.swapTotal)} GiB`
            fraction: root.swapTotal > 0 ? root.swapUsed / root.swapTotal : 0
        }

        StatRow {
            Layout.preferredWidth: 1
            visible: root.vramTotal > 0
            icon: "memory"
            label: "Video memory"
            value: `${root.gib(root.vramUsed)} / ${root.gib(root.vramTotal)} GiB`
            fraction: root.vramTotal > 0 ? root.vramUsed / root.vramTotal : 0
        }
    }

    // ---- top processes ----
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4

        SectionLabel {
            Layout.fillWidth: true
            Layout.leftMargin: 2
            text: "Using the most CPU"
        }

        Text {
            Layout.rightMargin: 4
            text: "CPU · Memory"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: Theme.foregroundDim
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Theme.radius
        color: Theme.surface
        clip: true

        Text {
            visible: root.procs.length === 0
            anchors.centerIn: parent
            text: "Measuring…"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        Column {
            x: 6
            y: 6
            width: parent.width - 12

            Repeater {
                model: root.procs

                ProcessRow {
                    required property var modelData
                    width: parent.width
                    proc: modelData
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            text: {
                const d = Math.floor(root.uptime / 86400);
                const h = Math.floor(root.uptime % 86400 / 3600);
                const m = Math.floor(root.uptime % 3600 / 60);
                const up = d > 0 ? `${d}d ${h}h` : h > 0 ? `${h}h ${m}m` : `${m}m`;
                const gpu = root.gpuKind === "intel" && root.gpuFreqMax > 0 ? `    GPU max ${root.gpuFreqMax} MHz` : "";
                return `Up ${up}    Load ${root.load}${gpu}`;
            }
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        // Bar pill under heavy load (services/SystemLoad.qml).
        Text {
            text: "Load warning in bar"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        Toggle {
            checked: SystemLoad.enabled
            onToggled: SystemLoad.enabled = !SystemLoad.enabled
        }
    }

    // One process: [icon] name            12%   340 MB   [End]
    // End asks once ("End?"), then sends SIGTERM; if the process is still
    // there 3 s later the button becomes "Force quit" (SIGKILL).
    component ProcessRow: MouseArea {
        id: row

        required property var proc

        readonly property string name: root.cleanName(proc.name)
        readonly property var entry: DesktopEntries.heuristicLookup(name)
        readonly property real endedAt: root.ending[proc.pid] ?? 0
        readonly property bool canForce: endedAt > 0 && Date.now() - endedAt > 3000
        readonly property bool armed: root.armedPid === proc.pid

        implicitHeight: 32
        hoverEnabled: true

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: row.containsMouse ? Theme.surfaceHigh : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 6
            spacing: 10

            Item {
                implicitWidth: 18
                implicitHeight: 18

                IconImage {
                    id: appIcon
                    anchors.fill: parent
                    source: Quickshell.iconPath(row.entry?.icon || row.name.toLowerCase(), true)
                    visible: status === Image.Ready
                }

                Icon {
                    anchors.centerIn: parent
                    visible: !appIcon.visible
                    name: "terminal"
                    size: 15
                    color: Theme.foregroundDim
                }
            }

            Text {
                Layout.fillWidth: true
                text: row.entry?.name || row.name
                elide: Text.ElideRight
                textFormat: Text.PlainText
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                color: Theme.foreground
            }

            Text {
                Layout.preferredWidth: 44
                horizontalAlignment: Text.AlignRight
                text: `${Math.round(row.proc.cpu * 100)}%`
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                font.features: {
                    "tnum": 1
                }
                color: row.proc.cpu >= 0.5 ? Theme.urgent : Theme.foreground
            }

            Text {
                Layout.preferredWidth: 60
                horizontalAlignment: Text.AlignRight
                text: root.megabytes(row.proc.mem)
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.features: {
                    "tnum": 1
                }
                color: Theme.foregroundDim
            }

            // End / End? / Ending… / Force quit (shown on hover or while armed).
            MouseArea {
                id: endButton
                Layout.preferredWidth: 78
                implicitHeight: 22
                visible: row.containsMouse || row.armed || row.endedAt > 0
                enabled: !(row.endedAt > 0 && !row.canForce)
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (row.armed || row.canForce)
                        root.endProcess(row.proc);
                    else
                        root.armedPid = row.proc.pid;
                }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: row.armed || row.canForce ? Theme.urgent : endButton.containsMouse ? Theme.muted : Theme.surface
                }

                Text {
                    anchors.centerIn: parent
                    text: row.canForce ? "Force quit" : row.endedAt > 0 ? "Ending…" : row.armed ? "End?" : "End"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: row.armed || row.canForce ? Font.DemiBold : Font.Normal
                    color: row.armed || row.canForce ? Theme.background : Theme.foreground
                }
            }
        }
    }
}
