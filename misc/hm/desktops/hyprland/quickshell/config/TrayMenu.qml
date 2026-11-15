import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

// A tray app's menu (DBusMenu), drawn like the bar's other dropdowns
// (instead of Qt's native popup menu).
// Submenus are entered in place, with a "Back" row to return.
Dropdown {
    id: root

    property var rootMenu: null
    property string title: ""

    // Submenu path; the last entry is the menu currently shown.
    property var stack: []
    readonly property var current: stack.length > 0 ? stack[stack.length - 1] : rootMenu

    contentWidth: 260

    onVisibleChanged: if (!visible)
        stack = []

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
        implicitHeight: 34
        enabled: root.stack.length > 0
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.stack = root.stack.slice(0, -1)

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius - 4
            color: parent.containsMouse ? Theme.surface : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Icon {
                visible: root.stack.length > 0
                name: "chevron_left"
                size: 18
            }

            Text {
                Layout.fillWidth: true
                text: root.stack.length > 0 ? root.label(root.stack[root.stack.length - 1].text) : root.title
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
                color: Theme.foreground
            }
        }
    }

    Separator {}

    Repeater {
        model: opener.children

        Loader {
            id: entryLoader
            required property var modelData

            width: parent.width
            sourceComponent: modelData.isSeparator ? separatorComponent : entryComponent

            Component {
                id: separatorComponent
                Separator {}
            }

            Component {
                id: entryComponent

                MouseArea {
                    id: entry
                    readonly property var menuEntry: entryLoader.modelData
                    readonly property bool checkable: menuEntry.buttonType !== QsMenuButtonType.None

                    width: entryLoader.width
                    implicitHeight: 34
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
                        radius: Theme.radius - 4
                        color: entry.containsMouse ? Theme.surface : "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10

                        // Checkbox / radio state, else the entry's icon.
                        Item {
                            implicitWidth: 18
                            implicitHeight: 18
                            // Hide the slot when the icon is missing from the icon theme.
                            visible: entry.checkable || (entry.menuEntry.icon !== "" && entryIcon.status === Image.Ready)

                            Icon {
                                anchors.centerIn: parent
                                visible: entry.checkable
                                name: entry.menuEntry.checkState === Qt.Checked ? (entry.menuEntry.buttonType === QsMenuButtonType.RadioButton ? "radio_button_checked" : "check_box") : (entry.menuEntry.buttonType === QsMenuButtonType.RadioButton ? "radio_button_unchecked" : "check_box_outline_blank")
                                size: 18
                                color: entry.menuEntry.checkState === Qt.Checked ? Theme.accent : Theme.foregroundDim
                            }

                            IconImage {
                                id: entryIcon
                                anchors.centerIn: parent
                                visible: !entry.checkable
                                implicitSize: 16
                                source: entry.menuEntry.icon
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.label(entry.menuEntry.text)
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            color: Theme.foreground
                        }

                        Icon {
                            visible: entry.menuEntry.hasChildren
                            name: "chevron_right"
                            size: 18
                            color: Theme.foregroundDim
                        }
                    }
                }
            }
        }
    }
}
