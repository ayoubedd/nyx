pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Mic noise suppression (RNNoise), switched from the sound menu.
//
// On: runs `nyx-noise-suppression <mic>` (quickshell/default.nix), a
// PipeWire filter reading that real mic and offering a virtual source
// "Noise-suppressed mic", and makes that source the default input, so
// apps using the default mic get the cleaned-up sound. Off: stops the
// filter (it disappears) and makes the real mic the default again.
// The filter reads one specific mic, never "default" (which is itself).
// The on/off choice and the mic are remembered ($XDG_STATE_HOME/nyx/).
Singleton {
    id: root

    readonly property string filterName: "nyx_rnnoise_source"
    readonly property string captureName: "capture.nyx_rnnoise"

    property bool enabled: false
    property string micName: "" // node.name of the real mic it reads
    property bool available: true // false when the wrapper isn't installed

    readonly property var filterNode: Pipewire.nodes.values.find(n => n.name === filterName) ?? null
    readonly property var micNode: Pipewire.nodes.values.find(n => n.name === micName) ?? null
    readonly property bool active: proc.running && !!filterNode

    function isFilter(node) {
        return node?.name === filterName;
    }

    function setEnabled(on) {
        if (on) {
            // Read from the current default mic (unless that's the filter).
            const src = Pipewire.defaultAudioSource;
            if (src && !isFilter(src))
                micName = src.name;
            if (!micName)
                return;
            enabled = true;
            start();
        } else {
            enabled = false;
            stop();
            if (micNode)
                Audio.makeDefault(micNode);
        }
        save();
    }

    // Another mic picked while on: rebuild the filter on it.
    function setMic(node) {
        micName = node.name;
        save();
        if (enabled) {
            stop();
            restartLater.restart();
        } else {
            Audio.makeDefault(node);
        }
    }

    function start() {
        proc.command = ["nyx-noise-suppression", micName];
        proc.running = true;
    }

    // Stopping on purpose (off / new mic): not a crash.
    property bool stopping: false

    function stop() {
        if (proc.running) {
            stopping = true;
            proc.running = false;
        }
    }

    Timer {
        id: restartLater
        interval: 300
        onTriggered: root.start()
    }

    // The filter came up: make it the default input.
    onFilterNodeChanged: if (enabled && filterNode) {
        retries = 0;
        Audio.makeDefault(filterNode);
    }

    // The filter died on its own (PipeWire restart, load error): put the
    // real mic back as the default, then retry a few times (PipeWire may
    // just be coming back up); after that, turn it off.
    property int retries: 0

    Timer {
        id: retryTimer
        interval: 2000 * Math.max(1, root.retries)
        onTriggered: if (root.enabled)
            root.start()
    }

    Process {
        id: proc
        onExited: code => {
            if (root.stopping) {
                root.stopping = false;
                return;
            }
            if (code === 127) {
                root.available = false;
                root.enabled = false;
                return;
            }
            if (!root.enabled)
                return;
            if (root.micNode)
                Audio.makeDefault(root.micNode);
            if (root.retries < 3) {
                root.retries++;
                retryTimer.restart();
            } else {
                root.retries = 0;
                root.enabled = false;
                root.save();
            }
        }
    }

    // ---- persistence ----
    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/noise-suppression.json`
    property bool restored: false

    function save() {
        if (restored)
            store.setText(JSON.stringify({
                enabled: enabled,
                mic: micName
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
                root.micName = s.mic ?? "";
                if (s.enabled && root.micName) {
                    root.enabled = true;
                    root.start();
                }
            } catch (e) {}
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }
}
