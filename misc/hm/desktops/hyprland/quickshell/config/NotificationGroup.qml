import QtQuick
import QtQuick.Layouts

// macOS-style stack of one app's notifications.
//   1 notification  -> plain card
//   collapsed       -> newest card with up to two cards peeking out below;
//                      click to expand, ✕ clears the group
//   expanded        -> header (app name, "Show less", clear) + every card
//
// Expanding/collapsing animates: the group's height eases, the two views
// cross-fade, and the cards fan out from (or fold back into) the stack.
Item {
    id: root

    required property var group

    // Re-read by key: the model may hand us a stale object for a kept delegate.
    readonly property var live: Notifs.groups.find(g => g.key === group.key) ?? group
    readonly property var items: live.notifications
    readonly property bool stacked: items.length > 1
    readonly property bool expanded: stacked && Notifs.isExpanded(group.key)
    readonly property int peek: Math.min(items.length - 1, 2)

    readonly property int duration: 280
    readonly property int easing: Easing.OutCubic

    implicitHeight: expanded ? expandedView.implicitHeight : collapsedView.height
    // Clip only while animating so the ✕ buttons poking out aren't cut off.
    clip: heightAnim.running

    Behavior on implicitHeight {
        NumberAnimation {
            id: heightAnim
            duration: root.duration
            easing.type: root.easing
        }
    }

    // ---- single / collapsed stack ----
    Item {
        id: collapsedView

        width: parent.width
        height: top.implicitHeight + root.peek * 7
        opacity: root.expanded ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.duration * 0.6
            }
        }

        // Cards peeking out underneath, each a bit narrower and dimmer.
        // Clipped to the strip below the top card, since cards are translucent.
        Item {
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
                    color: Theme.glassTile
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
            onStackClicked: Notifs.setExpanded(root.group.key, true)
            onStackClosed: Notifs.clearGroup(root.group.key)
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
                duration: root.duration * 0.6
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
                onClicked: Notifs.setExpanded(root.group.key, false)
            }

            PillButton {
                icon: "close"
                onClicked: Notifs.clearGroup(root.group.key)
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

                // Fan out from (fold back into) the collapsed stack at the top.
                transform: Translate {
                    y: root.expanded ? 0 : -card.y

                    Behavior on y {
                        NumberAnimation {
                            duration: root.duration
                            easing.type: root.easing
                        }
                    }
                }
            }
        }
    }
}
