import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common

// Gentle fade before the idle lock: hypridle (hyprland.nix) starts it a few
// seconds before locking, and its on-resume cancels it, so any mouse move or
// key press brings the screen straight back. Click-through and without
// keyboard focus, so it never swallows that input.
//
//   qs -c nyx ipc call idlefade start 15     (seconds)
//   qs -c nyx ipc call idlefade cancel
Scope {
    id: root

    property bool fading: false
    property int duration: 15 // seconds

    readonly property real maxDarkness: 0.92
    // Animation lengths, set *before* `fading` flips: if they were bound to
    // `fading` too, the opacity could change before the duration does
    // (binding order isn't guaranteed) and animate with the old length.
    property int shadeMs: 150
    property int noteMs: 150

    function start(seconds) {
        duration = seconds > 0 ? seconds : 15;
        shadeMs = duration * 1000;
        noteMs = 1500;
        fading = true;
    }

    function cancel() {
        shadeMs = 150;
        noteMs = 150;
        fading = false;
    }

    IpcHandler {
        target: "idlefade"

        function start(seconds: int): void {
            root.start(seconds);
        }
        function cancel(): void {
            root.cancel();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            screen: modelData
            visible: root.fading || shade.opacity > 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nyx-idlefade"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            color: "transparent"
            // Fully click-through.
            mask: Region {}

            Rectangle {
                id: shade
                anchors.fill: parent
                color: "black"
                opacity: root.fading ? root.maxDarkness : 0

                // Slow in (the whole lead time), instant out when cancelled.
                Behavior on opacity {
                    NumberAnimation {
                        duration: root.shadeMs
                        easing.type: Easing.InQuad
                    }
                }
            }

            // Short note, in the middle, fading in with the shade.
            Column {
                anchors.centerIn: parent
                spacing: 8
                opacity: root.fading ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.noteMs
                    }
                }

                Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    name: "lock_clock"
                    size: 40
                    color: Theme.foreground
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Locking soon"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 6
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Move the mouse or press a key to stay"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    color: Theme.foregroundDim
                }
            }
        }
    }
}
