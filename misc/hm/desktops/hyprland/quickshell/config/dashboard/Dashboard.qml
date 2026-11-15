import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Dashboard dropped down from the clock: a tab rail on the left, pages on
// the right. Pages only poll/refresh while they are the visible tab.
Dropdown {
    id: root

    centered: true
    // Slides down from the top edge to open, back up to close.
    slide: true
    contentWidth: 680

    property int current: 0

    readonly property var tabs: [
        {
            icon: "home",
            label: "Home"
        },
        {
            icon: "calendar_month",
            label: "Calendar"
        },
        {
            icon: "bolt",
            label: "Power"
        },
        {
            icon: "monitoring",
            label: "System"
        },
        {
            icon: "wallpaper",
            label: "Wallpaper" // WallpaperPage.qml
        }
    ]

    function isActive(index) {
        return shown && current === index;
    }

    RowLayout {
        width: parent.width
        height: 440
        spacing: 8

        // ---- tab rail ----
        Column {
            Layout.preferredWidth: 72
            Layout.fillHeight: true
            Layout.topMargin: 4
            spacing: 4

            Repeater {
                model: root.tabs

                DashTab {
                    required property var modelData
                    required property int index
                    icon: modelData.icon
                    label: modelData.label
                    selected: root.current === index
                    onClicked: root.current = index
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            implicitWidth: 1
            color: Theme.surfaceHigh
        }

        // ---- pages ----
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 6

            DashPage {
                active: root.isActive(0)
                HomePage {
                    anchors.fill: parent
                    active: root.isActive(0)
                }
            }

            DashPage {
                active: root.isActive(1)
                CalendarPage {
                    anchors.fill: parent
                    active: root.isActive(1)
                }
            }

            DashPage {
                active: root.isActive(2)
                PowerPage {
                    anchors.fill: parent
                    active: root.isActive(2)
                }
            }

            DashPage {
                active: root.isActive(3)
                SystemPage {
                    anchors.fill: parent
                    active: root.isActive(3)
                }
            }

            DashPage {
                active: root.isActive(4)
                WallpaperPage {
                    anchors.fill: parent
                    active: root.isActive(4)
                }
            }
        }
    }
}
