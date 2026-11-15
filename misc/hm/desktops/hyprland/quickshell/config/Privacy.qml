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
// (Apps that open /dev/video* directly, bypassing PipeWire, aren't seen.)
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
    readonly property var cameraApps: apps(activeLinks.filter(g => mediaClass(g.source) === "Video/Source" && isCamera(g.source)))
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
