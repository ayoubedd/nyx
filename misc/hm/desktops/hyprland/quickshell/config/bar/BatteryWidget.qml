import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.common
import qs.services
import qs.components

// Bar battery: icon, percentage and time left / time to full.
// Hidden on machines without a battery. Click: battery menu (charge details
// and power profile, same card style as the other bar menus).
MouseArea {
    id: root

    visible: Battery.present
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 26
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: menu.toggle()

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

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: Battery.icon
            filled: true
            color: Battery.color
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${Math.round(Battery.percent * 100)}%`
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: Battery.low ? Theme.urgent : Theme.foreground
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            leftPadding: 2
            text: Battery.shortEstimate
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foregroundDim
        }
    }

    Tooltip {
        target: root
        text: `Battery: ${Math.round(Battery.percent * 100)}% · ${Battery.status}`
        show: root.containsMouse && !root.pressed && !menu.shown
    }

    // qs -c nyx ipc call bar toggle battery
    Connections {
        target: Ui
        function onMenuRequested(name, screen) {
            if (name === "battery" && (root.QsWindow.window?.screen?.name ?? "") === screen)
                menu.toggle();
        }
    }

    // Charge limit (ThinkPad charge_control_end_threshold): read by the
    // Battery service, so its "held at N%" notification sees the same value.
    readonly property int chargeLimit: Battery.chargeLimit
    readonly property bool fullOnce: Battery.fullOnce

    function setFullOnce(on) {
        Battery.setFullOnce(on);
    }

    Dropdown {
        id: menu
        target: root
        contentWidth: 340
        contentSpacing: 8
        // The menu shows the profile; don't also pop the profile OSD.
        suppressOsd: true

        onShownChanged: {
            TunedProfiles.watch(shown);
            if (shown)
                Battery.reloadLimit();
        }

        // ---- battery ----
        Card {
            id: batteryColumn

            RowLayout {
                width: parent.width
                spacing: 10

                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: Battery.charging || Battery.full ? Theme.success : Battery.low ? Theme.urgent : Theme.surfaceHigh

                    Icon {
                        anchors.centerIn: parent
                        name: Battery.icon
                        filled: true
                        size: 18
                        color: Battery.charging || Battery.full || Battery.low ? Theme.background : Theme.foreground
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        text: `${Math.round(Battery.percent * 100)}%`
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize + 5
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Text {
                        Layout.fillWidth: true
                        text: Battery.status
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }
                }
            }

            // Charge level, with a tick at the charge limit.
            Item {
                width: parent.width
                height: 6

                Rectangle {
                    anchors.fill: parent
                    radius: 3
                    color: Theme.surfaceHigh
                }

                Rectangle {
                    width: Math.max(height, parent.width * Battery.percent)
                    height: parent.height
                    radius: 3
                    color: Battery.charging || Battery.full ? Theme.success : Battery.low ? Theme.urgent : Theme.foreground

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.ms(300)
                        }
                    }
                }

                Rectangle {
                    visible: root.chargeLimit > 0 && root.chargeLimit < 100
                    x: parent.width * root.chargeLimit / 100 - 1
                    y: -3
                    width: 2
                    height: parent.height + 6
                    radius: 1
                    color: Theme.foregroundDim
                }
            }

            // Details.
            GridLayout {
                width: parent.width
                columns: 2
                columnSpacing: 12
                rowSpacing: 4

                Key {
                    visible: Battery.rate > 0.05
                    text: Battery.charging ? "Charging at" : "Power draw"
                }
                Value {
                    visible: Battery.rate > 0.05
                    text: `${Battery.rate.toFixed(1)} W`
                }

                Key {
                    visible: Battery.capacity > 0
                    text: "Energy"
                }
                Value {
                    visible: Battery.capacity > 0
                    text: `${Battery.energy.toFixed(1)} / ${Battery.capacity.toFixed(1)} Wh`
                }

                Key {
                    visible: Battery.device?.healthSupported ?? false
                    text: "Health"
                }
                Value {
                    visible: Battery.device?.healthSupported ?? false
                    text: {
                        const h = Battery.device?.healthPercentage ?? 0;
                        return `${Math.round(h > 1 ? h : h * 100)}%`;
                    }
                }

                Key {
                    visible: root.chargeLimit > 0
                    text: "Charge limit"
                }
                Value {
                    visible: root.chargeLimit > 0
                    text: root.fullOnce ? "100% until unplugged" : `${root.chargeLimit}% (protects the battery)`
                }
            }

            // Charge to 100% once (machines/x1/power.nix: x1-charge-full /
            // x1-charge-limit units, allowed by a polkit rule). The limit
            // comes back on its own at the next unplug.
            MouseArea {
                id: fullOnceRow
                visible: root.chargeLimit > 0
                width: parent.width
                implicitHeight: 44
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setFullOnce(!root.fullOnce)

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: -6
                    anchors.rightMargin: -6
                    radius: 10
                    color: fullOnceRow.containsMouse ? Theme.surfaceHigh : "transparent"
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 15
                        color: root.fullOnce ? Theme.success : Theme.surfaceHigh

                        Icon {
                            anchors.centerIn: parent
                            name: "battery_charging_full"
                            filled: true
                            size: 16
                            color: root.fullOnce ? Theme.background : Theme.foreground
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: root.fullOnce ? "Charging to 100% once" : "Charge to 100% once"
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: Font.Medium
                            color: Theme.foreground
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.fullOnce ? "Back to 85% when you unplug" : "For a trip · back to 85% when you unplug"
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 3
                            color: Theme.foregroundDim
                        }
                    }

                    Toggle {
                        checked: root.fullOnce
                        onToggled: root.setFullOnce(!root.fullOnce)
                    }
                }
            }
        }

        // ---- power profile ----
        Card {
            id: profileColumn
            spacing: 4

            Text {
                bottomPadding: 6
                text: "Power profile"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            ProfileRow {
                icon: "auto_mode"
                label: "Automatic"
                detail: `${TunedProfiles.label(TunedProfiles.autoProfile)} ${Battery.discharging ? "on battery" : "on AC"}`
                selected: TunedProfiles.automatic
                onClicked: TunedProfiles.setAutomatic()
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surfaceHigh
            }

            Repeater {
                model: TunedProfiles.profiles

                ProfileRow {
                    required property var modelData
                    icon: modelData.icon
                    label: modelData.label
                    detail: modelData.detail
                    selected: TunedProfiles.current === modelData.id
                    // When automatic, the active profile is the automatic one.
                    dim: TunedProfiles.automatic
                    onClicked: TunedProfiles.set(modelData.id)
                }
            }
        }
    }

    component Key: Text {
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foregroundDim
    }
    component Value: Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foreground
    }

    // Selectable profile row: (icon)  Label / detail            ✓
    component ProfileRow: MouseArea {
        id: profileRow

        property string icon
        property string label
        property string detail
        property bool selected: false
        property bool dim: false // selected, but chosen by "Automatic"

        width: parent ? parent.width : 0
        implicitHeight: 40
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: 10
            color: profileRow.containsMouse ? Theme.surfaceHigh : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 15
                color: profileRow.selected && !profileRow.dim ? Theme.accent : Theme.surfaceHigh

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    name: profileRow.icon
                    filled: profileRow.selected
                    size: 16
                    color: profileRow.selected && !profileRow.dim ? Theme.background : Theme.foreground
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: profileRow.label
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: profileRow.selected ? Font.DemiBold : Font.Medium
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: profileRow.detail
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            Icon {
                visible: profileRow.selected
                name: "check"
                size: 18
                color: profileRow.dim ? Theme.foregroundDim : Theme.accent
            }
        }
    }
}
