import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Toast stack in the top-right corner of the focused monitor.
PanelWindow {
    id: root

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: Notifs.popups.length > 0 && !Notifs.centerOpen

    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 8
    }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nyx-notifications"
    color: "transparent"

    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight + 8)

    Column {
        id: column
        // Room for the close button that pokes out top-left.
        x: 8
        y: 8
        width: parent.width - 8
        spacing: 10

        Repeater {
            model: ScriptModel {
                values: Notifs.popups.slice(0, 4)
            }

            NotificationCard {
                required property var modelData
                notification: modelData
                width: column.width
                popup: true
            }
        }
    }
}
