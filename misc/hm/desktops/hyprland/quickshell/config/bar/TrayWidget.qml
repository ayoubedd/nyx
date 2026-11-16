import QtQuick
import Quickshell.Services.SystemTray
import qs.common

// System tray (StatusNotifierItem) icons. Collapses to nothing when no app
// has a tray icon. (The divider after it lives in Bar.qml, shared with the
// other status items.)
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
    }
}
