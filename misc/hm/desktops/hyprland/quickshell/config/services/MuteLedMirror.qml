import QtQuick
import Quickshell
import Quickshell.Io

// Keeps one ThinkPad mute LED in sync with the default device of its kind,
// while every device keeps its own mute state. Used twice by MuteLeds.qml:
// speakers (F1, platform::mute) and microphone (F4, platform::micmute).
//
// Each LED follows the built-in sound card's ALSA switch (kernel triggers
// "audio-mute" / "audio-micmute"), which WirePlumber flips when the
// built-in device is muted in PipeWire. The bar, the OSD and the media keys
// mute the *default* device though, which is often something else
// (Bluetooth / USB headset, HDMI, the noise-suppressed mic), and then the
// LED stays dark. So while another device is the default, its mute is
// mirrored onto the built-in one: the LED means "what I'm using is muted".
//
// Per-device state:
//   - Other devices: PipeWire keeps their mute per device already.
//   - The built-in device: the mirroring overwrites its real mute, so its
//     own state is kept here (`builtinOwn`, saved) and put back when it
//     becomes the default again.
//   - A virtual device standing for a real one (`underlying`, e.g. the
//     noise-suppression filter over a mic): takes that device's state when
//     it becomes the default, and muting it updates that device's state.
Scope {
    id: root

    // The current default device and the built-in one (both must be bound
    // by a PwObjectTracker; Audio.qml binds the defaults and all devices).
    required property var node
    required property var builtin
    // Saved state file name, in $XDG_STATE_HOME/nyx/.
    required property string stateName
    // The real device a (virtual) device stands for; itself by default.
    property var underlying: n => n

    // A newly picked default's audio controls arrive a moment after it does.
    readonly property bool ready: !!node?.audio && !!builtin?.audio && restored
    readonly property bool nodeMuted: node?.audio?.muted ?? false

    // The built-in device's own mute (what it goes back to), saved.
    property bool builtinOwn: false
    // The default we've finished switching to; mute changes on any other
    // (mid-switch, or caused by restoring) aren't the user's.
    property var settled: null
    property bool firstSettle: true

    function mirror() {
        if (node !== builtin && builtin.audio.muted !== node.audio.muted)
            builtin.audio.muted = node.audio.muted;
    }

    // A new default: give it its own (or its real device's) state, then
    // mirror it for the LED.
    function settle() {
        if (!ready)
            return;
        settled = null;
        const real = underlying(node) ?? builtin;
        if (real === builtin) {
            // First run with the built-in device in use: its current mute
            // (as WirePlumber restored it) is the truth, not the saved value.
            if (firstSettle && node === builtin)
                setOwn(builtin.audio.muted);
            else if (node.audio.muted !== builtinOwn)
                node.audio.muted = builtinOwn;
        } else if (real !== node && real?.audio) {
            if (node.audio.muted !== real.audio.muted)
                node.audio.muted = real.audio.muted;
        }
        firstSettle = false;
        mirror();
        settled = node;
    }

    function setOwn(muted) {
        if (builtinOwn === muted)
            return;
        builtinOwn = muted;
        state.setText(JSON.stringify({
            builtinMuted: muted
        }));
    }

    // The user (bar, OSD, media keys, any app) muted / unmuted the default.
    onNodeMutedChanged: {
        if (!ready || settled !== node)
            return;
        const real = underlying(node) ?? builtin;
        if (real === builtin)
            setOwn(nodeMuted);
        else if (real !== node && real?.audio)
            real.audio.muted = nodeMuted;
        mirror();
    }

    onNodeChanged: settle()
    onReadyChanged: settle()

    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/${stateName}`
    property bool restored: false

    FileView {
        id: state
        path: root.stateFile
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.builtinOwn = JSON.parse(text()).builtinMuted ?? false;
            } catch (e) {}
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }
}
