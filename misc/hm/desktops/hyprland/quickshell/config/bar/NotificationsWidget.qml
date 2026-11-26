import QtQuick
import qs.common
import qs.services
import qs.components

// Left click: toggle the control/notification center. Right click: do-not-disturb.
BarButton {
    icon: Notifs.dnd ? "notifications_off" : "notifications"
    iconColor: Notifs.dnd ? Theme.foregroundDim : Theme.foreground
    badge: Notifs.count > 0 && !Notifs.dnd
    active: Notifs.centerOpen
    tooltip: (Notifs.count === 0 ? "No notifications" : Notifs.count === 1 ? "1 notification" : `${Notifs.count} notifications`) + (Notifs.dnd ? ` · Do Not Disturb${Notifs.dndManual ? "" : ` (${Notifs.dndReason.toLowerCase()})`}` : "")

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            Notifs.toggleDnd();
        else
            Notifs.toggleCenter();
    }
}
