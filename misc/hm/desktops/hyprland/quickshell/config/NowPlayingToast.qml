import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

// "Now playing" toast: slides down under the bar's clock/player pill when a
// new track starts (Media.qml's current player).
//
// - Waits 0.5s after a change: browsers send title, artist and art as
//   separate updates; each track is shown once (pause/resume doesn't repeat).
// - Not for what's already playing at startup, with Do Not Disturb, or while
//   a dropdown / the dashboard / the notification center is open.
// - Hides after 4s; hover keeps it, click dismisses.
Scope {
    id: root

    readonly property var player: Media.player
    readonly property string key: player && player.trackTitle ? `${player.identity}|${player.trackTitle}|${player.trackArtist}` : ""

    property bool armed: false
    property string lastKey: ""
    property bool shown: false

    function maybeShow() {
        const p = player;
        if (!p || !p.isPlaying || !p.trackTitle || key === lastKey)
            return;
        lastKey = key;
        if (Notifs.dnd || Notifs.centerOpen || Ui.active)
            return;
        shown = true;
        hideTimer.restart();
    }

    onKeyChanged: if (armed)
        settle.restart()

    // Don't announce whatever was already playing when quickshell started.
    Timer {
        running: true
        interval: 2500
        onTriggered: {
            root.lastKey = root.key;
            root.armed = true;
        }
    }

    Timer {
        id: settle
        interval: 500
        onTriggered: root.maybeShow()
    }

    Timer {
        id: hideTimer
        interval: 4000
        onTriggered: {
            if (card.hovered)
                restart();
            else
                root.shown = false;
        }
    }

    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        // Fixed height here (not card.height, which follows the window and
        // would loop back into `visible`).
        visible: root.shown || card.y > -win.implicitHeight

        anchors.top: true
        margins.top: 18
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nyx-nowplaying"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        implicitWidth: 400
        implicitHeight: 76

        MouseArea {
            id: card

            readonly property bool hovered: containsMouse

            width: parent.width
            height: parent.height
            // Slides down from under the bar, back up to hide.
            y: root.shown ? 0 : -height - 8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.shown = false

            Behavior on y {
                NumberAnimation {
                    duration: 260
                    easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 18
                // Mostly opaque so it reads over any wallpaper/window; the
                // Hyprland blur (layer rule) shows through softly.
                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.92)
                border.width: 1
                border.color: Theme.glassBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    ClippingRectangle {
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 56
                        radius: 10
                        color: Theme.surfaceHigh

                        Image {
                            id: art
                            anchors.fill: parent
                            source: root.player?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 112
                            sourceSize.height: 112
                        }

                        Icon {
                            anchors.centerIn: parent
                            visible: art.status !== Image.Ready
                            name: "music_note"
                            size: 26
                            color: Theme.foregroundDim
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: `Now playing · ${root.player?.identity ?? ""}`
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 3
                            color: Theme.foregroundDim
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.player?.trackTitle ?? ""
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 1
                            font.weight: Font.DemiBold
                            color: Theme.foreground
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: [root.player?.trackArtist, root.player?.trackAlbum].filter(s => !!s).join(" — ")
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            color: Theme.foregroundDim
                        }
                    }
                }
            }
        }
    }
}
