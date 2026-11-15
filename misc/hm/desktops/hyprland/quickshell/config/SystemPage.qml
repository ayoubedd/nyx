import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// CPU / GPU / memory / swap / disk / temperature, polled every 2s while visible.
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

    function gib(bytes) {
        return (bytes / 1073741824).toFixed(1);
    }

    function parse(text) {
        const mem = {};
        let tempSeen = false;
        let gpuSeen = "";
        for (const line of text.split("\n")) {
            const f = line.trim().split(/\s+/);
            switch (f[0]) {
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

    // Temperatures are shown as text inside the CPU/GPU cards (no own bar).
    StatRow {
        icon: "developer_board"
        label: "CPU"
        value: `${Math.round(root.cpu * 100)}%` + (root.temp >= 0 ? `  ·  ${Math.round(root.temp)}°C` : "")
        fraction: root.cpu
    }

    StatRow {
        visible: root.gpuKind !== ""
        icon: "videogame_asset"
        label: root.gpuName || "GPU"
        value: {
            const parts = [`${Math.round(root.gpuBusy * 100)}%`];
            if (root.gpuKind === "intel" && root.gpuFreq > 0)
                parts.push(`${root.gpuFreq} / ${root.gpuFreqCap} MHz`);
            // Discrete GPUs report their own sensor; an Intel iGPU sits on the
            // CPU die and has none, so it shows the package temperature.
            const t = root.gpuTemp >= 0 ? root.gpuTemp : root.gpuKind === "intel" ? root.temp : -1;
            if (t >= 0)
                parts.push(`${Math.round(t)}°C`);
            return parts.join("  ·  ");
        }
        fraction: root.gpuBusy
    }

    StatRow {
        visible: root.vramTotal > 0
        icon: "memory"
        label: "Video memory"
        value: `${root.gib(root.vramUsed)} / ${root.gib(root.vramTotal)} GiB`
        fraction: root.vramTotal > 0 ? root.vramUsed / root.vramTotal : 0
    }

    StatRow {
        icon: "memory_alt"
        label: "Memory"
        value: `${root.gib(root.memUsed)} / ${root.gib(root.memTotal)} GiB`
        fraction: root.memTotal > 0 ? root.memUsed / root.memTotal : 0
    }

    StatRow {
        visible: root.swapTotal > 0
        icon: "swap_horiz"
        label: "Swap"
        value: `${root.gib(root.swapUsed)} / ${root.gib(root.swapTotal)} GiB`
        fraction: root.swapTotal > 0 ? root.swapUsed / root.swapTotal : 0
    }

    StatRow {
        icon: "hard_drive"
        label: "Disk  /"
        value: `${root.gib(root.diskUsed)} / ${root.gib(root.diskTotal)} GiB`
        fraction: root.diskTotal > 0 ? root.diskUsed / root.diskTotal : 0
    }

    Item {
        Layout.fillHeight: true
    }

    Text {
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
}
