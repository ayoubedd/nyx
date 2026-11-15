import QtQuick
import Quickshell
import qs.common
import qs.services
import qs.components
import qs.dashboard

// Bar clock. Click to open the dashboard.
MouseArea {
    id: root

    implicitWidth: row.implicitWidth + 20
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: dashboard.toggle()

    // Open the dashboard on a given tab (0 Home, 1 Calendar, 2 Power, 3 System).
    function showTab(index) {
        dashboard.current = index;
        if (!dashboard.shown)
            dashboard.toggle();
    }

    function showPlayer() {
        showTab(0);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        // Inside the shared pill (while media plays) hover needs a lighter shade.
        color: dashboard.shown || (root.containsMouse && Media.show) ? Theme.surfaceHigh : root.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "ddd d MMM")
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: Theme.foregroundDim
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
            color: Theme.foreground
        }
    }

    Dashboard {
        id: dashboard
        target: root
    }

    Tooltip {
        target: root
        text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")
        show: root.containsMouse && !root.pressed && !dashboard.shown
    }
}
