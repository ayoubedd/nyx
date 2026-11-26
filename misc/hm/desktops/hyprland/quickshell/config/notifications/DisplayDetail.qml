import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.services
import qs.components

// Display detail view of the notification center: per connected monitor,
// its scale and resolution / refresh rate.
//
// Changes apply right away (a runtime Hyprland monitor rule) and must be
// confirmed: a bar counts down 15 s and reverts on its own unless you press
// Keep, so a mode the screen can't show fixes itself. Kept changes last
// until the next login / config reload / kanshi profile switch; the
// permanent setup stays in hypr/monitor.lua and kanshi.
ColumnLayout {
    id: root

    spacing: 12

    property var monitors: [] // from `hyprctl monitors -j`
    property string expandedModes: "" // monitor whose resolution list is open

    // Waiting for "Keep": what to go back to.
    property var revert: null // { name, mode, scale, position }
    property int countdown: 0

    readonly property var scales: [1, 1.25, 1.5, 1.75, 2]

    function load() {
        reader.running = true;
    }

    function modeOf(m) {
        return `${m.width}x${m.height}@${m.refreshRate.toFixed(2)}`;
    }

    function rule(name, mode, scale, position) {
        Quickshell.execDetached(["hyprctl", "eval", `hl.monitor({ output = "${name}", mode = "${mode}", position = "${position}", scale = ${scale} })`]);
    }

    function change(m, mode, scale) {
        // Keep the first "before" while changes are chained.
        if (!revert)
            revert = {
                name: m.name,
                mode: modeOf(m),
                scale: m.scale,
                position: `${m.x}x${m.y}`
            };
        rule(m.name, mode, scale, `${m.x}x${m.y}`);
        countdown = 15;
        tick.restart();
        reloadSoon.restart();
    }

    function keep() {
        revert = null;
        tick.stop();
    }

    function undo() {
        if (revert)
            rule(revert.name, revert.mode, revert.scale, revert.position);
        revert = null;
        tick.stop();
        reloadSoon.restart();
    }

    // Leaving the view while unconfirmed reverts too.
    Connections {
        target: Notifs
        function onCenterDetailChanged() {
            if (Notifs.centerDetail === "display")
                root.load();
            else if (root.revert)
                root.undo();
        }
    }

    Component.onCompleted: load()

    Timer {
        id: tick
        interval: 1000
        repeat: true
        onTriggered: {
            root.countdown--;
            if (root.countdown <= 0)
                root.undo();
        }
    }

    Timer {
        id: reloadSoon
        interval: 700
        onTriggered: root.load()
    }

    Process {
        id: reader
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(text).filter(m => !m.disabled);
                } catch (e) {}
            }
        }
    }

    // ---- confirmation ----
    Tile {
        visible: !!root.revert
        Layout.fillWidth: true
        spacing: 10

        RowLayout {
            width: parent.width
            spacing: 10

            Icon {
                name: "help"
                filled: true
                size: 20
                color: Theme.accent
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: "Keep these display settings?"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    text: `Reverting in ${root.countdown} s`
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            PillButton {
                text: "Revert"
                onClicked: root.undo()
            }

            PillButton {
                text: "Keep"
                onClicked: root.keep()
            }
        }
    }

    // ---- one tile per monitor ----
    Repeater {
        model: root.monitors

        Tile {
            id: mon
            required property var modelData
            readonly property var m: modelData
            readonly property var modes: {
                // "2560x1440@59.95Hz" -> unique, highest resolution first.
                const seen = new Set();
                return m.availableModes.map(s => s.replace(/Hz$/, "")).filter(s => !seen.has(s) && seen.add(s)).map(s => {
                    const [res, hz] = s.split("@");
                    const [w, h] = res.split("x").map(Number);
                    return {
                        mode: s,
                        w: w,
                        h: h,
                        hz: Number(hz)
                    };
                }).sort((a, b) => (b.w * b.h - a.w * a.h) || (b.hz - a.hz));
            }

            Layout.fillWidth: true
            spacing: 10

            // Header: name + current mode.
            RowLayout {
                width: parent.width
                spacing: 10

                Icon {
                    name: mon.m.name.startsWith("eDP") ? "laptop" : "desktop_windows"
                    size: 22
                    color: Theme.foreground
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: mon.m.description || mon.m.name
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Text {
                        Layout.fillWidth: true
                        text: `${mon.m.name} · ${mon.m.width}×${mon.m.height} · ${mon.m.refreshRate.toFixed(2)} Hz · scale ${mon.m.scale}`
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }
                }
            }

            // Scale chips.
            Text {
                text: "Scale"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            Row {
                spacing: 6

                Repeater {
                    model: root.scales

                    MouseArea {
                        id: chip
                        required property real modelData
                        readonly property bool active: Math.abs(mon.m.scale - modelData) < 0.01

                        width: chipText.implicitWidth + 20
                        height: 28
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (!active)
                            root.change(mon.m, root.modeOf(mon.m), modelData)

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: chip.active ? Theme.accent : chip.containsMouse ? Theme.glassTileHover : Theme.glassTile
                            border.width: chip.active ? 0 : 1
                            border.color: Theme.glassBorder
                        }

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: `${chip.modelData}×`
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            font.weight: chip.active ? Font.DemiBold : Font.Normal
                            color: chip.active ? Theme.background : Theme.foreground
                        }
                    }
                }
            }

            // Resolution / refresh rate (expandable list).
            MouseArea {
                id: resHeader
                width: parent.width
                implicitHeight: 32
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expandedModes = root.expandedModes === mon.m.name ? "" : mon.m.name

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: -6
                    anchors.rightMargin: -6
                    radius: 8
                    color: resHeader.containsMouse ? Theme.glassTileHover : "transparent"
                }

                RowLayout {
                    anchors.fill: parent

                    Text {
                        Layout.fillWidth: true
                        text: "Resolution & refresh rate"
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    Text {
                        text: `${mon.m.width}×${mon.m.height} @ ${Math.round(mon.m.refreshRate)} Hz`
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foreground
                    }

                    Icon {
                        name: root.expandedModes === mon.m.name ? "expand_less" : "expand_more"
                        size: 18
                        color: Theme.foregroundDim
                    }
                }
            }

            ListView {
                visible: root.expandedModes === mon.m.name
                width: parent.width
                height: Math.min(contentHeight, 6 * 30)
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: mon.modes

                delegate: MouseArea {
                    id: modeRow
                    required property var modelData
                    readonly property bool current: modelData.w === mon.m.width && modelData.h === mon.m.height && Math.abs(modelData.hz - mon.m.refreshRate) < 0.05

                    width: ListView.view.width
                    height: 30
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (!current)
                        root.change(mon.m, modelData.mode, mon.m.scale)

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: modeRow.containsMouse ? Theme.glassTileHover : "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Text {
                            Layout.fillWidth: true
                            text: `${modeRow.modelData.w} × ${modeRow.modelData.h}`
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: modeRow.current ? Font.DemiBold : Font.Normal
                            color: Theme.foreground
                        }

                        Text {
                            text: `${modeRow.modelData.hz.toFixed(2)} Hz`
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.foregroundDim
                        }

                        Icon {
                            visible: modeRow.current
                            name: "check"
                            size: 16
                            color: Theme.accent
                        }
                    }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        wrapMode: Text.WordWrap
        text: "Changes revert after 15 s unless you keep them. Kept changes last until you log out or a display profile switches; your permanent setup stays in the Hyprland/kanshi config."
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foregroundDim
    }
}
