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

        SoundSection {
            id: outputCard
            title: "Output"
            node: Audio.sink
            devices: Audio.outputs
        }

        SoundSection {
            id: inputCard
            title: "Input"
            node: Audio.source
            devices: Audio.inputs
            isInput: true
        }

        // Apps playing audio (only while there are some).
        Rectangle {
            visible: Audio.apps.length > 0
            width: parent.width
            implicitHeight: appsColumn.implicitHeight + 24
            radius: 14
            color: Theme.surface

            Column {
                id: appsColumn
                x: 12
                y: 12
                width: parent.width - 24
                spacing: 10

                Text {
                    text: "Apps"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Repeater {
                    model: Audio.apps

                    AppVolume {
                        required property var modelData
                        node: modelData
                        width: appsColumn.width
                    }
                }
            }
        }

        MenuItem {
            icon: "settings"
            label: "Sound settings"
            onClicked: {
                menu.shown = false;
                Quickshell.execDetached(["pavucontrol"]);
            }
        }
    }
}
