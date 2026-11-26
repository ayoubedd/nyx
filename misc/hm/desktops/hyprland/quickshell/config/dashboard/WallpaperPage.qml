import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Dashboard tab: thumbnail grid of ~/Pictures/Wallpapers (Wallpaper.qml).
// Click to set and pin one; "Shuffle" goes back to the 15-min rotation.
ColumnLayout {
    id: root

    property bool active: false

    spacing: 10

    onActiveChanged: if (active)
        Wallpaper.refresh()

    RowLayout {
        Layout.fillWidth: true

        Column {
            Layout.fillWidth: true

            SectionLabel {
                text: "Wallpaper"
            }

            Text {
                text: Wallpaper.shuffling ? "Shuffling every 15 minutes" : "Pinned"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }
        }

        // Shuffle toggle pill.
        MouseArea {
            implicitWidth: shuffleRow.implicitWidth + 20
            implicitHeight: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Wallpaper.setShuffle(!Wallpaper.shuffling)

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Wallpaper.shuffling ? Theme.accent : parent.containsMouse ? Theme.surfaceHigh : Theme.surface

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }
            }

            Row {
                id: shuffleRow
                anchors.centerIn: parent
                spacing: 6

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "shuffle"
                    size: 16
                    color: Wallpaper.shuffling ? Theme.background : Theme.foreground
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Shuffle"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Wallpaper.shuffling ? Font.DemiBold : Font.Normal
                    color: Wallpaper.shuffling ? Theme.background : Theme.foreground
                }
            }
        }
    }

    GridView {
        id: grid

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        readonly property int columns: 3
        cellWidth: Math.floor(width / columns)
        cellHeight: Math.round(cellWidth * 9 / 16)

        model: Wallpaper.images

        delegate: MouseArea {
            id: tile
            required property string modelData
            readonly property bool selected: modelData === Wallpaper.current

            width: grid.cellWidth
            height: grid.cellHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Wallpaper.apply(modelData)

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: 10
                color: Theme.surface
                clip: true

                Image {
                    anchors.fill: parent
                    source: `file://${tile.modelData}`
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    // Decode small; these are multi-megapixel images.
                    sourceSize.width: 320
                    sourceSize.height: 180
                    opacity: status === Image.Ready ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.ms(200)
                        }
                    }
                }

                // Hover / selected outline.
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: tile.selected ? 3 : tile.containsMouse ? 2 : 0
                    border.color: tile.selected ? Theme.accent : Qt.rgba(1, 1, 1, 0.5)
                }

                // Checkmark on the current one.
                Rectangle {
                    visible: tile.selected
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    width: 22
                    height: 22
                    radius: 11
                    color: Theme.accent

                    Icon {
                        anchors.centerIn: parent
                        name: "check"
                        size: 15
                        color: Theme.background
                    }
                }
            }
        }
    }
}
