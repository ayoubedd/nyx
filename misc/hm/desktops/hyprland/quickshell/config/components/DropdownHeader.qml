import QtQuick
import QtQuick.Layouts
import qs.common

// Title row with an optional on/off switch.
Item {
    id: root

    property string title
    property bool showToggle: true
    property bool checked: false
    signal toggled

    width: parent ? parent.width : 0
    implicitHeight: 40

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Text {
            Layout.fillWidth: true
            text: root.title
            font.family: Theme.font
            font.pixelSize: Theme.fontSize + 1
            font.weight: Font.DemiBold
            color: Theme.foreground
        }

        MouseArea {
            visible: root.showToggle
            implicitWidth: 36
            implicitHeight: 20
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: root.checked ? Theme.accent : Theme.surfaceHigh

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }

                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    y: 3
                    x: root.checked ? parent.width - width - 3 : 3
                    color: root.checked ? Theme.background : Theme.foregroundDim

                    Behavior on x {
                        NumberAnimation {
                            duration: Theme.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
