import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Month calendar with prev/next navigation; today is highlighted.
ColumnLayout {
    id: root

    property bool active: false

    property date today: new Date()
    property int month: today.getMonth()
    property int year: today.getFullYear()

    function shift(delta) {
        const d = new Date(year, month + delta, 1);
        month = d.getMonth();
        year = d.getFullYear();
    }

    // Jump back to the current month each time the tab is shown.
    onActiveChanged: if (active) {
        today = new Date();
        month = today.getMonth();
        year = today.getFullYear();
    }

    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
            font.family: Theme.font
            font.pixelSize: 20
            font.weight: Font.DemiBold
            color: Theme.foreground
        }

        PillButton {
            icon: "chevron_left"
            onClicked: root.shift(-1)
        }

        PillButton {
            text: "Today"
            onClicked: {
                root.month = root.today.getMonth();
                root.year = root.today.getFullYear();
            }
        }

        PillButton {
            icon: "chevron_right"
            onClicked: root.shift(1)
        }
    }

    DayOfWeekRow {
        Layout.fillWidth: true
        locale: grid.locale

        delegate: Text {
            required property string shortName
            text: shortName
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }
    }

    MonthGrid {
        id: grid
        Layout.fillWidth: true
        Layout.fillHeight: true
        month: root.month
        year: root.year
        locale: Qt.locale()
        spacing: 2

        delegate: Item {
            id: cell
            required property var model

            readonly property bool inMonth: model.month === grid.month

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) - 4
                height: width
                radius: width / 2
                color: cell.model.today ? Theme.accent : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: cell.model.day
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.weight: cell.model.today ? Font.DemiBold : Font.Normal
                color: cell.model.today ? Theme.background : cell.inMonth ? Theme.foreground : Theme.muted
            }
        }
    }
}
