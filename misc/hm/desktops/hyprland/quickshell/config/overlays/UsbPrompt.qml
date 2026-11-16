import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services

// "New USB device" prompt for devices USBGuard blocked (services/UsbGuard.qml):
//
//   [⌨]  New USB device
//        Logitech · USB Receiver
//        046d:c52b · port 3-1
//   [Keyboard] [Mouse]
//   ⚠ Can type keystrokes. Only allow it if you just plugged in a keyboard…
//   [Keep blocked]            [Allow once] [Allow always]
//
// Never takes keyboard focus: a blocked device posing as a keyboard can't
// type anyway, but a prompt that could be answered by keystrokes would be
// the wrong habit. Mouse only.
PanelWindow {
    id: root

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: UsbGuard.pending.length > 0

    // Below the bar (respects its exclusive zone), with some breathing room.
    anchors.top: true
    margins.top: 20
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nyx-usbguard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    color: "transparent"
    implicitWidth: 400
    implicitHeight: cards.implicitHeight

    function deviceIcon(d) {
        const k = d.kinds;
        if (k.includes("Keyboard") && !k.includes("Mouse"))
            return "keyboard";
        if (k.includes("Mouse"))
            return "mouse";
        if (k.includes("Smart card") || /yubikey|security key|fido/i.test(d.name))
            return "key";
        if (k.includes("Storage"))
            return "usb";
        if (k.includes("Network/modem"))
            return "lan";
        if (k.includes("Camera/photos") || k.includes("Video"))
            return "videocam";
        if (k.includes("Audio"))
            return "headphones";
        if (k.includes("Bluetooth") || k.includes("Wireless"))
            return "bluetooth";
        if (k.includes("Printer"))
            return "print";
        if (k.includes("Hub"))
            return "device_hub";
        return "usb";
    }

    Column {
        id: cards
        width: parent.width
        spacing: 8

        Repeater {
            model: UsbGuard.pending

            Rectangle {
                id: card
                required property var modelData
                readonly property var dev: modelData

                width: cards.width
                implicitHeight: body.implicitHeight + 28
                radius: 16
                color: Theme.background
                border.width: 1
                border.color: dev.suspicious ? Theme.urgent : Theme.surfaceHigh

                ColumnLayout {
                    id: body
                    x: 14
                    y: 14
                    width: parent.width - 28
                    spacing: 10

                    // Header.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            implicitWidth: 40
                            implicitHeight: 40
                            radius: 12
                            color: card.dev.suspicious ? Theme.urgent : card.dev.canType ? Theme.privacyMic : Theme.surfaceHigh

                            Icon {
                                anchors.centerIn: parent
                                name: root.deviceIcon(card.dev)
                                filled: true
                                size: 22
                                color: card.dev.canType || card.dev.suspicious ? Theme.background : Theme.foreground
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "New USB device · blocked"
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 3
                                font.weight: Font.DemiBold
                                color: Theme.foregroundDim
                            }

                            Text {
                                Layout.fillWidth: true
                                text: [card.dev.vendor, card.dev.name].filter(s => s).join(" · ") || "Unknown device"
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize
                                font.weight: Font.DemiBold
                                color: Theme.foreground
                            }

                            Text {
                                Layout.fillWidth: true
                                text: [`${card.dev.vid}:${card.dev.pid}`, card.dev.port ? `port ${card.dev.port}` : "", card.dev.serial ? `serial ${card.dev.serial}` : ""].filter(s => s).join(" · ")
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 3
                                color: Theme.foregroundDim
                            }
                        }
                    }

                    // What it says it can do (its USB interfaces).
                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: card.dev.kinds

                            Rectangle {
                                required property string modelData
                                readonly property bool risky: modelData === "Keyboard" || modelData === "Input"

                                width: chipText.implicitWidth + 16
                                height: 22
                                radius: 11
                                color: risky ? Qt.rgba(Theme.privacyMic.r, Theme.privacyMic.g, Theme.privacyMic.b, 0.18) : Theme.surface

                                Text {
                                    id: chipText
                                    anchors.centerIn: parent
                                    text: parent.modelData
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSize - 3
                                    color: parent.risky ? Theme.privacyMic : Theme.foreground
                                }
                            }
                        }
                    }

                    // Warnings.
                    Rectangle {
                        visible: card.dev.canType
                        Layout.fillWidth: true
                        implicitHeight: warning.implicitHeight + 16
                        radius: 10
                        color: Qt.rgba(Theme.urgent.r, Theme.urgent.g, Theme.urgent.b, card.dev.suspicious ? 0.2 : 0.1)

                        RowLayout {
                            id: warning
                            x: 10
                            y: 8
                            width: parent.width - 20
                            spacing: 8

                            Icon {
                                Layout.alignment: Qt.AlignTop
                                name: "warning"
                                filled: true
                                size: 16
                                color: Theme.urgent
                            }

                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: card.dev.suspicious ? "This device is a keyboard and also storage/network. That's how \"BadUSB\" sticks disguise themselves to type commands. Keep it blocked unless you know exactly what it is." : "This device can type keystrokes. Only allow it if you just plugged in a keyboard, mouse receiver or security key."
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 2
                                color: Theme.foreground
                            }
                        }
                    }

                    // Actions.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        PromptButton {
                            text: "Keep blocked"
                            onClicked: UsbGuard.keepBlocked(card.dev)
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        PromptButton {
                            text: "Allow once"
                            onClicked: UsbGuard.allowOnce(card.dev)
                        }

                        PromptButton {
                            text: "Allow always"
                            primary: true
                            onClicked: UsbGuard.allowAlways(card.dev)
                        }
                    }
                }
            }
        }
    }

    component PromptButton: MouseArea {
        id: button

        property string text
        property bool primary: false

        implicitWidth: label.implicitWidth + 24
        implicitHeight: 30
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: button.primary ? (button.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent) : button.containsMouse ? Theme.surfaceHigh : Theme.surface
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: button.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: button.primary ? Font.DemiBold : Font.Normal
            color: button.primary ? Theme.background : Theme.foreground
        }
    }
}
