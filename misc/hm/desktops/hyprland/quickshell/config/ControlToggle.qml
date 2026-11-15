import QtQuick
import QtQuick.Layouts

// Round icon toggle with a title and status line (macOS control style).
MouseArea {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool checked: false
    property bool large: false

    width: parent ? parent.width : 0
    implicitHeight: large ? 72 : 36
    cursorShape: Qt.PointingHandCursor

    GridLayout {
        anchors.fill: parent
        columns: root.large ? 1 : 2
        columnSpacing: 10
        rowSpacing: 6

        Rectangle {
            Layout.alignment: root.large ? Qt.AlignLeft : Qt.AlignVCenter
            implicitWidth: 32
            implicitHeight: 32
            radius: 16
            color: root.checked ? Theme.accent : Theme.surfaceHigh

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animDuration
                }
            }

            Icon {
                anchors.centerIn: parent
                name: root.icon
                filled: root.checked
                size: 17
                color: root.checked ? Theme.background : Theme.foreground
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                width: parent.width
                text: root.title
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: root.subtitle
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }
        }
    }
}
