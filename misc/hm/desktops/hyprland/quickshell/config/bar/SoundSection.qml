import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// One card of the sound menu (Output or Input):
//   title
//   [mute] ━━━━━━━━━━━━━━━━━━  64%
//   <device icon> Current device             ⌄   (click to choose another)
//     ✓ Speakers
//       Ayoub's Buds Core
Rectangle {
    id: root

    property string title
    property var node: null // current default sink / source
    property var devices: [] // choices (Audio.outputs / Audio.inputs)
    property bool isInput: false
    property bool expanded: false

    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real volume: node?.audio?.volume ?? 0

    width: parent ? parent.width : 0
    implicitHeight: content.implicitHeight + 24
    radius: 14
    color: Theme.surface

    Column {
        id: content
        x: 12
        y: 12
        width: parent.width - 24
        spacing: 10

        Text {
            text: root.title
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            color: Theme.foreground
        }

        // Volume: mute toggle, slider, percentage.
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
                    filled: true
                    size: 17
                    color: root.muted ? Theme.background : Theme.foreground
                }
            }

            Slider {
                // Fills the space between the mute button and the label.
                Layout.fillWidth: true
                Layout.minimumWidth: 60
                value: root.muted ? 0 : root.volume
                onMoved: v => Audio.setVolume(root.node, v)
            }

            // Wide enough for the widest label it can show ("Muted" is wider
            // than "100%"), so the text can't spill past the card.
            TextMetrics {
                id: labelMetrics
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.weight: Font.DemiBold
                text: "Muted"
            }

            Text {
                Layout.preferredWidth: Math.ceil(labelMetrics.advanceWidth) + 2
                horizontalAlignment: Text.AlignRight
                text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%`
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                font.weight: Font.DemiBold
                color: root.muted ? Theme.foregroundDim : Theme.foreground
            }
        }

        // Current device; click to pick another.
        MouseArea {
            id: picker
            visible: root.devices.length > 0
            width: parent.width
            implicitHeight: 30
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

                Icon {
                    name: root.node ? Audio.deviceIcon(root.node) : (root.isInput ? "mic" : "speaker")
                    size: 16
                    color: Theme.foregroundDim
                }

                Text {
                    Layout.fillWidth: true
                    text: root.node ? Audio.deviceName(root.node) : "No device"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.foregroundDim
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
            spacing: 0

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
                            name: "check"
                            size: 16
                            color: Theme.accent
                            opacity: option.current ? 1 : 0
                        }

                        Icon {
                            name: Audio.deviceIcon(option.modelData)
                            size: 16
                            color: option.current ? Theme.foreground : Theme.foregroundDim
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Audio.deviceName(option.modelData)
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: option.current ? Font.DemiBold : Font.Normal
                            color: Theme.foreground
                        }
                    }
                }
            }
        }
    }
}
