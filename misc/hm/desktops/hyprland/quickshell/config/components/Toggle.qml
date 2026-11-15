import QtQuick
import qs.common

// On/off switch (iOS style). Emits toggled(); the owner flips `checked`.
MouseArea {
    id: root

    property bool checked: false
    signal toggled

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
            width: parent.height - 6
            height: width
            radius: width / 2
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
