import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.common
import qs.services
import qs.components

// Power detail view of the notification center (opened by ⏻ in
// SessionTile.qml):
//
//   Restart / Shut Down / Log Out
//   Advanced: restart into the firmware (UEFI) settings, or into the
//             boot menu (systemd-boot)
//
// Picking one asks first: "Restart now?" with how many windows are open,
// and Cancel / Restart. Nothing runs without that second, explicit click.
ColumnLayout {
    id: root

    spacing: 12

    property var pending: null // the action waiting for confirmation

    readonly property int windowCount: Hyprland.toplevels.values.length

    readonly property var actions: [
        {
            id: "reboot",
            icon: "restart_alt",
            label: "Restart",
            detail: "Close everything and start again",
            verb: "Restart",
            command: ["systemctl", "reboot"]
        },
        {
            id: "poweroff",
            icon: "power_settings_new",
            label: "Shut Down",
            detail: "Turn the computer off",
            verb: "Shut Down",
            command: ["systemctl", "poweroff"]
        },
        {
            id: "logout",
            icon: "logout",
            label: "Log Out",
            detail: "End this session",
            verb: "Log Out",
            command: ["uwsm", "stop"]
        }
    ]

    readonly property var advanced: [
        {
            id: "firmware",
            icon: "memory",
            label: "Restart to firmware settings",
            detail: "UEFI setup (BIOS)",
            verb: "Restart",
            command: ["systemctl", "reboot", "--firmware-setup"]
        },
        {
            id: "bootmenu",
            icon: "list",
            label: "Restart to boot menu",
            detail: "Show the systemd-boot menu once",
            verb: "Restart",
            command: ["systemctl", "reboot", "--boot-loader-menu=30"]
        }
    ]

    function run(action) {
        pending = null;
        Notifs.centerOpen = false;
        Quickshell.execDetached(action.command);
    }

    // Forget a pending action when the view closes.
    Connections {
        target: Notifs
        function onCenterDetailChanged() {
            root.pending = null;
        }
    }

    // ---- confirmation (replaces the lists while asking) ----
    Tile {
        visible: !!root.pending
        Layout.fillWidth: true
        spacing: 12

        RowLayout {
            width: parent.width
            spacing: 12

            Rectangle {
                implicitWidth: 44
                implicitHeight: 44
                radius: 22
                color: Theme.urgent

                Icon {
                    anchors.centerIn: parent
                    name: root.pending?.icon ?? "power_settings_new"
                    filled: true
                    size: 22
                    color: Theme.background
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.pending ? `${root.pending.label}?` : ""
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: root.windowCount > 0 ? `${root.windowCount} open ${root.windowCount === 1 ? "window" : "windows"} will be closed. Save your work first.` : "No windows are open."
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }
            }
        }

        RowLayout {
            width: parent.width
            spacing: 8

            Item {
                Layout.fillWidth: true
            }

            ConfirmButton {
                text: "Cancel"
                onClicked: root.pending = null
            }

            ConfirmButton {
                text: root.pending?.verb ?? ""
                danger: true
                onClicked: root.run(root.pending)
            }
        }
    }

    // ---- actions ----
    Tile {
        visible: !root.pending
        Layout.fillWidth: true
        spacing: 2

        Repeater {
            model: root.actions

            ActionRow {
                required property var modelData
                action: modelData
            }
        }
    }

    Text {
        visible: !root.pending
        Layout.leftMargin: 4
        text: "Advanced"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        visible: !root.pending
        Layout.fillWidth: true
        spacing: 2

        Repeater {
            model: root.advanced

            ActionRow {
                required property var modelData
                action: modelData
            }
        }
    }

    // (icon)  Label / detail                          ›
    component ActionRow: MouseArea {
        id: row

        required property var action

        width: parent ? parent.width : 0
        implicitHeight: 46
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.pending = row.action

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: 10
            color: row.containsMouse ? Theme.glassTileHover : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 12

            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                radius: 16
                color: row.containsMouse ? Theme.muted : Theme.surfaceHigh

                Icon {
                    anchors.centerIn: parent
                    name: row.action.icon
                    size: 17
                    color: Theme.foreground
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: row.action.label
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.Medium
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: row.action.detail
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            Icon {
                name: "chevron_right"
                size: 16
                color: Theme.foregroundDim
            }
        }
    }

    component ConfirmButton: MouseArea {
        id: button

        property string text
        property bool danger: false

        implicitWidth: label.implicitWidth + 28
        implicitHeight: 32
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: button.danger ? (button.containsMouse ? Qt.lighter(Theme.urgent, 1.1) : Theme.urgent) : button.containsMouse ? Theme.glassTileHover : Theme.glassTile
            border.width: button.danger ? 0 : 1
            border.color: Theme.glassBorder
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: button.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: button.danger ? Font.DemiBold : Font.Normal
            color: button.danger ? Theme.background : Theme.foreground
        }
    }
}
