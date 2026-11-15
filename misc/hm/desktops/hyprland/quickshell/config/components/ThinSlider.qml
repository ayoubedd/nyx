import QtQuick
import qs.common

// Slim slider: 4px track, fill, and a knob that shows on hover/drag.
// Wheel adjusts by 5%.
Item {
    id: root

    property real value: 0 // 0..1
    property bool muted: false
    signal moved(real value)

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    implicitHeight: 16

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Theme.surfaceHigh

        Rectangle {
            width: parent.width * root.value
            height: parent.height
            radius: 2
            color: root.muted ? Theme.muted : Theme.foreground

            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation {
                    duration: 100
                }
            }
        }
    }

    Rectangle {
        visible: drag.containsMouse || drag.pressed
        anchors.verticalCenter: parent.verticalCenter
        x: (parent.width - width) * root.value
        width: 12
        height: 12
        radius: 6
        color: Theme.foreground
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        hoverEnabled: true
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
