import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.components

// One card of the privacy menu (Microphone / Camera / Screen sharing):
//   (●)  Microphone                          [Mute]
//        Built-in microphone · 2 apps
//   [app icon]  Firefox
//   [app icon]  Discord
Card {
    id: root
    property string title
    property string icon
    property color tint
    property string detail // e.g. the device in use
    property var apps: [] // app names
    default property alias actions: actionSlot.data

    function appIcon(name) {
        const entry = DesktopEntries.heuristicLookup(name);
        return Quickshell.iconPath(entry?.icon || name.toLowerCase(), true);
    }

    function appLabel(name) {
        return DesktopEntries.heuristicLookup(name)?.name || name;
    }

    RowLayout {
        width: parent.width
        spacing: 10

        Rectangle {
            implicitWidth: 34
            implicitHeight: 34
            radius: 17
            color: root.tint

            Icon {
                anchors.centerIn: parent
                name: root.icon
                filled: true
                size: 18
                color: Theme.background
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Text {
                Layout.fillWidth: true
                text: [root.detail, root.apps.length === 1 ? "1 app" : `${root.apps.length} apps`].filter(s => s).join(" · ")
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 3
                color: Theme.foregroundDim
            }
        }

        // Optional action (e.g. mute), passed as children.
        Item {
            id: actionSlot
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }

    Repeater {
        model: root.apps

        RowLayout {
            id: appRow
            required property string modelData

            width: root.contentWidth
            spacing: 10

            Item {
                implicitWidth: 34
                implicitHeight: 26

                IconImage {
                    id: image
                    anchors.centerIn: parent
                    implicitSize: 22
                    source: root.appIcon(appRow.modelData)
                    visible: status === Image.Ready
                }

                Icon {
                    anchors.centerIn: parent
                    visible: !image.visible
                    name: "apps"
                    size: 18
                    color: Theme.foregroundDim
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.appLabel(appRow.modelData)
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                color: Theme.foreground
            }

            // Live dot.
            Rectangle {
                implicitWidth: 7
                implicitHeight: 7
                radius: 3.5
                color: root.tint
            }
        }
    }
}
