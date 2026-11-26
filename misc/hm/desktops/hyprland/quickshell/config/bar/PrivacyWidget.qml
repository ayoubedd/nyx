import QtQuick
import qs.common
import qs.services
import qs.components

// Bar privacy indicator: coloured icons while the mic, camera or screen is in
// use. Slides in/out; click for the list of apps.
Item {
    id: root

    implicitWidth: Privacy.any ? button.implicitWidth : 0
    implicitHeight: 26
    clip: true
    opacity: Privacy.any ? 1 : 0
    visible: implicitWidth > 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.ms(240)
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Theme.ms(200)
        }
    }

    MouseArea {
        id: button

        implicitWidth: row.implicitWidth + 16
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: menu.toggle()

        Tooltip {
            target: button
            text: [...Privacy.micApps.map(a => `Microphone: ${a}`), ...Privacy.cameraApps.map(a => `Camera: ${a}`), ...Privacy.screenApps.map(a => `Screen: ${a}`)].join("  ·  ")
            show: button.containsMouse && !button.pressed && !menu.shown
        }

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: menu.shown ? Theme.surfaceHigh : button.containsMouse ? Theme.surface : Qt.rgba(1, 1, 1, 0.06)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animDuration
                }
            }
        }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Icon {
                visible: Privacy.mic
                name: "mic"
                filled: true
                size: 16
                color: Theme.privacyMic
            }

            Icon {
                visible: Privacy.camera
                name: "videocam"
                filled: true
                size: 16
                color: Theme.privacyCamera
            }

            Icon {
                visible: Privacy.screen
                name: "screen_share"
                filled: true
                size: 16
                color: Theme.privacyScreen
            }
        }
    }

    // One card per kind of access in use (same card style as the sound,
    // Wi-Fi and Bluetooth menus).
    Dropdown {
        id: menu
        target: button
        contentWidth: 320
        contentSpacing: 8

        PrivacySection {
            visible: Privacy.mic
            title: "Microphone"
            icon: Audio.source?.audio?.muted ? "mic_off" : "mic"
            tint: Theme.privacyMic
            detail: Audio.source?.audio?.muted ? "Muted" : Audio.source ? Audio.deviceName(Audio.source) : ""
            apps: Privacy.micApps

            // Mute / unmute the input for everyone at once.
            PillButton {
                readonly property bool muted: Audio.source?.audio?.muted ?? false
                text: muted ? "Unmute" : "Mute"
                onClicked: Audio.toggleMute(Audio.source)
            }
        }

        PrivacySection {
            visible: Privacy.camera
            title: "Camera"
            icon: "videocam"
            tint: Theme.privacyCamera
            apps: Privacy.cameraApps
        }

        PrivacySection {
            visible: Privacy.screen
            title: "Screen sharing"
            icon: "screen_share"
            tint: Theme.privacyScreen
            apps: Privacy.screenApps
        }
    }

    // Nothing left to show: close the list.
    Connections {
        target: Privacy
        function onAnyChanged() {
            if (!Privacy.any)
                menu.shown = false;
        }
    }
}
