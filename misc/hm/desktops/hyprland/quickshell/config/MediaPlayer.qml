import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Mpris

// Now-playing card for MPRIS players (Spotify, browsers, mpv, ...).
Rectangle {
    id: root

    property bool active: false

    readonly property var players: Mpris.players.values
    property var chosen: null
    // The one the user picked, else whatever is playing, else the first.
    readonly property var player: (chosen && players.includes(chosen)) ? chosen : players.find(p => p.isPlaying) ?? players[0] ?? null

    // ---- position/length, robust against Firefox ----
    // Firefox/LibreWolf drop mpris:length and report Position 0 after a seek.
    // Remember the last good length per track, and after a seek estimate the
    // position from the seek target + elapsed time until the player reports a
    // real position again.
    readonly property string trackKey: player ? (player.metadata["xesam:url"] || player.trackTitle || player.identity || "") : ""
    property real knownLength: 0
    property real seekBase: -1 // seconds; -1 = trust the player
    property real seekAt: 0
    property real tick: 0 // bumped every second so `position` re-evaluates

    readonly property real length: (player?.length ?? 0) > 0 ? player.length : knownLength
    readonly property real position: {
        tick;
        const p = player?.position ?? 0;
        if (seekBase < 0 || p >= 1)
            return p;
        const elapsed = player?.isPlaying ? (Date.now() - seekAt) / 1000 : 0;
        return Math.min(length, seekBase + elapsed);
    }

    function seek(fraction) {
        const t = Math.max(0, Math.min(1, fraction)) * length;
        seekBase = t;
        seekAt = Date.now();
        player.position = t;
    }

    onTrackKeyChanged: {
        knownLength = (player?.length ?? 0) > 0 ? player.length : 0;
        seekBase = -1;
    }

    Connections {
        target: root.player
        ignoreUnknownSignals: true

        function onLengthChanged() {
            if (root.player.length > 0)
                root.knownLength = root.player.length;
        }

        // Freeze/resume the estimate across pause/play.
        function onIsPlayingChanged() {
            if (root.seekBase >= 0) {
                root.seekBase = root.position;
                root.seekAt = Date.now();
            }
        }
    }

    function fmt(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const s = Math.floor(seconds);
        return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
    }

    radius: Theme.radius
    color: Theme.surface

    // MPRIS doesn't push position updates; poll while visible and playing.
    Timer {
        running: root.active && (root.player?.isPlaying ?? false)
        interval: 1000
        repeat: true
        onTriggered: {
            root.player.positionChanged();
            if (root.player.position >= 1)
                root.seekBase = -1; // player reports real positions again
            root.tick = Date.now();
        }
    }

    // ---- nothing playing ----
    Column {
        anchors.centerIn: parent
        visible: !root.player
        spacing: 6

        Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "music_off"
            size: 28
            color: Theme.foregroundDim
        }

        Text {
            text: "Nothing playing"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: Theme.foregroundDim
        }
    }

    // ---- player ----
    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        visible: !!root.player
        spacing: 16

        ClippingRectangle {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            Layout.alignment: Qt.AlignVCenter
            radius: 12
            color: Theme.surfaceHigh

            Image {
                id: art
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 240
                sourceSize.height: 240
            }

            Icon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                name: "music_note"
                size: 40
                color: Theme.foregroundDim
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            // Player switcher when more than one is running.
            Row {
                visible: root.players.length > 1
                spacing: 6
                Layout.bottomMargin: 4

                Repeater {
                    model: root.players

                    PillButton {
                        required property var modelData
                        text: modelData.identity
                        opacity: modelData === root.player ? 1 : 0.5
                        onClicked: root.chosen = modelData
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.player?.trackTitle || root.player?.identity || ""
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 2
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Text {
                Layout.fillWidth: true
                text: [root.player?.trackArtist, root.player?.trackAlbum].filter(s => !!s).join(" — ")
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                color: Theme.foregroundDim
            }

            // Progress (click to seek when supported).
            Item {
                Layout.fillWidth: true
                Layout.topMargin: 8
                implicitHeight: 6
                visible: root.length > 0

                Rectangle {
                    anchors.fill: parent
                    radius: 3
                    color: Theme.surfaceHigh

                    Rectangle {
                        width: root.length > 0 ? parent.width * Math.min(1, root.position / root.length) : 0
                        height: parent.height
                        radius: 3
                        color: Theme.foreground
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    enabled: root.player?.canSeek ?? false
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: mouse => root.seek((mouse.x - 6) / parent.width)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.length > 0

                Text {
                    Layout.fillWidth: true
                    text: root.fmt(root.position)
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }

                Text {
                    text: root.fmt(root.length)
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            // Controls
            Row {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                spacing: 14

                MediaButton {
                    icon: "skip_previous"
                    enabled: root.player?.canGoPrevious ?? false
                    onClicked: root.player.previous()
                }

                MediaButton {
                    icon: root.player?.isPlaying ? "pause" : "play_arrow"
                    primary: true
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player.togglePlaying()
                }

                MediaButton {
                    icon: "skip_next"
                    enabled: root.player?.canGoNext ?? false
                    onClicked: root.player.next()
                }
            }
        }
    }
}
