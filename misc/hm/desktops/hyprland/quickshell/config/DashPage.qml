import QtQuick

// A dashboard page that fades and slides in when its tab becomes active.
Item {
    id: root

    property bool active: false

    anchors.fill: parent
    opacity: active ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: 180
        }
    }

    transform: Translate {
        y: root.active ? 0 : 8

        Behavior on y {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }
}
