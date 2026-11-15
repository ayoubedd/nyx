import QtQuick

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
            duration: 240
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 200
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

    Dropdown {
        id: menu
        target: button
        contentWidth: 260

        DropdownHeader {
            title: "In use"
            showToggle: false
        }

        Repeater {
            model: Privacy.micApps

            MenuItem {
                required property string modelData
                icon: "mic"
                label: modelData
                detail: "Microphone"
                tint: Theme.privacyMic
                cursorShape: Qt.ArrowCursor
            }
        }

        Repeater {
            model: Privacy.cameraApps

            MenuItem {
                required property string modelData
                icon: "videocam"
                label: modelData
                detail: "Camera"
                tint: Theme.privacyCamera
                cursorShape: Qt.ArrowCursor
            }
        }

        Repeater {
            model: Privacy.screenApps

            MenuItem {
                required property string modelData
                icon: "screen_share"
                label: modelData
                detail: "Screen"
                tint: Theme.privacyScreen
                cursorShape: Qt.ArrowCursor
            }
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
