import QtQuick
import Quickshell
import qs.common
import qs.services

// Hover tooltip for bar items: a small card centered under `target`.
// Shows after a short delay while `show` is true; never while a dropdown or
// the control center is open.
//
//   Tooltip { target: someItem; text: "Wi-Fi: Home · 87%"; show: mouse.containsMouse }
PopupWindow {
    id: root

    required property Item target
    property string text
    property bool show: false
    property bool armed: false

    onShowChanged: {
        if (show) {
            delay.restart();
        } else {
            delay.stop();
            armed = false;
        }
    }

    Timer {
        id: delay
        interval: 500
        onTriggered: root.armed = true
    }

    visible: armed && text !== "" && !Ui.active && !Notifs.centerOpen

    anchor.item: target
    anchor.rect.x: target.width / 2 - implicitWidth / 2
    anchor.rect.y: target.height + (Theme.barHeight - target.height) / 2 + 6
    color: "transparent"
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 12

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.background
        border.width: 1
        border.color: Theme.surfaceHigh

        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foreground
        }
    }
}
