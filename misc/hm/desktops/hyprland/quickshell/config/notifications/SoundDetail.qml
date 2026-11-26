import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.common
import qs.services
import qs.components
import qs.bar

// Sound detail view of the notification center (fuller than the bar's
// sound menu): every output with the default's volume, balance and a live
// level meter; over-100% volume; the input with a live mic meter and noise
// suppression; per-app volumes.
ColumnLayout {
    id: root

    spacing: 12

    readonly property var sink: Audio.sink
    readonly property var mic: NoiseSuppression.active ? NoiseSuppression.micNode : Audio.source

    // ---- output ----
    Text {
        Layout.leftMargin: 4
        text: "Output"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: Audio.outputs

            DeviceRow {
                required property var modelData
                node: modelData
                selected: modelData === root.sink
                onClicked: Audio.makeDefault(modelData)
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        LevelRow {
            label: "Volume"
            node: root.sink
            max: Audio.maxVolume
        }

        // Balance (stereo devices).
        RowLayout {
            visible: (root.sink?.audio?.volumes ?? []).length === 2
            width: parent.width
            spacing: 10

            Text {
                Layout.preferredWidth: 58
                text: "Balance"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            Text {
                text: "L"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            ThinSlider {
                Layout.fillWidth: true
                value: (Audio.balanceOf(root.sink) + 1) / 2
                onMoved: v => {
                    // Snap to the middle near center.
                    const b = v * 2 - 1;
                    Audio.setBalance(root.sink, Math.abs(b) < 0.06 ? 0 : b);
                }
            }

            Text {
                text: "R"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }
        }

        Meter {
            node: root.sink
            label: "Playing"
        }

        SwitchRow {
            icon: "volume_up"
            label: "Allow volume above 100%"
            detail: Audio.allowBoost ? "Up to 150% · may distort" : "For quiet speakers or recordings"
            checked: Audio.allowBoost
            onToggled: Audio.allowBoost = !Audio.allowBoost
        }
    }

    // ---- input ----
    Text {
        Layout.leftMargin: 4
        text: "Input"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: Audio.inputs

            DeviceRow {
                required property var modelData
                node: modelData
                selected: modelData === root.mic
                onClicked: NoiseSuppression.enabled ? NoiseSuppression.setMic(modelData) : Audio.makeDefault(modelData)
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        LevelRow {
            label: "Volume"
            node: root.mic
            max: 1
        }

        Meter {
            node: NoiseSuppression.active ? NoiseSuppression.filterNode : root.mic
            label: "Speak to test your mic"
        }

        SwitchRow {
            visible: NoiseSuppression.available
            icon: "graphic_eq"
            label: "Noise suppression"
            detail: NoiseSuppression.active ? "On · apps get the cleaned-up mic" : "Removes background noise for calls"
            checked: NoiseSuppression.enabled
            onToggled: NoiseSuppression.setEnabled(!NoiseSuppression.enabled)
        }
    }

    // ---- apps ----
    Text {
        visible: Audio.apps.length > 0
        Layout.leftMargin: 4
        text: "Apps"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        visible: Audio.apps.length > 0
        Layout.fillWidth: true
        spacing: 10

        Repeater {
            model: Audio.apps

            AppVolume {
                required property var modelData
                node: modelData
                width: parent.width
            }
        }
    }

    MouseArea {
        id: advanced
        Layout.fillWidth: true
        implicitHeight: 34
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Notifs.centerOpen = false;
            Quickshell.execDetached(["pavucontrol"]);
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: advanced.containsMouse ? Theme.glassTileHover : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            Icon {
                name: "tune"
                size: 16
                color: Theme.foregroundDim
            }

            Text {
                Layout.fillWidth: true
                text: "Advanced settings (pavucontrol)"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foreground
            }

            Icon {
                name: "open_in_new"
                size: 14
                color: Theme.foregroundDim
            }
        }
    }

    // ---- pieces ----

    // (icon)  Device name                         ✓
    component DeviceRow: MouseArea {
        id: dev

        property var node
        property bool selected: false

        width: parent ? parent.width : 0
        implicitHeight: 34
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: 8
            color: dev.containsMouse ? Theme.glassTileHover : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Icon {
                name: Audio.deviceIcon(dev.node)
                size: 17
                color: dev.selected ? Theme.accent : Theme.foregroundDim
            }

            Text {
                Layout.fillWidth: true
                text: Audio.deviceName(dev.node)
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: dev.selected ? Font.DemiBold : Font.Normal
                color: Theme.foreground
            }

            Icon {
                visible: dev.selected
                name: "check"
                size: 17
                color: Theme.accent
            }
        }
    }

    // Volume  [mute] ━━━━━━━━━  64%
    component LevelRow: RowLayout {
        id: lr

        property string label
        property var node
        property real max: 1
        readonly property bool muted: node?.audio?.muted ?? false
        readonly property real volume: node?.audio?.volume ?? 0

        width: parent ? parent.width : 0
        spacing: 10
        enabled: !!node
        opacity: enabled ? 1 : 0.4

        Text {
            Layout.preferredWidth: 58
            text: lr.label
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        MouseArea {
            id: muteBtn
            implicitWidth: 26
            implicitHeight: 26
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.toggleMute(lr.node)

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: lr.muted ? Theme.urgent : muteBtn.containsMouse ? Theme.glassTileHover : "transparent"
            }

            Icon {
                anchors.centerIn: parent
                name: lr.muted ? "volume_off" : "volume_up"
                size: 15
                color: lr.muted ? Theme.background : Theme.foreground
            }
        }

        ThinSlider {
            Layout.fillWidth: true
            value: lr.muted ? 0 : lr.volume / lr.max
            muted: lr.muted
            onMoved: v => Audio.setVolume(lr.node, v * lr.max)
        }

        Text {
            Layout.preferredWidth: 40
            horizontalAlignment: Text.AlignRight
            text: lr.muted ? "Muted" : `${Math.round(lr.volume * 100)}%`
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            font.weight: Font.DemiBold
            font.features: {
                "tnum": 1
            }
            color: lr.volume > 1 ? Theme.urgent : Theme.foreground
        }
    }

    // Live level meter (PipeWire peak monitor; only runs while shown).
    component Meter: RowLayout {
        id: meter

        property var node
        property string label

        width: parent ? parent.width : 0
        spacing: 10

        PwNodePeakMonitor {
            id: peaks
            node: meter.node
            enabled: meter.visible && Notifs.centerOpen && !!meter.node
        }

        Text {
            Layout.preferredWidth: 58
            text: "Level"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: 3
            color: Theme.surfaceHigh

            Rectangle {
                width: parent.width * Math.min(1, peaks.peak)
                height: parent.height
                radius: 3
                color: peaks.peak > 0.9 ? Theme.urgent : Theme.success

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.ms(60)
                    }
                }
            }
        }

        Text {
            Layout.preferredWidth: 150
            text: meter.label
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: Theme.foregroundDim
        }
    }
}
