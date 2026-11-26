import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Dashboard Timer tab (services/Timers.qml): countdown timer, stopwatch and
// Pomodoro. Left: a progress ring with the time and the main buttons.
// Right: the mode's options (presets, laps, Pomodoro durations).
ColumnLayout {
    id: root

    property bool active: false
    // Which view: opens on whatever is running.
    property string mode: Timers.pomoRunning || Timers.pomoPaused ? "pomodoro" : Timers.swRunning ? "stopwatch" : "timer"

    onActiveChanged: if (active)
        mode = Timers.pomoRunning || Timers.pomoPaused ? "pomodoro" : Timers.timerRunning || Timers.timerPaused ? "timer" : Timers.swRunning || Timers.swAccum > 0 ? "stopwatch" : mode

    readonly property var presets: [1, 5, 10, 15, 25, 45, 60]

    // Current view's numbers.
    readonly property real progress: {
        if (mode === "timer")
            return Timers.timerRunning || Timers.timerPaused ? 1 - Timers.timerRemaining / (Timers.timerMinutes * 60000) : 0;
        if (mode === "pomodoro")
            return Timers.pomoRunning || Timers.pomoPaused ? 1 - Timers.pomoRemaining / (Timers.phaseMinutes * 60000) : 0;
        return (Timers.swElapsed % 60000) / 60000; // one lap of the ring per minute
    }
    readonly property string timeText: mode === "timer" ? Timers.clock(Timers.timerRemaining) : mode === "pomodoro" ? Timers.clock(Timers.pomoRemaining) : Timers.clock(Timers.swElapsed)
    readonly property string subText: {
        if (mode === "timer")
            return Timers.timerRunning ? "Running" : Timers.timerPaused ? "Paused" : `${Timers.timerMinutes} min timer`;
        if (mode === "pomodoro")
            return `${Timers.phaseLabel}${Timers.pomoPaused ? " · paused" : ""}`;
        return Timers.swRunning ? "Running" : Timers.swAccum > 0 ? "Paused" : "Stopwatch";
    }
    readonly property bool running: mode === "timer" ? Timers.timerRunning : mode === "pomodoro" ? Timers.pomoRunning : Timers.swRunning
    readonly property color ringColor: mode === "pomodoro" && Timers.phase !== "focus" ? Theme.success : Theme.accent

    function primary() {
        if (mode === "timer")
            Timers.timerRunning ? Timers.pauseTimer() : Timers.startTimer(0);
        else if (mode === "pomodoro")
            Timers.pomoRunning ? Timers.pausePomodoro() : Timers.startPomodoro();
        else
            Timers.swRunning ? Timers.pauseStopwatch() : Timers.startStopwatch();
    }

    function reset() {
        if (mode === "timer")
            Timers.resetTimer();
        else if (mode === "pomodoro")
            Timers.resetPomodoro();
        else
            Timers.resetStopwatch();
    }

    spacing: 12

    // ---- mode switch ----
    Row {
        Layout.alignment: Qt.AlignHCenter
        spacing: 4

        Repeater {
            model: [
                {
                    id: "timer",
                    label: "Timer",
                    icon: "hourglass_empty"
                },
                {
                    id: "stopwatch",
                    label: "Stopwatch",
                    icon: "timer"
                },
                {
                    id: "pomodoro",
                    label: "Pomodoro",
                    icon: "schedule"
                }
            ]

            MouseArea {
                id: seg
                required property var modelData
                readonly property bool selected: root.mode === modelData.id

                width: segRow.implicitWidth + 24
                height: 30
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.mode = modelData.id

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: seg.selected ? Theme.surfaceHigh : seg.containsMouse ? Theme.surface : "transparent"
                }

                Row {
                    id: segRow
                    anchors.centerIn: parent
                    spacing: 6

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: seg.modelData.icon
                        filled: seg.selected
                        size: 16
                        color: seg.selected ? Theme.foreground : Theme.foregroundDim
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: seg.modelData.label
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: seg.selected ? Font.DemiBold : Font.Normal
                        color: seg.selected ? Theme.foreground : Theme.foregroundDim
                    }
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 16

        // ---- ring + controls ----
        ColumnLayout {
            Layout.preferredWidth: 230
            Layout.fillHeight: true
            spacing: 14

            Item {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 200
                implicitHeight: 200

                Canvas {
                    id: ring
                    anchors.fill: parent
                    readonly property real p: Math.max(0, Math.min(1, root.progress))
                    onPChanged: requestPaint()
                    onVisibleChanged: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        const c = width / 2, r = width / 2 - 8;
                        ctx.lineWidth = 10;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = Theme.surfaceHigh;
                        ctx.beginPath();
                        ctx.arc(c, c, r, 0, 2 * Math.PI);
                        ctx.stroke();
                        if (p > 0) {
                            ctx.strokeStyle = root.ringColor;
                            ctx.beginPath();
                            ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + p * 2 * Math.PI);
                            ctx.stroke();
                        }
                    }

                    Connections {
                        target: root
                        function onRingColorChanged() {
                            ring.requestPaint();
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.timeText
                        font.family: Theme.font
                        font.pixelSize: 40
                        font.weight: Font.DemiBold
                        font.features: {
                            "tnum": 1
                        }
                        color: Theme.foreground
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.subText
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                // Reset / lap-skip are smaller than start: center them on its
                // middle (a Row aligns children at the top).
                RoundButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "restart_alt"
                    tip: "Reset"
                    onClicked: root.reset()
                }

                RoundButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: root.running ? "pause" : "play_arrow"
                    tip: root.running ? "Pause" : "Start"
                    big: true
                    onClicked: root.primary()
                }

                // Not used by the Timer mode, but it keeps its space (hidden
                // and unclickable rather than removed), so the start button
                // stays put when switching modes.
                RoundButton {
                    anchors.verticalCenter: parent.verticalCenter
                    readonly property bool used: root.mode !== "timer"
                    visible: true
                    opacity: used ? (enabled ? 1 : 0.4) : 0
                    icon: root.mode === "stopwatch" ? "flag" : "skip_next"
                    tip: root.mode === "stopwatch" ? "Lap" : "Skip to next phase"
                    enabled: used && (root.mode !== "stopwatch" || Timers.swRunning)
                    onClicked: root.mode === "stopwatch" ? Timers.lap() : Timers.nextPhase(Timers.pomoRunning)
                }
            }
        }

        // ---- options per mode ----
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radius
            color: Theme.surface

            // Timer: presets + minutes.
            ColumnLayout {
                visible: root.mode === "timer"
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                SectionLabel {
                    text: "Quick start"
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.presets

                        Chip {
                            required property int modelData
                            text: modelData < 60 ? `${modelData} min` : `${modelData / 60} h`
                            selected: Timers.timerMinutes === modelData && (Timers.timerRunning || Timers.timerPaused)
                            onClicked: Timers.startTimer(modelData)
                        }
                    }
                }

                SectionLabel {
                    Layout.topMargin: 6
                    text: "Custom"
                }

                MinutesRow {
                    label: "Minutes"
                    value: Timers.timerMinutes
                    min: 1
                    max: 600
                    enabled: !Timers.timerRunning && !Timers.timerPaused
                    onChanged: v => {
                        Timers.timerMinutes = v;
                        Timers.save();
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: "When time is up you get a notification (even with Do Not Disturb on) and a chime. Timers keep running if you close the dashboard."
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            // Stopwatch: laps.
            ColumnLayout {
                visible: root.mode === "stopwatch"
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                SectionLabel {
                    text: Timers.laps.length ? `Laps (${Timers.laps.length})` : "Laps"
                }

                Text {
                    visible: Timers.laps.length === 0
                    text: "Press ⚑ while it runs to record a lap."
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: Timers.laps

                    delegate: RowLayout {
                        required property real modelData
                        required property int index
                        width: ListView.view.width
                        height: 26

                        Text {
                            Layout.fillWidth: true
                            text: `Lap ${Timers.laps.length - index}`
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            color: Theme.foregroundDim
                        }

                        // Split time (since the previous lap).
                        Text {
                            text: `+${Timers.clock(modelData - (Timers.laps[index + 1] ?? 0))}`
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            font.features: {
                                "tnum": 1
                            }
                            color: Theme.foregroundDim
                        }

                        Text {
                            Layout.preferredWidth: 70
                            horizontalAlignment: Text.AlignRight
                            text: Timers.clock(modelData)
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: Font.DemiBold
                            font.features: {
                                "tnum": 1
                            }
                            color: Theme.foreground
                        }
                    }
                }
            }

            // Pomodoro: durations + auto-continue.
            ColumnLayout {
                visible: root.mode === "pomodoro"
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                SectionLabel {
                    text: "Durations"
                }

                MinutesRow {
                    label: "Focus"
                    value: Timers.focusMinutes
                    min: 5
                    max: 120
                    onChanged: v => {
                        Timers.focusMinutes = v;
                        Timers.save();
                    }
                }

                MinutesRow {
                    label: "Short break"
                    value: Timers.shortMinutes
                    min: 1
                    max: 30
                    onChanged: v => {
                        Timers.shortMinutes = v;
                        Timers.save();
                    }
                }

                MinutesRow {
                    label: "Long break"
                    value: Timers.longMinutes
                    min: 5
                    max: 60
                    onChanged: v => {
                        Timers.longMinutes = v;
                        Timers.save();
                    }
                }

                MinutesRow {
                    label: "Rounds before a long break"
                    value: Timers.roundsBeforeLong
                    unit: ""
                    min: 2
                    max: 8
                    step: 1
                    onChanged: v => {
                        Timers.roundsBeforeLong = v;
                        Timers.save();
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                SwitchRow {
                    Layout.fillWidth: true
                    icon: "autoplay"
                    label: "Start the next phase automatically"
                    detail: ""
                    checked: Timers.autoContinue
                    onToggled: {
                        Timers.autoContinue = !Timers.autoContinue;
                        Timers.save();
                    }
                }
            }
        }
    }

    // ---- small building blocks ----

    component RoundButton: MouseArea {
        id: rb

        property string icon
        property string tip
        property bool big: false

        width: big ? 56 : 42
        height: width
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        opacity: enabled ? 1 : 0.4

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: rb.big ? (rb.containsMouse ? Qt.lighter(root.ringColor, 1.1) : root.ringColor) : rb.containsMouse ? Theme.surfaceHigh : Theme.surface
        }

        Icon {
            anchors.centerIn: parent
            name: rb.icon
            filled: true
            size: rb.big ? 28 : 20
            color: rb.big ? Theme.background : Theme.foreground
        }

        Tooltip {
            target: rb
            text: rb.tip
            show: rb.containsMouse
        }
    }

    component Chip: MouseArea {
        id: chip

        property string text
        property bool selected: false

        width: chipText.implicitWidth + 22
        height: 30
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: chip.selected ? Theme.accent : chip.containsMouse ? Theme.surfaceHigh : Theme.background
        }

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: chip.selected ? Font.DemiBold : Font.Normal
            color: chip.selected ? Theme.background : Theme.foreground
        }
    }

    // "Focus      [−]  25 min  [+]"
    component MinutesRow: RowLayout {
        id: mr

        property string label
        property int value
        property string unit: "min"
        property int min: 1
        property int max: 120
        property int step: value >= 30 ? 5 : 1
        signal changed(int value)

        Layout.fillWidth: true
        spacing: 8
        opacity: enabled ? 1 : 0.5

        Text {
            Layout.fillWidth: true
            text: mr.label
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foreground
        }

        StepButton {
            icon: "remove"
            onClicked: mr.changed(Math.max(mr.min, mr.value - mr.step))
        }

        Text {
            Layout.preferredWidth: 56
            horizontalAlignment: Text.AlignHCenter
            text: mr.unit ? `${mr.value} ${mr.unit}` : String(mr.value)
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            font.features: {
                "tnum": 1
            }
            color: Theme.foreground
        }

        StepButton {
            icon: "add"
            onClicked: mr.changed(Math.min(mr.max, mr.value + mr.step))
        }
    }

    component StepButton: MouseArea {
        id: sb

        property string icon

        implicitWidth: 26
        implicitHeight: 26
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: sb.containsMouse ? Theme.surfaceHigh : Theme.background
        }

        Icon {
            anchors.centerIn: parent
            name: sb.icon
            size: 15
        }
    }
}
