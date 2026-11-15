import QtQuick
import qs.common
import qs.services
import qs.components

// Coffee cup in the bar while "keep awake" is on. Click to turn it off.
BarButton {
    visible: Caffeine.active
    icon: "coffee"
    filled: true
    iconColor: Theme.accent
    tooltip: `Keep awake · ${Caffeine.remainingText} · click to turn off`
    onClicked: Caffeine.disable()
}
