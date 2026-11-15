import QtQuick
import qs.common

// Rounded control-center tile.
Rectangle {
    default property alias content: inner.data
    property alias spacing: inner.spacing

    implicitHeight: inner.implicitHeight + 24
    radius: 16
    color: Theme.glassTile
    border.width: 1
    border.color: Theme.glassBorder

    Column {
        id: inner
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 12
        }
        spacing: 10
    }
}
