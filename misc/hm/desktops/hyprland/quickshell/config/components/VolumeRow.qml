import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

// Volume slider for a PipeWire node with a mute button on the right.
RowLayout {
    id: root

    required property var node
    property string icon: Audio.volumeIcon(node?.audio?.volume ?? 0, node?.audio?.muted ?? false)

    readonly property bool muted: node?.audio?.muted ?? false

    width: parent ? parent.width : 0
    spacing: 8

    Slider {
        Layout.fillWidth: true
        icon: root.icon
        value: root.muted ? 0 : (root.node?.audio?.volume ?? 0)
        onMoved: v => Audio.setVolume(root.node, v)
    }

    Text {
        Layout.preferredWidth: 34
        horizontalAlignment: Text.AlignRight
        text: root.muted ? "Off" : `${Math.round((root.node?.audio?.volume ?? 0) * 100)}%`
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        color: Theme.foregroundDim
    }

    PillButton {
        icon: root.muted ? "volume_off" : "volume_up"
        opacity: root.muted ? 1 : 0.7
        onClicked: Audio.toggleMute(root.node)
    }
}
