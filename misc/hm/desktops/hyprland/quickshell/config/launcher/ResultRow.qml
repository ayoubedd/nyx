import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common

// One row of the launcher list: a section header, or a result
//   [icon]  Title  subtitle                        accessory
//
// item: { header, title, subtitle, appIcon | icon | emoji, accessory, ... }
MouseArea {
    id: root

    required property var item
    required property int index
    property bool selected: false
    property string notice: "" // e.g. "Press ↵ again to confirm"

    signal hovered(int index)
    signal activated(int index)

    readonly property bool isHeader: !!item.header

    implicitHeight: isHeader ? 28 : 44
    hoverEnabled: !isHeader
    cursorShape: isHeader ? Qt.ArrowCursor : Qt.PointingHandCursor
    // Select on real mouse movement only, so rows scrolling under a resting
    // pointer (keyboard navigation) don't steal the selection.
    onPositionChanged: if (!isHeader)
        root.hovered(index)
    onClicked: if (!isHeader)
        root.activated(index)

    Rectangle {
        visible: !root.isHeader
        anchors.fill: parent
        radius: 10
        color: root.selected ? Theme.glassTileHover : "transparent"
    }

    // Section header.
    Text {
        visible: root.isHeader
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        text: root.item.title ?? ""
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    RowLayout {
        visible: !root.isHeader
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 12
        spacing: 12

        // Icon slot: app icon, emoji, or a material icon on a tile.
        Item {
            implicitWidth: 28
            implicitHeight: 28

            IconImage {
                id: appIcon
                anchors.fill: parent
                visible: !!root.item.appIcon && status === Image.Ready
                source: root.item.appIcon ? Quickshell.iconPath(root.item.appIcon, true) : ""
                asynchronous: true
            }

            Text {
                visible: !!root.item.emoji
                anchors.centerIn: parent
                text: root.item.emoji ?? ""
                font.family: "Noto Color Emoji"
                font.pixelSize: 20
            }

            Rectangle {
                visible: !appIcon.visible && !root.item.emoji
                anchors.fill: parent
                radius: 8
                color: root.item.tint ?? Theme.surfaceHigh

                Icon {
                    anchors.centerIn: parent
                    name: root.item.icon || "apps"
                    filled: true
                    size: 17
                    color: root.item.tint ? Theme.background : Theme.foreground
                }
            }
        }

        // The title keeps its full width; only when the row is too narrow
        // for it does it elide (down to 140px). The subtitle gets what's left.
        Text {
            Layout.preferredWidth: implicitWidth
            Layout.minimumWidth: Math.min(implicitWidth, 140)
            text: root.item.title ?? ""
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
            font.family: root.item.mono ? "monospace" : Theme.font
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
            color: Theme.foreground
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            visible: !!root.item.subtitle
            text: root.item.subtitle ?? ""
            elide: Text.ElideRight
            maximumLineCount: 1
            textFormat: Text.PlainText
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        // Pushes the accessory right when there's no subtitle.
        Item {
            Layout.fillWidth: true
            visible: !root.item.subtitle
        }

        Text {
            text: root.selected && root.notice ? root.notice : root.item.accessory ?? ""
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: root.selected && root.notice ? Theme.urgent : Theme.foregroundDim
        }
    }
}
