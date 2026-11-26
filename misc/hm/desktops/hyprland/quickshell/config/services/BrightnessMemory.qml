import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Screen brightness per power source: one level on the charger, another on
// battery. On plug / unplug, the level in use is remembered for the source
// being left and the other source's level is put back (if it has one yet).
// Saved: $XDG_STATE_HOME/nyx/brightness.json ({ ac, battery }, raw values).
Scope {
    id: root

    readonly property bool onBattery: UPower.onBattery
    property var saved: ({})
    property bool restored: false
    property string leaving: ""

    onOnBatteryChanged: {
        if (!restored)
            return;
        leaving = onBattery ? "ac" : "battery";
        read.running = true;
    }

    // `brightnessctl -m`: "intel_backlight,backlight,285,57%,504"
    Process {
        id: read
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = parseInt(text.split(",")[2]);
                const next = root.leaving === "ac" ? "battery" : "ac";
                if (raw > 0) {
                    const s = Object.assign({}, root.saved);
                    s[root.leaving] = raw;
                    root.saved = s;
                    state.setText(JSON.stringify(s));
                }
                const want = root.saved[next];
                if (want > 0 && want !== raw)
                    Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", String(want)]);
            }
        }
    }

    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/brightness.json`

    FileView {
        id: state
        path: root.stateFile
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.saved = JSON.parse(text()) ?? {};
            } catch (e) {}
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }
}
