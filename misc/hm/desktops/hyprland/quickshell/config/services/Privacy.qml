pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Who is using the microphone, camera or capturing the screen, from active
// PipeWire links (source device -> app stream):
//   mic     Audio/Source            -> Stream/Input/Audio  (not Bluetooth's
//                                     internal capture stream)
//   camera  Video/Source (v4l2/libcamera) -> any
//   screen  any other Video/Source (the xdg-desktop-portal screencast) -> any
// Only *active* links count, so a paused/corked stream doesn't light it up.
//
// Most apps don't use the camera through PipeWire but open /dev/video*
// directly (browsers, Zoom, OBS's V4L2 source, mpv...). Those are found by
// looking for processes holding a /dev/video* file open. The scan is
// triggered by inotify open/close events on the devices (inotifywait), so
// nothing polls while the camera is idle; without inotifywait it falls back
// to scanning every 3 s.
Singleton {
    id: root

    // Bind every node (so `properties` like media.class are filled) and every
    // link group (otherwise its `state` stays unknown, -1).
    PwObjectTracker {
        objects: [...Pipewire.nodes.values, ...Pipewire.linkGroups.values]
    }

    readonly property var activeLinks: Pipewire.linkGroups.values.filter(g => g.state === PwLinkState.Active && g.source && g.target)

    function mediaClass(node) {
        return node?.properties?.["media.class"] ?? "";
    }

    function appName(node) {
        const p = node?.properties ?? {};
        return p["application.name"] || p["application.process.binary"] || node?.description || node?.nickname || node?.name || "Unknown app";
    }

    function isCamera(node) {
        const api = node?.properties?.["device.api"] ?? "";
        const name = node?.name ?? "";
        return api === "v4l2" || api === "libcamera" || name.startsWith("v4l2") || name.startsWith("libcamera");
    }

    function apps(links) {
        return [...new Set(links.map(g => appName(g.target)))];
    }

    readonly property var micApps: apps(activeLinks.filter(g => mediaClass(g.source) === "Audio/Source" && mediaClass(g.target).startsWith("Stream/Input/Audio") && !mediaClass(g.target).includes("Internal")))
    // Camera through PipeWire, plus apps holding /dev/video* themselves.
    readonly property var pipewireCameraApps: apps(activeLinks.filter(g => mediaClass(g.source) === "Video/Source" && isCamera(g.source)))
    property var deviceCameraApps: []
    readonly property var cameraApps: [...new Set([...pipewireCameraApps, ...deviceCameraApps])]

    // ---- direct /dev/video* users ------------------------------------------

    // PipeWire's own processes open the device on behalf of PipeWire clients,
    // which are already named through the links above.
    readonly property var ignoredCameraHolders: ["pipewire", "wireplumber", "pipewire-media-session"]

    // Executable name -> app name: ".librewolf-wrapped" -> "librewolf".
    function cleanName(exe) {
        return exe.replace(/^\./, "").replace(/-wrapp(ed)?$/, "");
    }

    function scanCamera() {
        if (!cameraScan.running)
            cameraScan.running = true;
        else
            cameraScanAgain = true;
    }
    property bool cameraScanAgain: false

    // pid list -> executable names of processes with a /dev/video* fd open
    // (only this user's processes are readable, which is what matters).
    Process {
        id: cameraScan
        command: ["sh", "-c", `
            find /proc/[0-9]*/fd -maxdepth 1 -lname '/dev/video*' 2>/dev/null | cut -d/ -f3 | sort -u |
            while read -r pid; do
                exe=$(readlink "/proc/$pid/exe" 2>/dev/null) || continue
                basename "$exe"
            done`]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = text.split("\n").map(s => root.cleanName(s.trim())).filter(n => n && !root.ignoredCameraHolders.includes(n));
                root.deviceCameraApps = [...new Set(names)];
            }
        }
        onExited: if (root.cameraScanAgain) {
            root.cameraScanAgain = false;
            running = true;
        }
    }

    // Open/close on any camera node -> rescan (debounced: an app opening the
    // device fires several events).
    Process {
        id: cameraWatch
        running: true
        command: ["sh", "-c", "set -- /dev/video*; [ -e \"$1\" ] || exit 3; exec inotifywait -mq -e open,close --format x \"$@\""]
        stdout: SplitParser {
            onRead: cameraDebounce.restart()
        }
        onExited: code => {
            if (code === 127)
                cameraPoll.running = true; // no inotifywait: poll instead
            else
                cameraWatchRestart.restart(); // no cameras yet / watcher died
        }
    }

    Timer {
        id: cameraDebounce
        interval: 250
        onTriggered: root.scanCamera()
    }

    Timer {
        id: cameraWatchRestart
        interval: 30000
        onTriggered: cameraWatch.running = true
    }

    Timer {
        id: cameraPoll
        interval: 3000
        repeat: true
        onTriggered: root.scanCamera()
    }

    Component.onCompleted: scanCamera()
    readonly property var screenApps: apps(activeLinks.filter(g => mediaClass(g.source) === "Video/Source" && !isCamera(g.source)))

    // `?.` guards against the lists being briefly undefined during a reload.
    readonly property bool mic: (micApps?.length ?? 0) > 0
    readonly property bool camera: (cameraApps?.length ?? 0) > 0
    readonly property bool screen: (screenApps?.length ?? 0) > 0
    readonly property bool any: mic || camera || screen

    // qs -c nyx ipc call privacy dump   -> what quickshell sees per link group
    IpcHandler {
        target: "privacy"

        function dump(): string {
            return Pipewire.linkGroups.values.map(g => `${g.source?.name ?? "?"} [${root.mediaClass(g.source)}] -> ${g.target?.name ?? "?"} [${root.mediaClass(g.target)}] state=${g.state} active=${g.state === PwLinkState.Active}`).join("\n") + `\n-- mic=${root.micApps} camera=${root.cameraApps} screen=${root.screenApps}`;
        }
    }
}
