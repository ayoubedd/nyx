import QtQuick
import Quickshell.Services.SystemTray

// System tray (StatusNotifierItem) icons, with a divider after them.
// Collapses to nothing when no app has a tray icon.
Item {
    id: root

    readonly property var items: SystemTray.items.values

    implicitWidth: items.length > 0 ? row.implicitWidth : 0
    implicitHeight: 26
    clip: true
    visible: implicitWidth > 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Repeater {
            model: root.items

            TrayItem {
                required property var modelData
                item: modelData
            }
        }

        // Divider between the tray and the shell's own widgets.
        Item {
            width: 11
            height: 26

            Rectangle {
                anchors.centerIn: parent
                width: 1
                height: 14
                color: Theme.muted
            }
        }
    }
}
