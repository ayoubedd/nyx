import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services

// Popups in the top-right corner of the focused monitor, stacked per app
// like the notification center (NotificationGroup with popup: true): a
// second message from the same app lands on top of the first instead of
// adding another card. Click a stack to fan it out.
PanelWindow {
    id: root

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: Notifs.popups.length > 0 && !Notifs.centerOpen

    anchors {
        top: true
        right: true
    }
    // Gap below the bar / from the screen edge for the hover backdrop; the
    // padding (`pad`) inside adds the gap around the cards.
    margins {
        top: 8
        right: 8
    }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nyx-notifications"
    color: "transparent"

    // Fixed size; only the cards take input. Sizing the window to its content
    // resized the layer surface on every frame of the fan-out animation (and
    // Hyprland re-blurred it each time), which made expanding laggy. The
    // empty part is transparent and click-through (ignore_alpha skips its
    // blur too).
    implicitWidth: 400 + leftRoom
    implicitHeight: Math.round((screen?.height ?? 1080) * 0.85)
    mask: Region {
        item: inputArea
    }

    readonly property int pad: 14 // around the stacks (room for the ✕ buttons)    // Transparent, click-through strip on the left so a card nudged left
    // while swiping isn't cut by the window edge.
    readonly property int leftRoom: 28

    // A fanned-out stack collapses when you click anywhere else (like the
    // menus). The grab is only held while a stack is open.
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible && Notifs.popupExpanded.length > 0
        onCleared: Notifs.popupExpanded = []
    }

    // Backdrop while a stack is fanned out: frosted glass (blurred by
    // Hyprland) so the cards and the "Show less" / ✕ pills don't blend into
    // whatever is behind them. Fully transparent otherwise, so there's no
    // blur then either (ignore_alpha).
    readonly property bool focused: Notifs.popupExpanded.length > 0

    Rectangle {
        id: inputArea
        x: root.leftRoom
        width: parent.width - root.leftRoom
        height: column.implicitHeight + 2 * root.pad
        radius: 22
        color: Theme.glass
        border.width: 1
        border.color: Theme.glassBorder
        opacity: root.focused ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.ms(180)
            }
        }

    }

    Column {
        id: column
        x: root.leftRoom + root.pad
        y: root.pad
        width: parent.width - root.leftRoom - 2 * root.pad
        spacing: 10

        Repeater {
            model: ScriptModel {
                values: Notifs.popupGroups.slice(0, 4)
                objectProp: "key" // keep a stack's delegate when it changes
            }

            NotificationGroup {
                required property var modelData
                group: modelData
                popup: true
                width: column.width
            }
        }
    }
}
