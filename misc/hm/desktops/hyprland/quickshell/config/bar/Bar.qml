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

        // Workspaces, then the keybind-mode pill while a submap is active.
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Workspaces {
                anchors.verticalCenter: parent.verticalCenter
            }

            SubmapWidget {
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Timer / Pomodoro / stopwatch pill, right next to the clock (it
        // doesn't shift the clock off center).
        TimerWidget {
            anchors.left: centerPill.right
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            onOpenTab: clock.showTab(2) // dashboard Timer tab
        }

        // Clock + now-playing as one centered pill. The player part slides
        // open while something plays and the whole pill re-centers.
        Rectangle {
            id: centerPill
            anchors.centerIn: parent
            width: centerRow.implicitWidth
            height: 26
            radius: height / 2
            color: Media.show ? Theme.surface : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Theme.ms(200)
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
            // Only under sustained CPU / memory load.
            LoadWidget {
                id: load
                onOpenSystem: clock.showTab(3) // dashboard System tab
            }
            RecordingWidget {
                id: recording
            }
            CaffeineWidget {
                id: caffeine
            }
            // Mounted USB drives / SD cards: eject.
            EjectWidget {
                id: eject
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
                visible: tray.visible || privacy.visible || caffeine.visible || recording.visible || load.visible || eject.visible
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
