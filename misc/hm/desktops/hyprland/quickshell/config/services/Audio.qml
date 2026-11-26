pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.common

// PipeWire audio state for the sound menu and bar icon.
//   outputs  Audio/Sink    (speakers, headsets, HDMI…)
//   inputs   Audio/Source  (microphones)
//   apps     Stream/Output/Audio (anything playing sound)
Singleton {
    id: root

    readonly property var nodes: Pipewire.nodes.values

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property var outputs: nodes.filter(n => mediaClass(n) === "Audio/Sink")
    // Real mics only: the noise-suppression filter's virtual source is
    // represented by its switch (NoiseSuppression.qml), not as a device.
    readonly property var inputs: nodes.filter(n => mediaClass(n).startsWith("Audio/Source") && n.name !== "nyx_rnnoise_source")
    readonly property var apps: nodes.filter(n => mediaClass(n) === "Stream/Output/Audio")

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // Bind everything shown, so volume/mute/properties are live and writable.
    PwObjectTracker {
        objects: [root.sink, root.source, ...root.outputs, ...root.inputs, ...root.apps]
    }

    function mediaClass(node) {
        return node?.properties?.["media.class"] ?? "";
    }

    function deviceName(node) {
        return node?.description || node?.nickname || node?.name || "Unknown device";
    }

    // "Allow volume above 100%" (sound detail view): sliders go to 150%.
    // The volume keys stay capped at 100% (wpctl -l 1 in binds.lua). Saved.
    property bool allowBoost: false
    readonly property real maxVolume: allowBoost ? 1.5 : 1

    function setVolume(node, v) {
        if (!node?.audio)
            return;
        node.audio.muted = false;
        node.audio.volume = Math.max(0, Math.min(maxVolume, v));
    }

    // Left/right balance for a stereo device: -1 (left) .. 0 .. 1 (right).
    // Keeps the louder side at the current overall volume.
    function balanceOf(node) {
        const v = node?.audio?.volumes ?? [];
        if (v.length !== 2 || Math.max(v[0], v[1]) <= 0)
            return 0;
        return (v[1] - v[0]) / Math.max(v[0], v[1]);
    }

    function setBalance(node, b) {
        const a = node?.audio;
        if (!a || (a.volumes ?? []).length !== 2)
            return;
        const level = Math.max(a.volumes[0], a.volumes[1]);
        a.volumes = [level * Math.min(1, 1 - b), level * Math.min(1, 1 + b)];
    }

    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/audio.json`
    property bool restored: false
    onAllowBoostChanged: {
        if (restored)
            store.setText(JSON.stringify({
                allowBoost: allowBoost
            }));
        // Turning it off brings anything above 100% back down.
        if (!allowBoost && sink?.audio && sink.audio.volume > 1)
            sink.audio.volume = 1;
    }

    FileView {
        id: store
        path: root.stateFile
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.allowBoost = JSON.parse(text()).allowBoost ?? false;
            } catch (e) {}
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }

    function toggleMute(node) {
        if (node?.audio)
            node.audio.muted = !node.audio.muted;
    }

    function makeDefault(node) {
        if (mediaClass(node) === "Audio/Sink")
            Pipewire.preferredDefaultAudioSink = node;
        else
            Pipewire.preferredDefaultAudioSource = node;
    }

    function volumeIcon(v, isMuted) {
        if (isMuted || v <= 0)
            return "volume_off";
        return v < 0.34 ? "volume_mute" : v < 0.67 ? "volume_down" : "volume_up";
    }

    // Icon for an output/input device from its name/properties.
    function deviceIcon(node) {
        const p = node?.properties ?? {};
        const text = `${node?.name ?? ""} ${node?.description ?? ""} ${p["device.form-factor"] ?? ""} ${p["device.bus"] ?? ""}`.toLowerCase();
        const isInput = mediaClass(node).startsWith("Audio/Source");
        if (/headset|headphone|bluez|buds|airpods/.test(text))
            return isInput ? "headset_mic" : "headphones";
        if (/hdmi|displayport|monitor|tv/.test(text))
            return "tv";
        if (/usb/.test(text))
            return isInput ? "mic_external_on" : "speaker";
        return isInput ? "mic" : "speaker";
    }
}
