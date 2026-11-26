import QtQuick
import qs.common

// Rounded section card used by the bar menus (sound, Wi-Fi, Bluetooth,
// battery, privacy): surface colour, 12px padding, children stacked in a
// Column. Children size themselves with `width: parent.width` (the Column);
// code outside can use `contentWidth`.
//
//   Card {
//       Text { text: "Title" }
//       SomeRow { width: parent.width }
//   }
Rectangle {
    id: root

    default property alias content: column.data
    property alias spacing: column.spacing
    property int padding: 12
    readonly property alias contentWidth: column.width

    width: parent ? parent.width : 0
    implicitHeight: column.implicitHeight + 2 * padding
    radius: 14
    color: Theme.surface

    Column {
        id: column
        x: root.padding
        y: root.padding
        width: parent.width - 2 * root.padding
        spacing: 10
    }
}
