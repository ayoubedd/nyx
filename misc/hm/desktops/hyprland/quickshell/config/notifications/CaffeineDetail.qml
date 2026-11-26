import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Keep Awake detail view of the notification center (services/Caffeine.qml):
// status, a switch, and how long to keep the machine awake. Picking a
// duration applies it right away.
ColumnLayout {
    id: root

    spacing: 12

    // minutes: 0 = until turned off
    readonly property var durations: [
        {
            minutes: 15,
            label: "15 minutes"
        },
        {
            minutes: 30,
            label: "30 minutes"
        },
        {
            minutes: 60,
            label: "1 hour"
        },
        {
            minutes: 120,
            label: "2 hours"
        },
        {
            minutes: 240,
            label: "4 hours"
        },
        {
            minutes: 0,
            label: "Until turned off"
        }
    ]

    // ---- status + switch ----
    Tile {
        Layout.fillWidth: true

        RowLayout {
            width: parent.width
            spacing: 12

            Rectangle {
                implicitWidth: 44
                implicitHeight: 44
                radius: 22
                color: Caffeine.active ? Theme.accent : Theme.surfaceHigh

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    name: "coffee"
                    filled: Caffeine.active
                    size: 22
                    color: Caffeine.active ? Theme.background : Theme.foreground
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: Caffeine.active ? "On" : "Off"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: Caffeine.active ? Caffeine.remainingText : Caffeine.autoActive ? `On automatically · ${Caffeine.autoReason || "ending soon"}` : "Dims, locks and sleeps when idle"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }
            }

            Toggle {
                checked: Caffeine.active
                onToggled: Caffeine.active ? Caffeine.disable() : Caffeine.enable(Caffeine.minutes)
            }
        }
    }

    // ---- automatic ----
    Tile {
        Layout.fillWidth: true

        SwitchRow {
            icon: "auto_mode"
            label: "Automatically"
            detail: !Caffeine.auto ? "Off" : Caffeine.autoReason ? `Now: ${Caffeine.autoReason}` : Caffeine.autoHold ? "Ending in a moment" : "On calls, screen sharing and fullscreen video"
            checked: Caffeine.auto
            onToggled: Caffeine.auto = !Caffeine.auto
        }
    }

    // ---- duration ----
    Text {
        Layout.leftMargin: 4
        text: "Keep awake for"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        Layout.fillWidth: true
        spacing: 2

        Repeater {
            model: root.durations

            MouseArea {
                id: option
                required property var modelData
                readonly property bool selected: Caffeine.active && Caffeine.minutes === modelData.minutes

                width: parent.width
                implicitHeight: 36
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Caffeine.enable(modelData.minutes)

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: -6
                    anchors.rightMargin: -6
                    radius: 10
                    color: option.containsMouse ? Theme.glassTileHover : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Icon {
                        name: option.modelData.minutes === 0 ? "all_inclusive" : "schedule"
                        size: 17
                        color: option.selected ? Theme.accent : Theme.foregroundDim
                    }

                    Text {
                        Layout.fillWidth: true
                        text: option.modelData.label
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: option.selected ? Font.DemiBold : Font.Normal
                        color: Theme.foreground
                    }

                    // Time left on the running choice.
                    Text {
                        visible: option.selected && Caffeine.until > 0
                        text: Caffeine.remainingText
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }

                    Icon {
                        visible: option.selected
                        name: "check"
                        size: 18
                        color: Theme.accent
                    }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        wrapMode: Text.WordWrap
        text: "While on, the screen won't dim, lock or turn off and the laptop won't sleep when idle. Closing the lid or choosing Sleep still works."
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foregroundDim
    }
}
