import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services
import qs.components
import qs.lock

// Power actions tile for the notification center.
// Log out / restart / shut down need a second click within 3s to confirm.
Tile {
    id: root

    property string armed: ""

    readonly property var actions: [
        {
            id: "lock",
            icon: "lock",
            label: "Lock",
            command: ["loginctl", "lock-session"],
            confirm: false
        },
        {
            id: "suspend",
            icon: "bedtime",
            label: "Sleep",
            command: ["systemctl", "suspend"],
            confirm: false
        },
        {
            id: "logout",
            icon: "logout",
            label: "Log Out",
            command: ["uwsm", "stop"],
            confirm: true
        },
        {
            id: "reboot",
            icon: "restart_alt",
            label: "Restart",
            command: ["systemctl", "reboot"],
            confirm: true
        },
        {
            id: "poweroff",
            icon: "power_settings_new",
            label: "Shut Down",
            command: ["systemctl", "poweroff"],
            confirm: true
        }
    ]

    function run(action) {
        if (action.confirm && armed !== action.id) {
            armed = action.id;
            disarm.restart();
            return;
        }
        armed = "";
        Notifs.centerOpen = false;
        Quickshell.execDetached(action.command);
    }

    Timer {
        id: disarm
        interval: 3000
        onTriggered: root.armed = ""
    }

    // Forget a half-confirmed action when the center closes.
    Connections {
        target: Notifs
        function onCenterOpenChanged() {
            root.armed = "";
        }
    }

    RowLayout {
        width: parent.width
        spacing: 4

        Repeater {
            model: root.actions

            MouseArea {
                id: button
                required property var modelData
                readonly property bool isArmed: root.armed === modelData.id

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 62
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.run(modelData)

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 36
                        height: 36
                        radius: 18
                        color: button.isArmed ? Theme.urgent : button.containsMouse ? Theme.muted : Theme.surfaceHigh

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animDuration
                            }
                        }

                        Icon {
                            anchors.centerIn: parent
                            name: button.modelData.icon
                            size: 18
                            color: button.isArmed ? Theme.background : Theme.foreground
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: button.isArmed ? "Confirm?" : button.modelData.label
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: button.isArmed ? Theme.urgent : Theme.foregroundDim
                    }
                }
            }
        }
    }
}
