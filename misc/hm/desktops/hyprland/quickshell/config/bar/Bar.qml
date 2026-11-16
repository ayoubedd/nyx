import QtQuick
import Quickshell
import qs.common
import qs.services

// One bar per monitor.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        Component.onCompleted: Ui.registerBar(bar)
        Component.onDestruction: Ui.unregisterBar(bar)

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Theme.barHeight
        color: Theme.background

        // Empty bar space closes whatever is open. Menus count the bar as
        // "inside" (so clicking another bar button switches menus), which
        // means a click on bare bar never closed them. Declared first, so
        // every widget sits on top and keeps its own clicks.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                Ui.closeAll();
                Notifs.centerOpen = false;
            }
        }

        Workspaces {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        // Clock + now-playing as one centered pill. The player part slides
        // open while something plays and the whole pill re-centers.
        Rectangle {
            anchors.centerIn: parent
            width: centerRow.implicitWidth
            height: 26
            radius: height / 2
            color: Media.show ? Theme.surface : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Row {
                id: centerRow
                anchors.verticalCenter: parent.verticalCenter

                Clock {
                    id: clock
                }

                BarMedia {
                    onOpenPlayer: clock.showPlayer()
                }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            // Left to right: speed, recording, keep-awake, privacy, tray apps
            // | system: battery, sound, network, bluetooth, notifications.
            NetSpeedWidget {}
            RecordingWidget {
                id: recording
            }
            CaffeineWidget {
                id: caffeine
            }
            PrivacyWidget {
                id: privacy
            }
            TrayWidget {
                id: tray
            }

            // Divider between app/status items and the system controls; only
            // while there are status items (tray, privacy, keep-awake,
            // recording) to set apart.
            Item {
                visible: tray.visible || privacy.visible || caffeine.visible || recording.visible
                implicitWidth: 13
                implicitHeight: 26

                Rectangle {
                    anchors.centerIn: parent
                    width: 1
                    height: 14
                    color: Theme.muted
                }
            }

            BatteryWidget {} // battery + power profile menu
            SoundWidget {} // volume + output/input/app sound menu
            NetworkWidget {}
            BluetoothWidget {}
            // Rightmost: notification center (also holds the power actions).
            NotificationsWidget {}
        }
    }
}
