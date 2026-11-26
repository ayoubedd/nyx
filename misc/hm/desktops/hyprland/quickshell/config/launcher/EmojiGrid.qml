import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Emoji view: category chips, the grid, and a details strip for the
// selected emoji. Keyboard navigation lives in Launcher.qml (it moves
// `current`); this only reports clicks/hover.
Item {
    id: root

    property var model: [] // [{ char, name, group, keywords, recent }]
    property int current: 0
    property bool browsing: true // no query: show category chips

    readonly property int cell: 52
    // From the view's own width, not the grid's: the grid is sized from
    // `columns`, so measuring the grid would lock it at one column.
    readonly property int columns: Math.max(1, Math.floor(width / cell))
    readonly property var selectedEmoji: model[current] ?? null

    signal hovered(int index)
    signal activated(int index)

    onCurrentChanged: grid.positionViewAtIndex(current, GridView.Contain)

    // Jump to the first emoji of a category.
    function jumpTo(groupIndex) {
        const i = model.findIndex(e => !e.recent && e.group === groupIndex);
        if (i >= 0) {
            root.hovered(i);
            grid.positionViewAtIndex(i, GridView.Beginning);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Category chips.
        Row {
            visible: root.browsing && Emoji.groups.length > 0
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Repeater {
                model: Emoji.groups

                MouseArea {
                    id: chip
                    required property var modelData
                    required property int index
                    readonly property bool active: root.selectedEmoji && !root.selectedEmoji.recent && root.selectedEmoji.group === index

                    width: 34
                    height: 30
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.jumpTo(index)

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: chip.active ? Theme.glassTileHover : chip.containsMouse ? Theme.glassTile : "transparent"
                    }

                    Icon {
                        anchors.centerIn: parent
                        name: Emoji.groupIcons[chip.modelData] ?? "mood"
                        filled: chip.active
                        size: 17
                        color: chip.active ? Theme.foreground : Theme.foregroundDim
                    }
                }
            }
        }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Whole cells only, centered.
            Layout.maximumWidth: root.columns * root.cell
            Layout.alignment: Qt.AlignHCenter
            cellWidth: root.cell
            cellHeight: root.cell
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.model
            currentIndex: root.current
            highlightFollowsCurrentItem: false

            delegate: MouseArea {
                id: cellArea
                required property var modelData
                required property int index

                width: root.cell
                height: root.cell
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: root.hovered(index)
                onClicked: root.activated(index)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 10
                    color: cellArea.index === root.current ? Theme.glassTileHover : "transparent"
                    border.width: cellArea.index === root.current ? 1 : 0
                    border.color: Theme.glassBorder
                }

                Text {
                    anchors.centerIn: parent
                    // `?? ""`: while switching views the grid can briefly get
                    // the other view's rows (no `char`).
                    text: cellArea.modelData.char ?? ""
                    font.family: "Noto Color Emoji"
                    font.pixelSize: 28
                }
            }
        }

        // Details of the selected emoji.
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 6
            Layout.rightMargin: 6
            Layout.preferredHeight: 36
            spacing: 10
            visible: !!root.selectedEmoji

            Text {
                text: root.selectedEmoji?.char ?? ""
                font.family: "Noto Color Emoji"
                font.pixelSize: 24
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: {
                        const n = root.selectedEmoji?.name ?? "";
                        return n.charAt(0).toUpperCase() + n.slice(1);
                    }
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: {
                        const e = root.selectedEmoji;
                        if (!e)
                            return "";
                        const group = Emoji.groups[e.group] ?? "";
                        return [e.recent ? "Recently used" : group, e.keywords].filter(s => s).join(" · ");
                    }
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            // Default skin tone (remembered), for emoji that have tones.
            Row {
                spacing: 4

                Repeater {
                    model: Emoji.toneSwatches

                    MouseArea {
                        id: swatch
                        required property string modelData
                        required property int index
                        readonly property bool active: LauncherStore.emojiTone === index

                        width: 20
                        height: 20
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: LauncherStore.setEmojiTone(index)

                        Rectangle {
                            anchors.centerIn: parent
                            width: swatch.active ? 18 : 14
                            height: width
                            radius: width / 2
                            color: swatch.modelData
                            border.width: swatch.active ? 2 : swatch.containsMouse ? 1 : 0
                            border.color: Theme.foreground

                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.ms(120)
                                }
                            }
                        }

                        Tooltip {
                            target: swatch
                            text: `Skin tone: ${Emoji.toneNames[swatch.index]}`
                            show: swatch.containsMouse
                        }
                    }
                }
            }
        }
    }
}
