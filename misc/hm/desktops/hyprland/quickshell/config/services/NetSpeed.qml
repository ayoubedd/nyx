pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Current download / upload speed over the physical interfaces, from
// /proc/net/dev every 2 s. Read in-process (FileView), so it starts no
// processes. VPN/tunnel and virtual interfaces (tun, wg, docker, veth,
// bridges) are skipped: their traffic is already counted on the physical
// link, so including them would double it.
Singleton {
    id: root

    property real down: 0 // bytes/s
    property real up: 0
    property var last: null // { rx, tx, t }

    readonly property int interval: 2000

    function sample(text) {
        let rx = 0, tx = 0;
        for (const line of text.split("\n").slice(2)) {
            const colon = line.indexOf(":");
            if (colon < 0)
                continue;
            const name = line.slice(0, colon).trim();
            if (!/^(wl|en|eth|ww|usb)/.test(name))
                continue;
            const f = line.slice(colon + 1).trim().split(/\s+/).map(Number);
            rx += f[0];
            tx += f[8];
        }
        const now = Date.now();
        if (last) {
            const dt = (now - last.t) / 1000;
            // Counters reset (interface re-created): skip that sample.
            if (dt > 0 && rx >= last.rx && tx >= last.tx) {
                down = (rx - last.rx) / dt;
                up = (tx - last.tx) / dt;
            }
        }
        last = {
            rx: rx,
            tx: tx,
            t: now
        };
    }

    // "0 K", "340 K", "1.2 M", "12 M" (per second; short for the bar).
    function short(bytes) {
        if (bytes < 1024 * 1000)
            return `${Math.round(bytes / 1024)} K`;
        const m = bytes / 1048576;
        return m < 10 ? `${m.toFixed(1)} M` : `${Math.round(m)} M`;
    }

    // "340 KB/s" / "1.2 MB/s" (tooltips and menus).
    function long(bytes) {
        return `${short(bytes)}B/s`;
    }

    FileView {
        id: dev
        path: "/proc/net/dev"
        printErrors: false
        onLoaded: root.sample(text())
    }

    // Paused while locked. The first sample after resuming only sets the
    // baseline (an average over the whole lock would be meaningless).
    Timer {
        running: !Ui.locked
        repeat: true
        interval: root.interval
        triggeredOnStart: true
        onTriggered: dev.reload()
        onRunningChanged: if (!running) {
            root.last = null;
            root.down = 0;
            root.up = 0;
        }
    }
}
