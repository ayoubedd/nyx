pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

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
    readonly property var inputs: nodes.filter(n => mediaClass(n).startsWith("Audio/Source"))
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

    function setVolume(node, v) {
        if (!node?.audio)
            return;
        node.audio.muted = false;
        node.audio.volume = Math.max(0, Math.min(1, v));
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
