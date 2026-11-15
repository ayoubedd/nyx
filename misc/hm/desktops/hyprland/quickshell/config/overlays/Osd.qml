import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import qs.common
import qs.services

// On-screen display for volume, microphone mute and brightness.
//
// Volume/mic come straight from PipeWire, so any change shows it (keys, the
// control center, wpctl, a headset connecting). Brightness has no reliable
// change event, so the brightness keys call:
//   qs -c nyx ipc call osd brightness
//
// Click-through, no keyboard focus, hidden while the control center is open.
Scope {
    id: root

    property string kind: "" // "volume" | "mic" | "brightness"
    property bool shown: false
    property string device: "" // set when the output device just changed
    property real brightness: 0

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool volumeMuted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false

    // Ignore the burst of "changes" while PipeWire state loads at startup.
    property bool armed: false

    function show(which) {
        if (!armed || Notifs.centerOpen || (Ui.active?.suppressOsd ?? false))
            return;
        kind = which;
        shown = true;
        hideTimer.restart();
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            root.shown = false;
            root.device = "";
        }
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() {
            root.show("volume");
        }
        function onMutedChanged() {
            root.show("volume");
        }
    }

    Connections {
        target: root.source?.audio ?? null
        function onMutedChanged() {
            root.show("mic");
        }
    }

    // New default output (e.g. headphones connected): show its name.
    onSinkChanged: {
        if (!armed || !sink)
            return;
        device = sink.description || sink.nickname || sink.name;
        show("volume");
    }

    // `brightnessctl -m` -> "intel_backlight,backlight,191,38%,504"
    Process {
        id: readBrightness
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: SplitParser {
            onRead: line => {
                const f = line.split(",");
                if (f.length >= 5 && parseInt(f[4]) > 0) {
                    root.brightness = parseInt(f[2]) / parseInt(f[4]);
                    root.show("brightness");
                }
            }
        }
    }

    IpcHandler {
        target: "osd"

        function brightness(): void {
            readBrightness.running = true;
        }
        function volume(): void {
            root.show("volume");
        }
        function mic(): void {
            root.show("mic");
        }
    }

    PanelWindow {
        id: window

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.shown || card.opacity > 0

        anchors.bottom: true
        margins.bottom: 90
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nyx-osd"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        // Fully click-through.
        mask: Region {}

        implicitWidth: 320
        implicitHeight: card.implicitHeight

        Rectangle {
            id: card

            readonly property bool isMic: root.kind === "mic"
            readonly property bool muted: root.kind === "volume" ? root.volumeMuted : root.kind === "mic" ? root.micMuted : false
            readonly property real level: root.kind === "volume" ? root.volume : root.kind === "brightness" ? root.brightness : 0

            width: parent.width
            implicitHeight: content.implicitHeight + 28
            radius: 22
            color: Theme.glass
            border.width: 1
            border.color: Theme.glassBorder

            opacity: root.shown ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            transform: Translate {
                y: root.shown ? 0 : 12
                Behavior on y {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }
            }

            RowLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 14

                Icon {
                    size: 24
                    filled: true
                    color: card.muted ? Theme.foregroundDim : Theme.foreground
                    name: {
                        if (root.kind === "mic")
                            return root.micMuted ? "mic_off" : "mic";
                        if (root.kind === "brightness")
                            return root.brightness < 0.34 ? "brightness_low" : root.brightness < 0.67 ? "brightness_medium" : "brightness_high";
                        if (root.volumeMuted || root.volume <= 0)
                            return "volume_off";
                        return root.volume < 0.34 ? "volume_mute" : root.volume < 0.67 ? "volume_down" : "volume_up";
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Device name after an output switch, or the mic state.
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: card.isMic ? (root.micMuted ? "Microphone muted" : "Microphone on") : root.kind === "volume" ? root.device : ""
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: card.isMic ? Theme.fontSize : Theme.fontSize - 2
                        font.weight: card.isMic ? Font.DemiBold : Font.Normal
                        color: card.isMic ? Theme.foreground : Theme.foregroundDim
                    }

                    // Level bar (not for the mic).
                    Rectangle {
                        Layout.fillWidth: true
                        visible: !card.isMic
                        implicitHeight: 6
                        radius: 3
                        color: Theme.surfaceHigh

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, card.level))
                            height: parent.height
                            radius: 3
                            color: card.muted ? Theme.muted : Theme.foreground

                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: !card.isMic
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: card.muted ? "Muted" : `${Math.round(card.level * 100)}%`
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: card.muted ? Theme.foregroundDim : Theme.foreground
                }
            }
        }
    }
}
