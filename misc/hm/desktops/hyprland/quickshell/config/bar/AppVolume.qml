import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.services
import qs.components

// One app playing audio:
//   [icon]  App name · what's playing         64%
//           ━━━━━━━━━━━━━━━━━━━━━━
// Click the icon to mute/unmute the app.
RowLayout {
    id: root

    required property var node

    readonly property var props: node?.properties ?? {}
    readonly property string appName: props["application.name"] || node?.description || node?.name || "Unknown app"
    readonly property string media: props["media.name"] ?? ""
    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real volume: node?.audio?.volume ?? 0
    readonly property string iconSource: {
        const candidates = [props["application.icon-name"], props["application.process.binary"], appName.toLowerCase()];
        for (const c of candidates) {
            const path = c ? Quickshell.iconPath(c, true) : "";
            if (path)
                return path;
        }
        return "";
    }

    width: parent ? parent.width : 0
    spacing: 10

    // App icon = mute toggle.
    MouseArea {
        id: iconButton
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 30
        implicitHeight: 30
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Audio.toggleMute(root.node)

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: iconButton.containsMouse ? Theme.surfaceHigh : "transparent"
        }

        IconImage {
            id: appIcon
            anchors.centerIn: parent
            implicitSize: 22
            source: root.iconSource
            visible: status === Image.Ready
            opacity: root.muted ? 0.35 : 1
        }

        Icon {
            anchors.centerIn: parent
            visible: !appIcon.visible
            name: "music_note"
            size: 18
            color: Theme.foregroundDim
        }

        // Muted badge.
        Rectangle {
            visible: root.muted
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 14
            height: 14
            radius: 7
            color: Theme.urgent

            Icon {
                anchors.centerIn: parent
                name: "volume_off"
                filled: true
                size: 10
                color: Theme.background
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text: root.appName
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Text {
                Layout.fillWidth: true
                visible: root.media !== "" && root.media !== root.appName
                text: root.media
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            Item {
                Layout.fillWidth: true
                visible: !(root.media !== "" && root.media !== root.appName)
            }

            Text {
                text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%`
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }
        }

        ThinSlider {
            Layout.fillWidth: true
            value: root.muted ? 0 : root.volume
            muted: root.muted
            onMoved: v => Audio.setVolume(root.node, v)
        }
    }
}
