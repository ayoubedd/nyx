import QtQuick
import Quickshell

// The ThinkPad's two mute LEDs, each kept in sync with the device actually
// in use while every device keeps its own mute (see MuteLedMirror.qml).
Scope {
    // F1 LED (platform::mute): the laptop speakers' sink on the internal
    // card. (Headphones / HDMI on the same card are separate sinks and are
    // treated like any other output.)
    MuteLedMirror {
        node: Audio.sink
        builtin: Audio.outputs.find(n => (n.name ?? "").startsWith("alsa_output.pci-") && n.name.includes("Speaker")) ?? null
        stateName: "speakermute.json"
    }

    // F4 LED (platform::micmute): the built-in mic. The noise-suppressed
    // mic is the same physical mic as the one the filter reads, so it
    // shares that mic's mute (switching it on never un-mutes you).
    MuteLedMirror {
        id: mic
        node: Audio.source
        builtin: Audio.inputs.find(n => (n.name ?? "").startsWith("alsa_input.pci-")) ?? null
        stateName: "micmute.json"
        underlying: n => NoiseSuppression.isFilter(n) ? (NoiseSuppression.micNode ?? mic.builtin) : n
    }
}
