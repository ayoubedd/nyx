import QtQuick
import qs.common

// Pill slider with the icon sitting inside the fill (macOS style).
Item {
    id: root

    property real value: 0 // 0..1
    property string icon
    signal moved(real value)

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    // No width binding of its own: the parent decides (a Column sets
    // `width: parent.width`, a RowLayout uses Layout.fillWidth). Binding
    // width here fought RowLayouts and made the slider overflow until the
    // next relayout.
    implicitWidth: 120
    implicitHeight: 26

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.surfaceHigh

        Rectangle {
            width: Math.max(parent.height, root.value * parent.width)
            height: parent.height
            radius: height / 2
            color: Theme.foreground

            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation {
                    duration: 100
                }
            }
        }

        Icon {
            x: 6
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            filled: true
            size: 15
            color: Theme.background
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.moved(root.clamp(mouse.x / width))
        onPositionChanged: mouse => {
            if (pressed)
                root.moved(root.clamp(mouse.x / width));
        }
    }

    WheelHandler {
        onWheel: event => root.moved(root.clamp(root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05)))
    }
}
