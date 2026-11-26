import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// One half of the sound quick menu (output or input):
//   <device icon> Current device             ⌄   (click to choose another)
//   [mute] ━━━━━━━━━━━━━━━━━━  64%
// Everything else (balance, meters, boost, noise suppression) is in the
// notification center's Sound view.
Column {
    id: root
    property var node: null // current default sink / source
    property var devices: [] // choices (Audio.outputs / Audio.inputs)
    property bool isInput: false
    property bool expanded: false
    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real volume: node?.audio?.volume ?? 0

    width: parent ? parent.width : 0
    spacing: 4

    // Current device; click to pick another.
    MouseArea {
        id: picker
        width: parent.width
        implicitHeight: 28
        hoverEnabled: true
        cursorShape: root.devices.length > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.devices.length > 1
        onClicked: root.expanded = !root.expanded

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: 8
            color: picker.containsMouse || root.expanded ? Theme.surfaceHigh : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: root.node ? Audio.deviceName(root.node) : root.isInput ? "No microphone" : "No output device"
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Icon {
                visible: root.devices.length > 1
                name: root.expanded ? "expand_less" : "expand_more"
                size: 18
                color: Theme.foregroundDim
            }
        }
    }

    // Device list (expanded).
    Column {
        visible: root.expanded
        width: parent.width

        Repeater {
            model: root.devices

            MouseArea {
                id: option
                required property var modelData
                readonly property bool current: modelData === root.node

                width: parent.width
                implicitHeight: 30
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // With noise suppression on, a new mic means rebuilding
                    // the filter on it (the filter stays the default).
                    if (root.isInput && NoiseSuppression.enabled)
                        NoiseSuppression.setMic(modelData);
                    else
                        Audio.makeDefault(modelData);
                    root.expanded = false;
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: -6
                    anchors.rightMargin: -6
                    radius: 8
                    color: option.containsMouse ? Theme.surfaceHigh : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    Icon {
                        name: Audio.deviceIcon(option.modelData)
                        size: 16
                        color: option.current ? Theme.accent : Theme.foregroundDim
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Audio.deviceName(option.modelData)
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: option.current ? Font.DemiBold : Font.Normal
                        color: option.current ? Theme.foreground : Theme.foregroundDim
                    }
                }
            }
        }
    }

    // Volume: mute toggle (its icon says output / mic), slider, percentage.
    RowLayout {
        width: parent.width
        spacing: 10
        enabled: !!root.node
        opacity: enabled ? 1 : 0.4

        MouseArea {
            id: muteButton
            implicitWidth: 30
            implicitHeight: 30
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.toggleMute(root.node)

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.muted ? Theme.urgent : muteButton.containsMouse ? Theme.muted : Theme.surfaceHigh

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }
            }

            Icon {
                anchors.centerIn: parent
                name: root.isInput ? (root.muted ? "mic_off" : "mic") : Audio.volumeIcon(root.volume, root.muted)
                size: 17
                color: root.muted ? Theme.background : Theme.foreground
            }
        }

        Slider {
            Layout.fillWidth: true
            Layout.minimumWidth: 60
            value: root.muted ? 0 : root.volume
            onMoved: v => Audio.setVolume(root.node, v)
        }

        // Fixed width (fits "100%"), so the slider doesn't jump.
        TextMetrics {
            id: labelMetrics
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            font.weight: Font.DemiBold
            text: "100%"
        }

        Text {
            Layout.preferredWidth: Math.ceil(labelMetrics.advanceWidth) + 2
            horizontalAlignment: Text.AlignRight
            text: `${Math.round(root.volume * 100)}%`
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            font.weight: Font.DemiBold
            color: root.muted ? Theme.foregroundDim : Theme.foreground
        }
    }
}
