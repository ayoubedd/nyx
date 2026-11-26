import QtQuick
import QtQuick.Layouts
import qs.common

// "From   [−]  22:00  [+]" — a time of day in 30-minute steps (wraps around
// midnight). `minutes` = minutes after midnight; emits changed(minutes).
// Used by the notification center's detail views (DND, night light).
RowLayout {
    id: root

    property string label
    property int minutes
    property int step: 30
    signal changed(int minutes)

    function clockText(m) {
        return `${String(Math.floor(m / 60)).padStart(2, "0")}:${String(m % 60).padStart(2, "0")}`;
    }

    function move(delta) {
        root.changed((root.minutes + delta + 1440) % 1440);
    }

    width: parent ? parent.width : 0
    spacing: 8

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 30
        text: root.label
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 1
        color: Theme.foregroundDim
    }

    StepButton {
        icon: "remove"
        onClicked: root.move(-root.step)
    }

    Text {
        Layout.preferredWidth: 52
        horizontalAlignment: Text.AlignHCenter
        text: root.clockText(root.minutes)
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        font.weight: Font.DemiBold
        font.features: {
            "tnum": 1
        }
        color: Theme.foreground
    }

    StepButton {
        icon: "add"
        onClicked: root.move(root.step)
    }

    component StepButton: MouseArea {
        id: sb

        property string icon

        implicitWidth: 28
        implicitHeight: 28
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: sb.containsMouse ? Theme.glassTileHover : Theme.glassTile
            border.width: 1
            border.color: Theme.glassBorder
        }

        Icon {
            anchors.centerIn: parent
            name: sb.icon
            size: 16
        }
    }
}
