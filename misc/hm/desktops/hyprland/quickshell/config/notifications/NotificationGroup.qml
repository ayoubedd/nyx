import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// macOS-style stack of one app's notifications.
//   1 notification  -> plain card
//   collapsed       -> newest card with up to two cards peeking out below;
//                      click to expand, ✕ clears the group
//   expanded        -> header (app name, "Show less", clear) + every card
//
// Expanding/collapsing animates: the group's height eases, the two views
// cross-fade, and the cards fan out from (or fold back into) the stack.
//
// `popup: true` (NotificationPopups.qml): the stack is built from the
// on-screen popups only, times out as a whole (top card's timer), and ✕
// dismisses just those popups. A fanned-out popup stack doesn't time out.
Item {
    id: root

    required property var group
    property bool popup: false

    // Re-read by key: the model may hand us a stale object for a kept delegate.
    readonly property var live: (popup ? Notifs.popupGroups : Notifs.groups).find(g => g.key === group.key) ?? group
    readonly property var items: live.notifications
    readonly property bool stacked: items.length > 1
    readonly property bool expanded: stacked && (popup ? Notifs.isPopupExpanded(group.key) : Notifs.isExpanded(group.key))

    function setExpanded(on) {
        if (popup)
            Notifs.setPopupExpanded(group.key, on);
        else
            Notifs.setExpanded(group.key, on);
    }

    function clear() {
        if (popup)
            Notifs.dismissPopupGroup(group.key);
        else
            Notifs.clearGroup(group.key);
    }
    readonly property int peek: Math.min(items.length - 1, 2)

    readonly property int duration: 280
    readonly property int easing: Easing.OutCubic

    implicitHeight: expanded ? expandedView.implicitHeight : collapsedView.height

    Behavior on implicitHeight {
        NumberAnimation {
            id: heightAnim
            duration: Theme.ms(root.duration)
            easing.type: root.easing
        }
    }

    // While animating, clip so the fanning cards don't spill out, but to an
    // area reaching `bleed` px past the group on every side: the ✕ buttons
    // poke out of the cards' top-left corners and were being cut off.
    readonly property int bleed: 10

    Item {
        x: -root.bleed
        y: -root.bleed
        width: root.width + 2 * root.bleed
        height: root.height + 2 * root.bleed
        clip: heightAnim.running

        Item {
            id: content
            x: root.bleed
            y: root.bleed
            width: root.width
            height: root.height

            // ---- single / collapsed stack ----
            Item {
                id: collapsedView

                width: parent.width
                height: top.implicitHeight + root.peek * 7
                opacity: root.expanded ? 0 : 1
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.ms(root.duration * 0.6)
                    }
                }

                // Cards peeking out underneath, each a bit narrower and dimmer.
                // Clipped to the strip below the top card, since cards are translucent.
                // They follow the top card when it's swiped (the whole stack goes).
                Item {
                    x: top.swipe
                    opacity: 1 - Math.min(0.8, Math.abs(top.swipe) / Math.max(1, width))
                    y: top.implicitHeight
                    width: parent.width
                    height: root.peek * 7
                    clip: true

                    Repeater {
                        model: root.peek

                        Rectangle {
                            required property int index
                            readonly property int depth: index + 1

                            z: -depth
                            x: depth * 10
                            y: depth * 7 - 28
                            width: parent.width - depth * 20
                            height: 28
                            radius: 14
                            color: root.popup ? Theme.glass : Theme.glassTile
                            opacity: 1 - depth * 0.3
                            border.width: 1
                            border.color: Theme.glassBorder
                        }
                    }
                }

                NotificationCard {
                    id: top
                    width: parent.width
                    notification: root.items[0]
                    collapsedStack: root.stacked
                    popup: root.popup
                    // Popup stack: one timer for the whole stack, paused while open.
                    autoHide: root.popup && !root.expanded
                    popupGroup: root.popup ? root.group.key : ""
                    onStackClicked: root.setExpanded(true)
                    onStackClosed: root.clear()
                }
            }

            // ---- expanded: header + every card ----
            // Built for any stacked group (not just expanded ones) so collapsing can
            // animate out instead of the cards vanishing at once.
            Column {
                id: expandedView

                width: parent.width
                spacing: 8
                opacity: root.expanded ? 1 : 0
                visible: root.stacked && opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.ms(root.duration * 0.6)
                    }
                }

                RowLayout {
                    id: header
                    width: parent.width
                    height: 28

                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        text: root.live.appName
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 1
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    PillButton {
                        text: "Show less"
                        onClicked: root.setExpanded(false)
                    }

                    PillButton {
                        icon: "close"
                        onClicked: root.clear()
                    }
                }

                Repeater {
                    model: root.stacked ? root.items : []

                    NotificationCard {
                        id: card
                        required property var modelData
                        required property int index
                        notification: modelData
                        width: root.width
                        z: -index
                        // Popup look, but no own timeout: an open stack stays.
                        popup: root.popup
                        autoHide: false

                        // Fan out from (fold back into) the collapsed stack at the top.
                        transform: Translate {
                            y: root.expanded ? 0 : -card.y

                            Behavior on y {
                                NumberAnimation {
                                    duration: Theme.ms(root.duration)
                                    easing.type: root.easing
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
