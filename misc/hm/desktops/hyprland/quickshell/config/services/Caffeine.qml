pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// "Keep awake": holds a systemd idle inhibitor while active. hypridle honours
// it, so the idle dim / lock / screen-off / auto-suspend listeners don't fire.
// Manual suspend (power menu, lid) still works.
//
//   qs -c nyx ipc call caffeine toggle
//   qs -c nyx ipc call caffeine enable 60     (minutes; 0 = until turned off)
//   qs -c nyx ipc call caffeine disable
//
// Automatic (setting `auto`, saved): also kept awake, separately from the
// manual switch above, while
//   - on a call: mic, camera or screen sharing in use (Privacy.qml), or
//   - a video plays fullscreen: the focused window is fullscreen AND is
//     itself a playing MPRIS player (its app id matches the player's desktop
//     entry / identity / bus name). Music playing in the background while
//     some other window (a terminal, a game, an IDE) is fullscreen doesn't
//     count, so idle dim/lock/suspend still happen then.
// It holds 30 s after the reason ends, so a pause between videos or a
// dropped mic doesn't dim the screen at once.
Singleton {
    id: root

    // ---- automatic ----
    property bool auto: true
    readonly property bool onCall: Privacy.mic || Privacy.camera || Privacy.screen
    readonly property bool fullscreenVideo: fullscreenApp !== "" && Media.players.some(p => p.isPlaying && playerIsApp(p, fullscreenApp))
    readonly property string autoReason: !auto ? "" : onCall ? (Privacy.screen ? "Sharing your screen" : "On a call") : fullscreenVideo ? "Video playing fullscreen" : ""
    property bool autoHold: false // the 30 s after the reason ended
    property string lastAutoReason: ""
    // Turned off by hand (middle-click on the cup) for the current reason;
    // resets once that reason ends, so the next call / video counts again.
    property bool autoDismissed: false
    readonly property bool autoActive: !autoDismissed && (autoReason !== "" || autoHold)

    // Either keeps the machine awake.
    readonly property bool inhibiting: active || autoActive

    onAutoReasonChanged: {
        if (autoReason !== "") {
            lastAutoReason = autoReason;
            autoHold = false;
            holdTimer.stop();
        } else {
            if (lastAutoReason !== "" && auto && !autoDismissed) {
                autoHold = true;
                holdTimer.restart();
            }
            autoDismissed = false;
        }
    }

    // Stop the automatic hold for what's happening now.
    function dismissAuto() {
        if (!autoActive)
            return;
        autoDismissed = autoReason !== "";
        autoHold = false;
        lastAutoReason = "";
        holdTimer.stop();
    }

    onAutoChanged: {
        if (!auto) {
            autoHold = false;
            holdTimer.stop();
        }
        saveSettings();
    }

    Timer {
        id: holdTimer
        interval: 30000
        onTriggered: {
            root.autoHold = false;
            root.lastAutoReason = "";
        }
    }

    // App id of the focused window while it's fullscreen, else "". Straight
    // from the Wayland foreign-toplevel protocol: live properties, no
    // polling or processes.
    readonly property string fullscreenApp: ToplevelManager.activeToplevel?.fullscreen ? (ToplevelManager.activeToplevel.appId ?? "").toLowerCase() : ""

    // Does this MPRIS player belong to the app with this (lowercase) app id?
    // e.g. LibreWolf: appId "librewolf", desktopEntry "librewolf"; mpv,
    // Spotify, Firefox ("org.mozilla.firefox" -> "firefox") likewise.
    function playerIsApp(player, app) {
        const short = app.split(".").pop();
        const entry = (player.desktopEntry ?? "").toLowerCase().replace(/\.desktop$/, "");
        if (entry !== "" && (entry === app || entry === short || entry.split(".").pop() === short))
            return true;
        return (player.identity ?? "").toLowerCase().includes(short) || (player.dbusName ?? "").toLowerCase().includes(short);
    }

    // `auto` survives restarts: $XDG_STATE_HOME/nyx/caffeine.json.
    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/caffeine.json`
    property bool restored: false

    function saveSettings() {
        if (restored)
            settings.setText(JSON.stringify({
                auto: auto
            }));
    }

    FileView {
        id: settings
        path: root.stateFile
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                root.auto = JSON.parse(text()).auto ?? true;
            } catch (e) {}
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }

    // ---- manual ----
    property bool active: false
    property real until: 0 // epoch ms; 0 = until turned off
    property int minutes: 0 // the duration chosen (0 = until turned off)
    property real now: Date.now()

    readonly property real remaining: active && until > 0 ? Math.max(0, until - now) : 0

    function enable(mins) {
        minutes = mins > 0 ? mins : 0;
        until = mins > 0 ? Date.now() + mins * 60000 : 0;
        now = Date.now();
        active = true;
    }

    function disable() {
        active = false;
        until = 0;
    }

    function toggle() {
        if (active)
            disable();
        else
            enable(0);
    }

    // "1h 20m left" (an hour or more), "14:32 left" (less), "Until turned
    // off", or "". Seconds are shown below an hour so the countdown visibly
    // moves (whole minutes rounded up looked stuck on the starting value).
    readonly property string remainingText: {
        if (!active)
            return "";
        if (until <= 0)
            return "Until turned off";
        const secs = Math.ceil(remaining / 1000);
        if (secs >= 3600) {
            const mins = Math.ceil(secs / 60);
            return `${Math.floor(mins / 60)}h ${String(mins % 60).padStart(2, "0")}m left`;
        }
        return `${Math.floor(secs / 60)}:${String(secs % 60).padStart(2, "0")} left`;
    }

    // The inhibitor lives exactly as long as this process (manual or auto).
    Process {
        running: root.inhibiting
        command: ["systemd-inhibit", "--what=idle", "--who=nyx", "--why=Keep awake (quickshell)", "--mode=block", "sleep", "infinity"]
    }

    // Ticks every second only while a timed keep-awake runs (in-process, no
    // processes started).
    Timer {
        running: root.active && root.until > 0
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();
            if (root.now >= root.until)
                root.disable();
        }
    }

    IpcHandler {
        target: "caffeine"

        function toggle(): void {
            root.toggle();
        }
        function enable(minutes: int): void {
            root.enable(minutes);
        }
        function disable(): void {
            root.disable();
        }
        function isActive(): bool {
            return root.active;
        }
        function status(): string {
            const manual = root.active ? `on · ${root.remainingText} · ${Math.round(root.remaining / 1000)}s` : "off";
            const auto = !root.auto ? "auto off" : root.autoReason ? `auto: ${root.autoReason}` : root.autoHold ? `auto: holding (${root.lastAutoReason})` : "auto: idle";
            return `${manual} · ${auto} · inhibiting=${root.inhibiting}`;
        }
    }
}
