import QtQuick
import Quickshell.Hyprland
import qs.common
import qs.components

// Shows the active Hyprland submap (keybind mode) next to the workspaces,
// with its keys, so it's obvious a mode is on:
//   [⤡ RESIZE   h j k l  resize · Esc  exit]
// Follows Hyprland's `submap` event (empty name = back to normal).
// Hints for the submaps in hypr/binds.lua; others just show their name.
Item {
    id: root

    property string submap: ""

    readonly property var info: ({
            resize: {
                icon: "open_in_full",
                keys: "h j k l  resize"
            },
            move: {
                icon: "open_with",
                keys: "h j k l  move"
            },
            notifications: {
                icon: "notifications",
                keys: "c clear · t center · d DND"
            }
        })
    readonly property var current: info[submap] ?? {
        icon: "keyboard",
        keys: ""
    }

    implicitWidth: submap ? pill.width : 0
    implicitHeight: 26
    clip: true
    visible: implicitWidth > 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.ms(180)
            easing.type: Easing.OutCubic
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap")
                root.submap = event.data ?? "";
        }
    }

    Rectangle {
        id: pill
        width: row.implicitWidth + 20
        height: parent.height
        radius: height / 2
        color: Theme.accent

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: root.current.icon
                filled: true
                size: 15
                color: Theme.background
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.submap.toUpperCase()
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.weight: Font.Bold
                font.letterSpacing: 0.5
                color: Theme.background
            }

            Text {
                visible: root.current.keys !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: root.current.keys
                font.family: "monospace"
                font.pixelSize: Theme.fontSize - 2
                color: Theme.background
                opacity: 0.85
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Esc  exit"
                font.family: "monospace"
                font.pixelSize: Theme.fontSize - 2
                color: Theme.background
                opacity: 0.65
            }
        }
    }
}
