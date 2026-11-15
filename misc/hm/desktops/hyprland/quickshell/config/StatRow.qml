import QtQuick
import QtQuick.Layouts

// Tile with icon, label, value and a usage bar (turns red past `warnAt`).
Rectangle {
    id: root

    property string icon
    property string label
    property string value
    property real fraction: 0
    property real warnAt: 0.85

    readonly property real clamped: Math.max(0, Math.min(1, fraction))

    Layout.fillWidth: true
    implicitHeight: 58
    radius: Theme.radius
    color: Theme.surface

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Icon {
            name: root.icon
            size: 22
            color: Theme.foregroundDim
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.label
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.foreground
                }

                Text {
                    text: root.value
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 6
                radius: 3
                color: Theme.surfaceHigh

                Rectangle {
                    width: parent.width * root.clamped
                    height: parent.height
                    radius: 3
                    color: root.clamped >= root.warnAt ? Theme.urgent : Theme.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
