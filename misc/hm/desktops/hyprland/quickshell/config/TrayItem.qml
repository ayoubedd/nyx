import QtQuick
import Quickshell.Widgets

// One tray icon.
//   left click    activate (or the menu, for menu-only items)
//   right click   menu
//   middle click  secondary activate
//   scroll        forwarded to the app
MouseArea {
    id: root

    required property var item

    implicitWidth: 28
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            item.secondaryActivate();
        else if (mouse.button === Qt.RightButton || item.onlyMenu)
            openMenu();
        else
            item.activate();
    }

    onWheel: wheel => {
        const vertical = Math.abs(wheel.angleDelta.y) >= Math.abs(wheel.angleDelta.x);
        item.scroll(vertical ? wheel.angleDelta.y : wheel.angleDelta.x, !vertical);
    }

    function openMenu() {
        if (item.hasMenu)
            menu.toggle();
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: menu.shown ? Theme.surfaceHigh : root.containsMouse ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animDuration
            }
        }
    }

    IconImage {
        id: icon
        anchors.centerIn: parent
        implicitSize: 16
        source: root.item.icon
    }

    // Fallback when the app's icon can't be resolved.
    Icon {
        anchors.centerIn: parent
        visible: icon.status !== Image.Ready
        name: "apps"
        size: 16
        color: Theme.foregroundDim
    }

    TrayMenu {
        id: menu
        target: root
        rootMenu: root.item.menu
        title: root.item.tooltipTitle || root.item.title || root.item.id
    }

    Tooltip {
        target: root
        text: root.item.tooltipTitle || root.item.title || root.item.id
        show: root.containsMouse && !root.pressed && !menu.shown
    }
}
