import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.components

// One app playing audio: icon, name, what it's playing, its own volume.
ColumnLayout {
    id: root

    required property var node

    readonly property var props: node?.properties ?? {}
    readonly property string appName: props["application.name"] || node?.description || node?.name || "Unknown app"
    readonly property string media: props["media.name"] ?? ""
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
    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        spacing: 8

        Item {
            implicitWidth: 18
            implicitHeight: 18

            IconImage {
                id: appIcon
                anchors.fill: parent
                source: root.iconSource
                visible: status === Image.Ready
            }

            Icon {
                anchors.centerIn: parent
                visible: !appIcon.visible
                name: "music_note"
                size: 16
                color: Theme.foregroundDim
            }
        }

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
    }

    VolumeRow {
        Layout.fillWidth: true
        node: root.node
    }
}
