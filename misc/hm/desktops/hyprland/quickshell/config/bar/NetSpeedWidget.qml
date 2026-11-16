import QtQuick
import Quickshell
import qs.common
import qs.services
import qs.components

// Two-line down/up speed readout next to the network icon:
//   ↓ 1.2 M
//   ↑  40 K
// Fixed width, so changing numbers don't shift the rest of the bar.
// Display only: hovering shows the exact speeds, clicking does nothing.
MouseArea {
    id: root

    implicitWidth: Math.ceil(metrics.advanceWidth) + 22
    implicitHeight: 26
    hoverEnabled: true
    acceptedButtons: Qt.NoButton

    // Widest value it can show ("999 K"), at the readout's font.
    TextMetrics {
        id: metrics
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 4
        font.features: {
            "tnum": 1
        }
        text: "999 K"
    }

    Column {
        anchors.centerIn: parent
        spacing: -2

        Repeater {
            model: [
                {
                    icon: "arrow_downward",
                    value: NetSpeed.down
                },
                {
                    icon: "arrow_upward",
                    value: NetSpeed.up
                }
            ]

            Row {
                required property var modelData
                readonly property bool busy: modelData.value >= 100 * 1024
                spacing: 2

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: parent.modelData.icon
                    size: 10
                    color: parent.busy ? Theme.foreground : Theme.foregroundDim
                }

                Text {
                    width: Math.ceil(metrics.advanceWidth)
                    horizontalAlignment: Text.AlignRight
                    text: NetSpeed.short(parent.modelData.value)
                    font: metrics.font
                    color: parent.busy ? Theme.foreground : Theme.foregroundDim
                }
            }
        }
    }

    Tooltip {
        target: root
        text: `Download ${NetSpeed.long(NetSpeed.down)}  ·  Upload ${NetSpeed.long(NetSpeed.up)}`
        show: root.containsMouse
    }
}
