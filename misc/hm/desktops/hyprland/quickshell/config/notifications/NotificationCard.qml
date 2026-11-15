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

    onClicked: {
        if (collapsedStack) {
            stackClicked();
            return;
        }
        defaultAction?.invoke();
        if (!notification.resident)
            notification.dismiss();
    }

    HoverHandler {
        id: hover
    }

    // Popups slide in from the right.
    transform: Translate {
        id: shift
        x: root.popup ? root.width + 16 : 0
    }
    NumberAnimation {
        id: enter
        target: shift
        property: "x"
        to: 0
        duration: 260
        easing.type: Easing.OutCubic
    }
    Component.onCompleted: if (popup)
        enter.start()

    // Auto-hide popups (back into the center, not dismissed). Paused on hover.
    Timer {
        running: root.popup && !root.hovered && !root.critical
        interval: {
            const t = root.notification.expireTimeout;
            return t > 0 ? Math.min(t < 1000 ? t * 1000 : t, 30000) : 5000;
        }
        onTriggered: {
            if (root.notification.transient)
                root.notification.expire();
            else
                Notifs.hidePopup(root.notification);
        }
    }

    Rectangle {
        id: card
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

                    Text {
                        text: Notifs.timeAgo(root.notification)
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: root.notification.summary
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
            }
        }
    }

    // Close button, top-left on hover (like macOS).
    MouseArea {
        x: -6
        y: -6
        width: 22
        height: 22
        visible: root.hovered
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
