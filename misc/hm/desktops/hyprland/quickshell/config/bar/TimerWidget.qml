import QtQuick
import qs.common
import qs.services
import qs.components

// Bar pill while a timer, Pomodoro or stopwatch is going (services/Timers.qml):
//   ⏱ 4:59
// Click: the dashboard's Timer tab (Bar.qml wires `openTab`). Middle-click:
// pause / resume.
MouseArea {
    id: root

    signal openTab

    readonly property var item: Timers.barItem
    readonly property color tint: item?.kind === "break" ? Theme.success : Theme.accent

    visible: !!item
    implicitWidth: row.implicitWidth + 18
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            Timers.toggleBarItem();
        else
            root.openTab();
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.containsMouse ? Theme.surfaceHigh : Theme.surface
        border.width: 1
        border.color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.5)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: {
                switch (root.item?.kind) {
                case "pomodoro":
                    return "schedule";
                case "break":
                    return "coffee";
                case "stopwatch":
                    return "timer";
                default:
                    return "hourglass_empty";
                }
            }
            filled: true
            size: 15
            color: root.tint
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.item?.text ?? ""
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            font.weight: Font.DemiBold
            font.features: {
                "tnum": 1
            }
            color: root.item?.paused ? Theme.foregroundDim : Theme.foreground
        }

        Icon {
            visible: root.item?.paused ?? false
            anchors.verticalCenter: parent.verticalCenter
            name: "pause"
            size: 14
            color: Theme.foregroundDim
        }
    }

    Tooltip {
        target: root
        text: {
            const k = root.item?.kind;
            const what = k === "pomodoro" || k === "break" ? Timers.phaseLabel : k === "stopwatch" ? "Stopwatch" : "Timer";
            return `${what}${root.item?.paused ? " (paused)" : ""} · click to open · middle-click to ${root.item?.paused ? "resume" : "pause"}`;
        }
        show: root.containsMouse
    }
}
