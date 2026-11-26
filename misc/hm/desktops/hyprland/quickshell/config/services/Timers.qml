pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Timer, stopwatch and Pomodoro for the dashboard's Timer tab
// (dashboard/TimerPage.qml) and the bar pill (bar/TimerWidget.qml).
//
// Times are kept as end/start timestamps, so they're exact and survive a
// quickshell restart ($XDG_STATE_HOME/nyx/timers.json). A 1 s tick runs only
// while something is running. When time is up: a critical notification
// (shows through Do Not Disturb) and a chime.
//
//   qs -c nyx ipc call timers start 10        (minutes)
//   qs -c nyx ipc call timers pause | resume | reset
Singleton {
    id: root

    property real now: Date.now()

    // ---- countdown timer ----
    property int timerMinutes: 10 // chosen duration
    property real timerEnd: 0 // epoch ms while running
    property real timerLeft: 0 // ms left while paused (0 = not paused)
    readonly property bool timerRunning: timerEnd > 0
    readonly property bool timerPaused: !timerRunning && timerLeft > 0
    readonly property real timerRemaining: timerRunning ? Math.max(0, timerEnd - now) : timerPaused ? timerLeft : timerMinutes * 60000

    // minutes: a new duration; 0 = resume a paused one (or start the last).
    function startTimer(minutes) {
        const resume = !minutes && timerPaused;
        if (minutes)
            timerMinutes = minutes;
        const duration = resume ? timerLeft : timerMinutes * 60000;
        now = Date.now();
        timerLeft = 0;
        timerEnd = now + duration;
        save();
    }

    function pauseTimer() {
        if (!timerRunning)
            return;
        timerLeft = Math.max(0, timerEnd - Date.now());
        timerEnd = 0;
        save();
    }

    function resetTimer() {
        timerEnd = 0;
        timerLeft = 0;
        save();
    }

    // ---- stopwatch ----
    property real swStart: 0 // epoch ms while running
    property real swAccum: 0 // ms counted before the current run
    property var laps: [] // ms at each lap, newest first
    readonly property bool swRunning: swStart > 0
    readonly property real swElapsed: swAccum + (swRunning ? now - swStart : 0)

    function startStopwatch() {
        if (swRunning)
            return;
        swStart = now = Date.now();
        save();
    }

    function pauseStopwatch() {
        if (!swRunning)
            return;
        swAccum += Date.now() - swStart;
        swStart = 0;
        save();
    }

    function lap() {
        laps = [swElapsed, ...laps].slice(0, 50);
        save();
    }

    function resetStopwatch() {
        swStart = 0;
        swAccum = 0;
        laps = [];
        save();
    }

    // ---- Pomodoro ----
    property int focusMinutes: 25
    property int shortMinutes: 5
    property int longMinutes: 15
    property int roundsBeforeLong: 4
    property bool autoContinue: true // start the next phase by itself
    property string phase: "focus" // "focus" | "short" | "long"
    property int round: 1 // focus round within the set (1..roundsBeforeLong)
    property real pomoEnd: 0
    property real pomoLeft: 0
    readonly property bool pomoRunning: pomoEnd > 0
    readonly property bool pomoPaused: !pomoRunning && pomoLeft > 0
    readonly property int phaseMinutes: phase === "focus" ? focusMinutes : phase === "short" ? shortMinutes : longMinutes
    readonly property real pomoRemaining: pomoRunning ? Math.max(0, pomoEnd - now) : pomoPaused ? pomoLeft : phaseMinutes * 60000
    readonly property string phaseLabel: phase === "focus" ? `Focus ${round}/${roundsBeforeLong}` : phase === "short" ? "Short break" : "Long break"

    function startPomodoro() {
        const duration = pomoPaused ? pomoLeft : phaseMinutes * 60000;
        now = Date.now();
        pomoLeft = 0;
        pomoEnd = now + duration;
        save();
    }

    function pausePomodoro() {
        if (!pomoRunning)
            return;
        pomoLeft = Math.max(0, pomoEnd - Date.now());
        pomoEnd = 0;
        save();
    }

    function resetPomodoro() {
        pomoEnd = 0;
        pomoLeft = 0;
        phase = "focus";
        round = 1;
        save();
    }

    // Next phase: focus -> short break (or long after the last round) -> focus.
    function nextPhase(start) {
        if (phase === "focus") {
            phase = round >= roundsBeforeLong ? "long" : "short";
        } else {
            round = phase === "long" ? 1 : round + 1;
            phase = "focus";
        }
        pomoEnd = 0;
        pomoLeft = 0;
        if (start)
            startPomodoro();
        else
            save();
    }

    // ---- shared ----
    readonly property bool anyRunning: timerRunning || swRunning || pomoRunning
    readonly property bool anyActive: anyRunning || timerPaused || pomoPaused || swAccum > 0

    // What the bar pill shows: Pomodoro first, then the timer, then the
    // stopwatch. { kind, text, paused }
    readonly property var barItem: {
        if (pomoRunning || pomoPaused)
            return {
                kind: phase === "focus" ? "pomodoro" : "break",
                text: clock(pomoRemaining),
                paused: pomoPaused
            };
        if (timerRunning || timerPaused)
            return {
                kind: "timer",
                text: clock(timerRemaining),
                paused: timerPaused
            };
        if (swRunning || swAccum > 0)
            return {
                kind: "stopwatch",
                text: clock(swElapsed),
                paused: !swRunning
            };
        return null;
    }

    // Pause / resume whatever the bar pill shows (middle-click).
    function toggleBarItem() {
        const k = barItem?.kind;
        if (k === "pomodoro" || k === "break")
            pomoRunning ? pausePomodoro() : startPomodoro();
        else if (k === "timer")
            timerRunning ? pauseTimer() : startTimer(0);
        else if (k === "stopwatch")
            swRunning ? pauseStopwatch() : startStopwatch();
    }

    // "4:59", "1:02:03"; ceil for countdowns so 0:00 means done.
    function clock(ms) {
        const s = Math.max(0, Math.ceil(ms / 1000));
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), sec = s % 60;
        const mm = h > 0 ? String(m).padStart(2, "0") : String(m);
        return `${h > 0 ? `${h}:` : ""}${mm}:${String(sec).padStart(2, "0")}`;
    }

    Timer {
        running: root.anyRunning
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();
            if (root.timerRunning && root.now >= root.timerEnd) {
                root.timerEnd = 0;
                root.timerLeft = 0;
                root.save();
                root.alert("Time's up", `Your ${root.timerMinutes}-minute timer has finished.`, "alarm-clock-elapsed");
            }
            if (root.pomoRunning && root.now >= root.pomoEnd) {
                const was = root.phase;
                root.nextPhase(root.autoContinue);
                if (was === "focus")
                    root.alert(root.phase === "long" ? "Time for a long break" : "Time for a break", `Focus session done. ${root.phaseMinutes} minute ${root.phase === "long" ? "long " : ""}break${root.autoContinue ? " started" : ""}.`, "complete");
                else
                    root.alert("Back to focus", `Break over. ${root.phaseLabel}${root.autoContinue ? " started" : ""}.`, "complete");
            }
        }
    }

    // Critical (shows through Do Not Disturb) + a chime from the freedesktop
    // sound theme.
    function alert(summary, body, sound) {
        Notifier.send("Timer", summary, body, {
            icon: "alarm-symbolic",
            urgency: "critical"
        });
        Quickshell.execDetached(["sh", "-c", `for d in /run/current-system/sw/share /etc/profiles/per-user/$USER/share; do f="$d/sounds/freedesktop/stereo/$1.oga"; [ -e "$f" ] && exec pw-play "$f"; done`, "sh", sound]);
    }

    // ---- persistence ----
    readonly property string stateFile: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/nyx/timers.json`
    property bool restored: false

    function save() {
        if (!restored)
            return;
        store.setText(JSON.stringify({
            timerMinutes,
            timerEnd,
            timerLeft,
            swStart,
            swAccum,
            laps,
            focusMinutes,
            shortMinutes,
            longMinutes,
            roundsBeforeLong,
            autoContinue,
            phase,
            round,
            pomoEnd,
            pomoLeft
        }));
    }

    FileView {
        id: store
        path: root.stateFile
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                const s = JSON.parse(text());
                for (const k of ["timerMinutes", "timerEnd", "timerLeft", "swStart", "swAccum", "laps", "focusMinutes", "shortMinutes", "longMinutes", "roundsBeforeLong", "autoContinue", "phase", "round", "pomoEnd", "pomoLeft"])
                    if (s[k] !== undefined)
                        root[k] = s[k];
            } catch (e) {}
            root.now = Date.now();
            root.restored = true;
        }
        onLoadFailed: {
            Quickshell.execDetached(["mkdir", "-p", root.stateFile.replace(/\/[^/]*$/, "")]);
            root.restored = true;
        }
    }

    IpcHandler {
        target: "timers"

        function start(minutes: int): void {
            root.startTimer(minutes > 0 ? minutes : root.timerMinutes);
        }
        function pause(): void {
            root.pauseTimer();
        }
        function resume(): void {
            root.startTimer(0);
        }
        function reset(): void {
            root.resetTimer();
        }
        function status(): string {
            return `timer ${root.clock(root.timerRemaining)}${root.timerRunning ? " running" : root.timerPaused ? " paused" : ""} · pomodoro ${root.phaseLabel} ${root.clock(root.pomoRemaining)}${root.pomoRunning ? " running" : ""} · stopwatch ${root.clock(root.swElapsed)}${root.swRunning ? " running" : ""}`;
        }
    }
}
