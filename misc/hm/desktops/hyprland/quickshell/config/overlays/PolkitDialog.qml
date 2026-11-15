import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import qs.common
import qs.components

// Polkit authentication agent (replaces polkit-gnome): the prompt shown when
// something needs admin rights (pkexec, systemctl, NetworkManager, …).
//
// Only one agent can be registered per session, so polkit-gnome must not run
// (machines/x1/default.nix no longer imports it).
//
// The polkit-1 PAM stack may ask to touch the YubiKey instead of typing; that
// arrives as an info message with no response required.
Scope {
    id: root

    PolkitAgent {
        id: agent
    }

    readonly property var flow: agent.flow
    readonly property bool open: agent.isActive && !!flow

    PanelWindow {
        id: window

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.open || card.opacity > 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nyx-polkit"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"

        // Dimmed (and, via the Hyprland layer rule, blurred) backdrop.
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: root.open ? 0.45 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        Rectangle {
            id: card

            anchors.centerIn: parent
            width: 420
            implicitHeight: content.implicitHeight + 48
            radius: 20
            color: Theme.background
            border.width: 1
            border.color: Theme.surfaceHigh

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.96

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 24
                spacing: 12

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 56
                    implicitHeight: 56
                    radius: 28
                    color: Theme.surface

                    Icon {
                        anchors.centerIn: parent
                        name: "admin_panel_settings"
                        filled: true
                        size: 30
                        color: Theme.accent
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "Authentication required"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 3
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: root.flow?.message ?? ""
                    wrapMode: Text.Wrap
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    color: Theme.foregroundDim
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                    text: root.flow?.actionId ?? ""
                    elide: Text.ElideMiddle
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.muted
                }

                // Password (shakes on failure).
                Rectangle {
                    id: field
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    implicitHeight: 40
                    radius: 12
                    color: Theme.surface
                    border.width: 1
                    border.color: (root.flow?.supplementaryIsError ?? false) ? Theme.urgent : input.activeFocus ? Theme.accent : Theme.surfaceHigh
                    opacity: (root.flow?.isResponseRequired ?? false) ? 1 : 0.5

                    transform: Translate {
                        id: shake
                    }

                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation {
                            target: shake
                            property: "x"
                            to: -12
                            duration: 50
                        }
                        NumberAnimation {
                            target: shake
                            property: "x"
                            to: 12
                            duration: 80
                        }
                        NumberAnimation {
                            target: shake
                            property: "x"
                            to: 0
                            duration: 60
                        }
                    }

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: (root.flow?.responseVisible ?? false) ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "●"
                        enabled: root.flow?.isResponseRequired ?? false
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 1
                        color: Theme.foreground
                        clip: true
                        focus: true

                        onAccepted: root.submit()
                        Keys.onEscapePressed: root.cancel()

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !input.text
                            text: (root.flow?.inputPrompt ?? "").replace(/:\s*$/, "") || "Password"
                            font: input.font
                            color: Theme.foregroundDim
                        }
                    }
                }

                // Info / error from PAM (e.g. "Please touch the device", "Sorry, try again").
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                    text: root.flow?.supplementaryMessage ?? ""
                    wrapMode: Text.Wrap
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    color: (root.flow?.supplementaryIsError ?? false) ? Theme.urgent : Theme.foregroundDim
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    spacing: 10

                    DialogButton {
                        Layout.fillWidth: true
                        text: "Cancel"
                        onClicked: root.cancel()
                    }

                    DialogButton {
                        Layout.fillWidth: true
                        text: "Authenticate"
                        primary: true
                        enabled: root.flow?.isResponseRequired ?? false
                        onClicked: root.submit()
                    }
                }
            }
        }
    }

    function submit() {
        if (!flow?.isResponseRequired)
            return;
        flow.submit(input.text);
        input.text = "";
    }

    function cancel() {
        input.text = "";
        flow?.cancelAuthenticationRequest();
    }

    // New request (also after a failed attempt): focus the field.
    Connections {
        target: agent
        function onAuthenticationRequestStarted() {
            input.text = "";
            input.forceActiveFocus();
        }
    }

    Connections {
        target: root.flow
        ignoreUnknownSignals: true
        function onAuthenticationFailed() {
            shakeAnim.restart();
        }
        function onIsResponseRequiredChanged() {
            if (root.flow?.isResponseRequired)
                input.forceActiveFocus();
        }
    }
}
