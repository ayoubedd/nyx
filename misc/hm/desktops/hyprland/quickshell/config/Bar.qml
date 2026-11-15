import QtQuick
import Quickshell

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

            TrayWidget {}
            PrivacyWidget {}
            CaffeineWidget {}
            BatteryWidget {
                onClicked: clock.showTab(2) // dashboard Power tab
            }
            SoundWidget {} // volume + output/input/app sound menu
            NetworkWidget {}
            BluetoothWidget {}
            // Rightmost: notification center (also holds the power actions).
            NotificationsWidget {}
        }
    }
}
