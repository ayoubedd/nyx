pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The "current" MPRIS player for the bar: whatever is playing, else a paused
// one. The bar controls show while playing and linger for a minute after a
// pause, so a long-paused browser tab doesn't keep them around forever.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: players.find(p => p.isPlaying) ?? players.find(p => p.playbackState === MprisPlaybackState.Paused) ?? null
    readonly property bool playing: player?.isPlaying ?? false

    property bool lingering: false
    readonly property bool show: !!player && (playing || lingering)

    onPlayingChanged: {
        if (playing) {
            linger.stop();
            lingering = true;
        } else {
            linger.restart();
        }
    }

    Timer {
        id: linger
        interval: 60000
        onTriggered: root.lingering = false
    }
}
