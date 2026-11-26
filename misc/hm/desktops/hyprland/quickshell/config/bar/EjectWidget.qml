import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// ⏏ in the bar while a removable drive is mounted (Removable.qml).
// One drive: click ejects it. Several: click lists them, each with Eject.
BarButton {
    id: root

    visible: Removable.drives.length > 0
    icon: "eject"
    active: menu.shown
    tooltip: Removable.drives.length === 1 ? `Eject ${Removable.drives[0].name}` : `${Removable.drives.length} drives · click to eject`
    onClicked: {
        if (Removable.drives.length === 1)
            Removable.eject(Removable.drives[0]);
        else
            menu.toggle();
    }

    Dropdown {
        id: menu
        target: root
        contentWidth: 280
        contentSpacing: 4

        Repeater {
            model: Removable.drives

            MenuItem {
                required property var modelData
                Layout.fillWidth: true
                width: parent?.width ?? 0
                icon: Removable.ejecting === modelData.target ? "hourglass_top" : "eject"
                label: modelData.name
                detail: modelData.source
                onClicked: Removable.eject(modelData)
            }
        }
    }
}
