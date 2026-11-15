import QtQuick

Item {
    width: parent ? parent.width : 0
    implicitHeight: 9

    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 16
        height: 1
        color: Theme.surfaceHigh
    }
}
