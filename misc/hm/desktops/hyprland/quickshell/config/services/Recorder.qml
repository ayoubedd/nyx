pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen recording with wf-recorder, started from the screenshot tool
// (overlays/Screenshot.qml, "Record") and stopped from the bar
// (bar/RecordingWidget.qml) or:
//   qs -c nyx ipc call recorder stop
//
// H.264 on the GPU (VA-API, /dev/dri/renderD128), so recording barely touches
// the CPU. Optional desktop audio = the default output's monitor source.
// Files go to ~/Videos/Recordings; when a recording ends, a notification
// offers to open it.
Singleton {
    id: root

    readonly property bool recording: proc.running
    property real startedAt: 0
    property int elapsed: 0 // seconds
    property string file: ""
    property bool withAudio: false
    property string stderrTail: ""

    readonly property string dir: `${Quickshell.env("HOME")}/Videos/Recordings`

    // target: { output: "eDP-1" } for a whole screen, or
    //         { geometry: "x,y wxh" } in global logical coordinates.
    function start(target, audio) {
        if (recording)
            return;
        const ts = Qt.formatDateTime(new Date(), "yyyyMMdd_HH'h'mm'm'ss's'");
        file = `${dir}/${ts}.mp4`;
        withAudio = audio;
        const args = ["wf-recorder", "-y", "-f", file, "-c", "h264_vaapi", "-d", "/dev/dri/renderD128"];
        if (target.output)
            args.push("-o", target.output);
        else
            args.push("-g", target.geometry);
        // Desktop sound: the monitor of the default output. (`$(...)` needs a
        // shell, so resolve it in the wrapper below.)
        proc.command = ["sh", "-c", `
            mkdir -p "$1"
            shift
            if [ "$AUDIO" = 1 ]; then
                sink=$(pactl get-default-sink 2>/dev/null)
                [ -n "$sink" ] && set -- "$@" "--audio=$sink.monitor"
            fi
            exec "$@"`, "sh", dir, ...args];
        proc.environment = {
            AUDIO: audio ? "1" : "0"
        };
        stderrTail = "";
        startedAt = Date.now();
        elapsed = 0;
        proc.running = true;
    }

    // SIGINT lets wf-recorder finish the file properly.
    function stop() {
        if (recording)
            proc.signal(2);
    }

    function notify(summary, body, open) {
        // notify-send --wait blocks until the notification is acted on, so the
        // "Open" button can open the file. Runs detached.
        const script = open ? `
            choice=$(notify-send -a "Screen recording" -i video-x-generic -A open=Open -A folder="Show in folder" --wait "$1" "$2")
            case "$choice" in
                open) xdg-open "$3" ;;
                folder) xdg-open "$(dirname "$3")" ;;
            esac` : `notify-send -a "Screen recording" -u critical "$1" "$2"`;
        Quickshell.execDetached(["sh", "-c", script, "sh", summary, body, file]);
    }

    function duration(s) {
        const m = Math.floor(s / 60);
        return `${m}:${String(s % 60).padStart(2, "0")}`;
    }

    Process {
        id: proc
        stderr: SplitParser {
            onRead: line => {
                // Keep the last few lines for an error message.
                const lines = (root.stderrTail + "\n" + line).split("\n").filter(l => l.trim());
                root.stderrTail = lines.slice(-4).join("\n");
            }
        }
        onExited: code => {
            const secs = root.elapsed;
            // Died on its own within a couple of seconds = it never recorded.
            if (code !== 0 && Date.now() - root.startedAt < 3000) {
                root.notify("Recording failed", root.stderrTail || `wf-recorder exited with code ${code}`, false);
                return;
            }
            root.notify("Recording saved", `${root.file.replace(Quickshell.env("HOME"), "~")} · ${root.duration(secs)}`, true);
        }
    }

    Timer {
        running: root.recording
        interval: 1000
        repeat: true
        onTriggered: root.elapsed = Math.round((Date.now() - root.startedAt) / 1000)
    }

    IpcHandler {
        target: "recorder"

        function stop(): void {
            root.stop();
        }
        function status(): string {
            return root.recording ? `recording ${root.duration(root.elapsed)} ${root.file}` : "idle";
        }
    }
}
