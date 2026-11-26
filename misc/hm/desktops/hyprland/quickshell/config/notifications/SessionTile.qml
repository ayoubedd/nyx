import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.services
import qs.components

// Session row of the notification center (replaces the old five-button
// power row):
//
//   (O)  Orbit                      [lock] [sleep] [⏻]
//        Up 21h 14m
//
// Lock and Sleep act right away; ⏻ opens the Power detail view
// (PowerDetail.qml) with restart / shut down / log out and their
// confirmation.
Tile {
    id: root

    readonly property string user: Quickshell.env("USER") || "user"
    readonly property string displayName: user.charAt(0).toUpperCase() + user.slice(1)
    property real uptime: 0 // seconds

    function uptimeText(s) {
        const d = Math.floor(s / 86400);
        const h = Math.floor(s % 86400 / 3600);
        const m = Math.floor(s % 3600 / 60);
        return d > 0 ? `${d}d ${h}h` : h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    // Read when the center opens (in-process).
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        printErrors: false
        onLoaded: root.uptime = parseFloat(text())
    }

    Connections {
        target: Notifs
        function onCenterOpenChanged() {
            if (Notifs.centerOpen)
                uptimeFile.reload();
        }
    }

    RowLayout {
        width: parent.width
        spacing: 10

        // Initial in a circle (no avatar image needed).
        Rectangle {
            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: Theme.accent

            Text {
                anchors.centerIn: parent
                text: root.displayName.charAt(0)
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 3
                font.weight: Font.DemiBold
                color: Theme.background
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.displayName
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Text {
                Layout.fillWidth: true
                text: root.uptime > 0 ? `Up ${root.uptimeText(root.uptime)}` : ""
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 3
                color: Theme.foregroundDim
            }
        }

        SessionButton {
            icon: "lock"
            tip: "Lock"
            onClicked: {
                Notifs.centerOpen = false;
                Quickshell.execDetached(["loginctl", "lock-session"]);
            }
        }

        SessionButton {
            icon: "bedtime"
            tip: "Sleep"
            onClicked: {
                Notifs.centerOpen = false;
                Quickshell.execDetached(["systemctl", "suspend"]);
            }
        }

        SessionButton {
            icon: "power_settings_new"
            tip: "Restart, shut down, log out…"
            onClicked: Notifs.centerDetail = "power"
        }
    }

    component SessionButton: MouseArea {
        id: button

        property string icon
        property string tip

        implicitWidth: 36
        implicitHeight: 36
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: button.containsMouse ? Theme.muted : Theme.surfaceHigh

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animDuration
                }
            }
        }

        Icon {
            anchors.centerIn: parent
            name: button.icon
            size: 18
            color: Theme.foreground
        }

        Tooltip {
            target: button
            text: button.tip
            show: button.containsMouse
        }
    }
}
