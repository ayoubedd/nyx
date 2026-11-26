import QtQuick
import QtQuick.Layouts
import qs.common

// (icon)  Label / detail                       [switch]
// A setting row for the notification center's detail views.
RowLayout {
    id: root

    property string icon
    property string label
    property string detail
    property bool checked
    signal toggled

    width: parent ? parent.width : 0
    spacing: 12

    Icon {
        name: root.icon
        size: 18
        color: Theme.foregroundDim
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: root.label
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foreground
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.detail
            elide: Text.ElideRight
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: Theme.foregroundDim
        }
    }

    Toggle {
        checked: root.checked
        onToggled: root.toggled()
    }
}
