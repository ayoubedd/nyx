import QtQuick
import Quickshell.Widgets
import qs.common
import qs.services

// Compact now-playing controls next to the clock. Slides open when something
// plays (see Media.qml); clicking the title opens the dashboard player.
Item {
    id: root

    signal openPlayer

    readonly property var player: Media.player

    implicitWidth: Media.show ? pill.implicitWidth : 0
    implicitHeight: 26
    clip: true
    opacity: Media.show ? 1 : 0
    visible: implicitWidth > 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.ms(260)
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Theme.ms(200)
        }
    }

    // No background of its own: it shares the clock's pill (see Bar.qml).
    Item {
        id: pill

        implicitWidth: row.implicitWidth + 8
        height: parent.height

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            // Divider between the clock and the player.
            Item {
                width: 9
                height: 22

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 14
                    color: Theme.muted
                }
            }

            // Art + title: opens the full player in the dashboard.
            MouseArea {
                id: info
                implicitWidth: infoRow.implicitWidth + 8
                implicitHeight: 22
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openPlayer()

                Row {
                    id: infoRow
                    anchors.verticalCenter: parent.verticalCenter
                    x: 2
                    spacing: 8

                    ClippingRectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 18
                        radius: 5
                        color: Theme.surfaceHigh

                        Image {
                            id: art
                            anchors.fill: parent
                            source: root.player?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 36
                            sourceSize.height: 36
                        }

                        Icon {
                            anchors.centerIn: parent
                            visible: art.status !== Image.Ready
                            name: "music_note"
                            size: 13
                            color: Theme.foregroundDim
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, 220)
                        elide: Text.ElideRight
                        text: {
                            const p = root.player;
                            if (!p)
                                return "";
                            const title = p.trackTitle || p.identity;
                            return p.trackArtist ? `${title} · ${p.trackArtist}` : title;
                        }
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        color: info.containsMouse ? Theme.foreground : Theme.foregroundDim
                    }
                }
            }

            BarMediaButton {
                icon: "skip_previous"
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player.previous()
            }

            BarMediaButton {
                icon: Media.playing ? "pause" : "play_arrow"
                enabled: root.player?.canTogglePlaying ?? false
                onClicked: root.player.togglePlaying()
            }

            BarMediaButton {
                icon: "skip_next"
                enabled: root.player?.canGoNext ?? false
                onClicked: root.player.next()
            }
        }
    }
}
