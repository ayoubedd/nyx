import QtQuick
import Quickshell
import qs.common
import qs.services
import qs.components

// Bar volume icon + quick sound menu (output / input device + volume, app
// volumes). The rest lives in the notification center's Sound view.
//   click         open the menu
//   scroll        change output volume
//   middle click  mute/unmute output
BarButton {
    id: root

    icon: Audio.volumeIcon(Audio.volume, Audio.muted)
    iconColor: Audio.muted ? Theme.foregroundDim : Theme.foreground
    active: menu.shown
    tooltip: Audio.sink ? `${Audio.deviceName(Audio.sink)} · ${Audio.muted ? "muted" : `${Math.round(Audio.volume * 100)}%`}` : "No output device"
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            Audio.toggleMute(Audio.sink);
        else
            menu.toggle();
    }

    // qs -c nyx ipc call bar toggle sound
    Connections {
        target: Ui
        function onMenuRequested(name, screen) {
            if (name === "sound" && (root.QsWindow.window?.screen?.name ?? "") === screen)
                menu.toggle();
        }
    }

    WheelHandler {
        onWheel: event => Audio.setVolume(Audio.sink, Audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
    }

    Dropdown {
        id: menu
        target: root
        contentWidth: 340
        // The sliders show the level; don't also pop the OSD.
        suppressOsd: true
        contentSpacing: 8

        // Collapse the device pickers when the menu closes.
        onShownChanged: if (!shown) {
            outputCard.expanded = false;
            inputCard.expanded = false;
        }

        // Output and input in one card.
        Card {
            spacing: 12

            SoundSection {
                id: outputCard
                node: Audio.sink
                devices: Audio.outputs
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.glassBorder
            }

            SoundSection {
                id: inputCard
                // With noise suppression on, the default input is the
                // filter; this still shows and controls the real mic.
                node: NoiseSuppression.active ? NoiseSuppression.micNode : Audio.source
                devices: Audio.inputs
                isInput: true
            }
        }

        // Apps playing audio (only while there are some).
        Card {
            id: appsColumn
            visible: Audio.apps.length > 0

            Repeater {
                model: Audio.apps

                AppVolume {
                    required property var modelData
                    node: modelData
                    width: appsColumn.contentWidth
                }
            }
        }

        MenuItem {
            icon: "settings"
            label: "Sound settings…"
            onClicked: {
                menu.shown = false;
                Notifs.openCenterAt("sound");
            }
        }
    }
}
