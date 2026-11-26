import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Pause playback when the headphones go away, like a phone does: when the
// output that was in use disappears (Bluetooth earbuds out of range or back
// in their case, a USB headset unplugged), whatever was playing is paused
// instead of carrying on through the laptop speakers.
Scope {
    id: root

    property string lastSink: ""

    Connections {
        target: Audio
        function onSinkChanged() {
            const prev = root.lastSink;
            root.lastSink = Audio.sink?.name ?? "";
            // The old output only counts as "gone" once PipeWire has removed
            // it, which can land just after the default switches.
            if (prev !== "" && prev !== root.lastSink) {
                gone.name = prev;
                gone.restart();
            }
        }
    }

    Component.onCompleted: lastSink = Audio.sink?.name ?? ""

    Timer {
        id: gone
        property string name: ""
        interval: 400
        onTriggered: {
            if (Audio.outputs.some(n => n.name === name))
                return; // switched by hand, not disconnected
            for (const p of Mpris.players.values) {
                if (p.isPlaying && p.canPause)
                    p.pause();
            }
        }
    }
}
