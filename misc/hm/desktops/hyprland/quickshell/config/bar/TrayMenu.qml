import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common
import qs.components

// A tray app's menu (DBusMenu), drawn like the bar's other dropdowns
// (instead of Qt's native popup menu), but compact like a context menu:
// short rows, smaller text, and as wide as the longest entry (180-320px).
// Submenus are entered in place, with a "Back" row to return.
Dropdown {
    id: root

    property var rootMenu: null
    property string title: ""

    // Submenu path; the last entry is the menu currently shown.
    property var stack: []
    readonly property var current: stack.length > 0 ? stack[stack.length - 1] : rootMenu

    // Compact metrics.
    readonly property int rowHeight: 26
    readonly property int textSize: Theme.fontSize - 1
    readonly property int iconSize: 15

    // Widest label in the current menu (rows report theirs), for the width.
    property real widestLabel: 0
    // label + icon slot + chevron + row padding + card margins
    contentWidth: Math.max(180, Math.min(320, Math.ceil(widestLabel) + iconSize + iconSize + 8 * 2 + 10 * 2 + 16))
    contentSpacing: 0

    onCurrentChanged: widestLabel = 0
    onVisibleChanged: if (!visible)
        stack = []

    function reportWidth(w) {
        if (w > widestLabel)
            widestLabel = w;
    }

    // DBusMenu labels use "_" for mnemonics ("_Quit"); "__" is a literal "_".
    function label(text) {
        return (text || "").replace(/__/g, "\u0000").replace(/_/g, "").replace(/\u0000/g, "_");
    }

    QsMenuOpener {
        id: opener
        menu: root.current
    }

    // Header: app name, or "Back" inside a submenu.
    MouseArea {
        width: parent.width
        implicitHeight: root.rowHeight + 2
        enabled: root.stack.length > 0
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.stack = root.stack.slice(0, -1)

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: parent.containsMouse ? Theme.surface : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 6

            Icon {
                visible: root.stack.length > 0
                name: "chevron_left"
                size: root.iconSize
            }

            Text {
                id: headerText
                Layout.fillWidth: true
                text: root.stack.length > 0 ? root.label(root.stack[root.stack.length - 1].text) : root.title
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: root.textSize
                font.weight: Font.DemiBold
                color: Theme.foregroundDim
                onImplicitWidthChanged: root.reportWidth(implicitWidth)
                Component.onCompleted: root.reportWidth(implicitWidth)
            }
        }
    }

    // Thin divider (half the height of the regular Separator).
    component ThinSeparator: Item {
        width: parent ? parent.width : 0
        implicitHeight: 5

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 12
            height: 1
            color: Theme.surfaceHigh
        }
    }

    ThinSeparator {}

    Repeater {
        model: opener.children

        Loader {
            id: entryLoader
            required property var modelData

            width: parent.width
            sourceComponent: modelData.isSeparator ? separatorComponent : entryComponent

            Component {
                id: separatorComponent
                ThinSeparator {}
            }

            Component {
                id: entryComponent

                MouseArea {
                    id: entry
                    readonly property var menuEntry: entryLoader.modelData
                    readonly property bool checkable: menuEntry.buttonType !== QsMenuButtonType.None

                    width: entryLoader.width
                    implicitHeight: root.rowHeight
                    enabled: menuEntry.enabled
                    opacity: enabled ? 1 : 0.4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (menuEntry.hasChildren) {
                            root.stack = [...root.stack, menuEntry];
                        } else {
                            menuEntry.triggered();
                            root.shown = false;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: entry.containsMouse ? Theme.surface : "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        // Checkbox / radio state, else the entry's icon.
                        Item {
                            implicitWidth: root.iconSize
                            implicitHeight: root.iconSize
                            // Hide the slot when the icon is missing from the icon theme.
                            visible: entry.checkable || (entry.menuEntry.icon !== "" && entryIcon.status === Image.Ready)

                            Icon {
                                anchors.centerIn: parent
                                visible: entry.checkable
                                name: entry.menuEntry.checkState === Qt.Checked ? (entry.menuEntry.buttonType === QsMenuButtonType.RadioButton ? "radio_button_checked" : "check_box") : (entry.menuEntry.buttonType === QsMenuButtonType.RadioButton ? "radio_button_unchecked" : "check_box_outline_blank")
                                size: root.iconSize
                                color: entry.menuEntry.checkState === Qt.Checked ? Theme.accent : Theme.foregroundDim
                            }

                            IconImage {
                                id: entryIcon
                                anchors.centerIn: parent
                                visible: !entry.checkable
                                implicitSize: root.iconSize - 1
                                source: entry.menuEntry.icon
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.label(entry.menuEntry.text)
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: root.textSize
                            color: Theme.foreground
                            onImplicitWidthChanged: root.reportWidth(implicitWidth)
                            Component.onCompleted: root.reportWidth(implicitWidth)
                        }

                        Icon {
                            visible: entry.menuEntry.hasChildren
                            name: "chevron_right"
                            size: root.iconSize
                            color: Theme.foregroundDim
                        }
                    }
                }
            }
        }
    }
}
