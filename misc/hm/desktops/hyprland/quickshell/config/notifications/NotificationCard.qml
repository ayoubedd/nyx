import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.common
import qs.services

// macOS-style notification card, used both as a popup and in the center.
MouseArea {
    id: root

    required property var notification
    property bool popup: false
    // Popups time out (paused on hover). Off for the cards of a fanned-out
    // popup stack, which stays until collapsed/closed.
    property bool autoHide: popup
    // Set when this card is the top of a popup stack: timing out hides the
    // whole stack (Notifs.hidePopupGroup), not just this card.
    property string popupGroup: ""

    // Top card of a collapsed group: click expands, ✕ clears the whole group.
    property bool collapsedStack: false
    signal stackClicked
    signal stackClosed

    readonly property bool hovered: hover.hovered
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: notification.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notification.actions.filter(a => a.identifier !== "default")
    readonly property string iconSource: {
        const n = notification;
        if (n.image)
            return n.image;
        const i = n.appIcon;
        if (i)
            return i.startsWith("/") ? `file://${i}` : i.includes("://") ? i : Quickshell.iconPath(i, true);
        return n.desktopEntry ? Quickshell.iconPath(n.desktopEntry, true) : "";
    }

    implicitHeight: card.implicitHeight
    cursorShape: Qt.PointingHandCursor

    // Per-app options (⋯ on hover, or right-click): center only / mute.
    property bool optionsOpen: false
    readonly property string appName: notification.appName || notification.desktopEntry || "this app"
    readonly property string rule: Notifs.appRule(notification)

    function setRule(r) {
        Notifs.setAppRule(Notifs.appKey(notification), r, notification.appName || notification.desktopEntry);
        optionsOpen = false;
    }

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (!collapsedStack)
                optionsOpen = !optionsOpen;
            return;
        }
        if (optionsOpen) {
            optionsOpen = false;
            return;
        }
        if (collapsedStack) {
            stackClicked();
            return;
        }
        defaultAction?.invoke();
        // Bring the app's window forward (apps can't focus themselves here;
        // see Notifs.focusApp). Before dismissing, while the fields exist.
        Notifs.focusApp(notification);
        if (!notification.resident)
            notification.dismiss();
    }

    HoverHandler {
        id: hover
    }

    // ---- swipe right to dismiss -------------------------------------------
    // Drag the card to the right: past ~35% of its width (or a quick flick)
    // it slides away and is dismissed; a collapsed stack's top card dismisses
    // the whole stack. Less than that springs back. Dragging left only gives
    // a little resistance. The visuals (card + ✕) move, not this item: a
    // stack's fan-out animation owns this item's `transform`.
    property real swipe: 0
    readonly property bool swiping: swipeDrag.active || swipeOut.running || swipeBack.running

    DragHandler {
        id: swipeDrag
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        // Left: a little resistance, capped to the room the container has
        // (popups have a margin for it; the center's list clips sooner).
        onTranslationChanged: root.swipe = translation.x > 0 ? translation.x : Math.max(-(root.popup ? 24 : 6), translation.x * 0.2)
        onActiveChanged: {
            if (active)
                return;
            const flick = centroid.velocity.x > 900 && root.swipe > 24;
            if (root.swipe > root.width * 0.35 || flick)
                swipeOut.start();
            else
                swipeBack.start();
        }
    }

    NumberAnimation {
        id: swipeBack
        target: root
        property: "swipe"
        to: 0
        duration: Theme.ms(200)
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: swipeOut
        NumberAnimation {
            target: root
            property: "swipe"
            to: root.width + 40
            duration: Theme.ms(170)
            easing.type: Easing.InCubic
        }
        ScriptAction {
            script: {
                if (root.collapsedStack)
                    root.stackClosed();
                else
                    root.notification.dismiss();
            }
        }
    }

    // Popups slide in from the right. Once in, `entered` pins them at 0: the
    // animation writes x without removing the binding, so a later width
    // change re-evaluated it and pushed the card off-screen again. With
    // reduced motion (on battery) the 0 ms animation ended before the card
    // had its width, and every popup ended up invisible off to the right.
    property bool entered: !popup
    transform: Translate {
        id: shift
        x: root.entered ? 0 : root.width + 16
    }
    NumberAnimation {
        id: enter
        target: shift
        property: "x"
        to: 0
        duration: Theme.ms(260)
        easing.type: Easing.OutCubic
        onStopped: root.entered = true
    }
    Component.onCompleted: {
        if (Theme.reduceMotion)
            entered = true;
        else if (!entered)
            enter.start();
    }

    // Auto-hide popups (back into the center, not dismissed). Paused on hover.
    Timer {
        id: hideTimer
        running: root.autoHide && !root.hovered && !root.critical
        interval: {
            const t = root.notification.expireTimeout;
            return t > 0 ? Math.min(t < 1000 ? t * 1000 : t, 30000) : 5000;
        }
        onTriggered: {
            if (root.popupGroup)
                Notifs.hidePopupGroup(root.popupGroup);
            else if (root.notification.transient)
                root.notification.expire();
            else
                Notifs.hidePopup(root.notification);
        }
    }

    // Another notification in this card (a newer one landed on top of a
    // stack): start in place, and a popup gets its full time again.
    onNotificationChanged: {
        swipe = 0;
        if (autoHide)
            hideTimer.restart();
    }

    Rectangle {
        id: card
        x: root.swipe
        opacity: 1 - Math.min(0.8, Math.abs(root.swipe) / Math.max(1, root.width))
        width: parent.width
        implicitHeight: layout.implicitHeight + 24
        radius: 16
        // Popups sit directly on the desktop, so give them the darker glass.
        color: root.hovered ? Theme.glassTileHover : root.popup ? Theme.glass : Theme.glassTile
        border.width: 1
        border.color: root.critical ? Theme.urgent : Theme.glassBorder

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }

        RowLayout {
            id: layout
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 12

            // App icon / image
            ClippingRectangle {
                Layout.alignment: Qt.AlignTop
                implicitWidth: 36
                implicitHeight: 36
                radius: 9
                color: Theme.surfaceHigh

                IconImage {
                    id: image
                    anchors.fill: parent
                    source: root.iconSource
                    visible: status === Image.Ready
                }

                Icon {
                    anchors.centerIn: parent
                    visible: !image.visible
                    name: "notifications"
                    color: Theme.foregroundDim
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: root.notification.appName || "Notification"
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    // Time, swapped for ⋯ (per-app options; also right-click)
                    // on hover, in the same spot: nothing reserves extra
                    // space and nothing moves (macOS style).
                    Item {
                        readonly property bool showMore: (root.hovered || root.optionsOpen) && !root.collapsedStack

                        implicitWidth: Math.max(timeText.implicitWidth, moreButton.implicitWidth)
                        implicitHeight: Math.max(timeText.implicitHeight, moreButton.implicitHeight)

                        Text {
                            id: timeText
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Notifs.timeAgo(root.notification)
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.foregroundDim
                            opacity: parent.showMore ? 0 : 1

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.animDuration
                                }
                            }
                        }

                        MouseArea {
                            id: moreButton
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: 22
                            implicitHeight: 18
                            opacity: parent.showMore ? 1 : 0
                            enabled: parent.showMore
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.optionsOpen = !root.optionsOpen

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.animDuration
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: moreButton.containsMouse || root.optionsOpen ? Theme.surfaceHigh : "transparent"
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "more_horiz"
                                size: 16
                                color: Theme.foregroundDim
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    // "×3" when the app posted the same notification again.
                    text: root.notification.summary + (Notifs.repeatCount(root.notification) > 1 ? `  ×${Notifs.repeatCount(root.notification)}` : "")
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: root.notification.body
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: root.popup ? 3 : 5
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.foregroundDim
                    linkColor: Theme.accent
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                Flow {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    visible: root.buttons.length > 0 && !root.collapsedStack
                    spacing: 6

                    Repeater {
                        model: root.buttons

                        MouseArea {
                            required property var modelData
                            implicitWidth: label.implicitWidth + 20
                            implicitHeight: 26
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.invoke();
                                if (!root.notification.resident)
                                    root.notification.dismiss();
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: parent.containsMouse ? Theme.muted : Theme.surfaceHigh
                            }

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: modelData.text
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 1
                                color: Theme.foreground
                            }
                        }
                    }
                }

                // Per-app options (Notifs.appRules).
                ColumnLayout {
                    visible: root.optionsOpen
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: root.rule === "silent" ? `${root.appName}: center only (no popups)` : root.rule === "mute" ? `${root.appName}: muted` : `Notifications from ${root.appName}`
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        OptionButton {
                            visible: root.rule !== "silent"
                            icon: "notifications_paused"
                            text: "Center only"
                            onClicked: root.setRule("silent")
                        }

                        OptionButton {
                            visible: root.rule !== "mute"
                            icon: "notifications_off"
                            text: `Mute ${root.appName}`
                            danger: true
                            onClicked: root.setRule("mute")
                        }

                        OptionButton {
                            visible: root.rule !== ""
                            icon: "notifications_active"
                            text: "Allow popups again"
                            onClicked: root.setRule("")
                        }
                    }
                }
            }
        }
    }

    component OptionButton: MouseArea {
        id: opt

        property string icon
        property string text
        property bool danger: false

        implicitWidth: optRow.implicitWidth + 20
        implicitHeight: 26
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: opt.containsMouse ? (opt.danger ? Theme.urgent : Theme.muted) : Theme.surfaceHigh
        }

        Row {
            id: optRow
            anchors.centerIn: parent
            spacing: 5

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: opt.icon
                size: 14
                color: opt.danger && opt.containsMouse ? Theme.background : Theme.foreground
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: opt.text
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: opt.danger && opt.containsMouse ? Theme.background : Theme.foreground
            }
        }
    }

    // Close button, top-left on hover (like macOS).
    MouseArea {
        x: -6 + root.swipe
        y: -6
        width: 22
        height: 22
        visible: root.hovered && !root.swiping
        cursorShape: Qt.PointingHandCursor
        onClicked: root.collapsedStack ? root.stackClosed() : root.notification.dismiss()

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.surfaceHigh
            border.width: 1
            border.color: Theme.muted
        }

        Icon {
            anchors.centerIn: parent
            name: "close"
            size: 14
        }
    }
}
