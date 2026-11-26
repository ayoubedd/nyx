import QtQuick
import qs.common
import qs.services
import qs.components

// Coffee cup in the bar while "keep awake" is on. Click: its options in the
// notification center (CaffeineDetail.qml); middle-click: turn it off (the
// manual switch, and the automatic hold until its reason ends).
// While only the automatic mode holds it (call / fullscreen video), the cup
// is drawn outlined.
BarButton {
    visible: Caffeine.inhibiting
    icon: "coffee"
    filled: Caffeine.active
    iconColor: Theme.accent
    tooltip: Caffeine.active ? `Keep awake · ${Caffeine.remainingText}` : `Keep awake (automatic) · ${Caffeine.autoReason || "ending soon"}`
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) {
            Caffeine.disable();
            Caffeine.dismissAuto();
        } else
            Notifs.openCenterAt("caffeine");
    }
}
