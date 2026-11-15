import QtQuick
import Quickshell
import qs.common
import qs.services
import qs.components

// Bar volume icon + sound menu.
//   click         open the menu (output/input devices, per-app volume)
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

    WheelHandler {
        onWheel: event => Audio.setVolume(Audio.sink, Audio.volume + (event.angleDelta.y > 0 ? 0.05 : -0.05))
    }

    Dropdown {
        id: menu
        target: root
        contentWidth: 340
        // The sliders show the level; don't also pop the OSD.
        suppressOsd: true

        // ---- output ----
        DropdownHeader {
            title: "Output"
            showToggle: false
        }

        VolumeRow {
            x: 8
            width: parent.width - 16
            node: Audio.sink
        }

        Repeater {
            model: Audio.outputs

            MenuItem {
                required property var modelData
                icon: Audio.deviceIcon(modelData)
                label: Audio.deviceName(modelData)
                highlighted: modelData === Audio.sink
                onClicked: Audio.makeDefault(modelData)
            }
        }

        Separator {}

        // ---- input ----
        DropdownHeader {
            title: "Input"
            showToggle: false
        }

        VolumeRow {
            x: 8
            width: parent.width - 16
            visible: !!Audio.source
            node: Audio.source
            icon: (Audio.source?.audio?.muted ?? false) ? "mic_off" : "mic"
        }

        Repeater {
            model: Audio.inputs

            MenuItem {
                required property var modelData
                icon: Audio.deviceIcon(modelData)
                label: Audio.deviceName(modelData)
                highlighted: modelData === Audio.source
                onClicked: Audio.makeDefault(modelData)
            }
        }

        // ---- apps ----
        Separator {
            visible: Audio.apps.length > 0
        }

        DropdownHeader {
            visible: Audio.apps.length > 0
            title: "Apps"
            showToggle: false
        }

        Column {
            width: parent.width
            leftPadding: 8
            rightPadding: 8
            bottomPadding: 4
            spacing: 10

            Repeater {
                model: Audio.apps

                AppVolume {
                    required property var modelData
                    node: modelData
                    width: parent.width - 16
                }
            }
        }

        Separator {}

        MenuItem {
            icon: "settings"
            label: "Sound settings"
            tint: Theme.foregroundDim
            onClicked: {
                menu.shown = false;
                Quickshell.execDetached(["pavucontrol"]);
            }
        }
    }
}
