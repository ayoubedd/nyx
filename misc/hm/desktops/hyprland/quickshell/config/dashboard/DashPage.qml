import QtQuick
import qs.common

// A dashboard page that fades and slides in when its tab becomes active.
//
// The page itself (`page`) is only instantiated while this tab is visible
// (including its fade-out), and destroyed afterwards: closed tabs and a
// closed dashboard hold no items, images or timers. Pages reset their view
// in onActiveChanged, so nothing is lost. `active` is bound after creation,
// so the page always sees it change false -> true and runs that reset.
Item {
    id: root

    property bool active: false
    property Component page

    anchors.fill: parent
    opacity: active ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.ms(180)
        }
    }

    transform: Translate {
        y: root.active ? 0 : 8

        Behavior on y {
            NumberAnimation {
                duration: Theme.ms(220)
                easing.type: Easing.OutCubic
            }
        }
    }

    Loader {
        anchors.fill: parent
        active: root.visible
        sourceComponent: root.page
        onLoaded: item.active = Qt.binding(() => root.active)
    }
}
