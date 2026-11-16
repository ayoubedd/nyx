import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import qs.common
import qs.services
import qs.components

// Battery status + tuned profile switcher.
ColumnLayout {
    id: root

    property bool active: false

    // Last timed keep-awake choice made here (to highlight its chip).
    property int caffeineChoice: -1

    spacing: 12

    // Profiles: services/TunedProfiles.qml (polls only while shown).
    onActiveChanged: TunedProfiles.watch(active)
    Component.onDestruction: if (active)
        TunedProfiles.watch(false)

    // ---- battery ----
    Rectangle {
        Layout.fillWidth: true
        visible: Battery.present
        implicitHeight: 96
        radius: Theme.radius
        color: Theme.surface

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Icon {
                name: Battery.icon
                filled: true
                size: 40
                color: Battery.color
            }

            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: `${Math.round(Battery.percent * 100)}%`
                    font.family: Theme.font
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Battery.status
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    color: Theme.foregroundDim
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: {
                        const parts = [];
                        if (Battery.rate > 0.05)
                            parts.push(`${Battery.charging ? "Charging at" : "Using"} ${Battery.rate.toFixed(1)} W`);
                        if (Battery.capacity > 0)
                            parts.push(`${Battery.energy.toFixed(1)} / ${Battery.capacity.toFixed(1)} Wh`);
                        if (Battery.device?.healthSupported) {
                            const h = Battery.device.healthPercentage;
                            parts.push(`Health ${Math.round(h > 1 ? h : h * 100)}%`);
                        }
                        return parts.join(" · ");
                    }
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }
            }
        }
    }

    // ---- tuned profiles ----
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4

        SectionLabel {
            Layout.fillWidth: true
            Layout.leftMargin: 2
            text: "Power profile"
        }

        // Automatic = whatever the power source calls for; picking a profile
        // below overrides it until the next plug/unplug.
        MouseArea {
            id: autoChip
            implicitWidth: autoRow.implicitWidth + 18
            implicitHeight: 26
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (!TunedProfiles.automatic)
                TunedProfiles.setAutomatic()

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: TunedProfiles.automatic ? Theme.accent : autoChip.containsMouse ? Theme.surfaceHigh : Theme.surface

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }
            }

            Row {
                id: autoRow
                anchors.centerIn: parent
                spacing: 5

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "auto_mode"
                    size: 15
                    color: TunedProfiles.automatic ? Theme.background : Theme.foreground
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Automatic"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: TunedProfiles.automatic ? Font.DemiBold : Font.Normal
                    color: TunedProfiles.automatic ? Theme.background : Theme.foreground
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        Repeater {
            model: TunedProfiles.profiles

            MouseArea {
                id: profile
                required property var modelData
                readonly property bool selected: TunedProfiles.current === modelData.id

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 64
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (!selected)
                    TunedProfiles.set(modelData.id)

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius
                    color: profile.selected ? Theme.surfaceHigh : profile.containsMouse ? Theme.surface : Theme.surface
                    border.width: profile.selected ? 2 : 1
                    border.color: profile.selected ? Theme.accent : Theme.surfaceHigh

                    Behavior on border.color {
                        ColorAnimation {
                            duration: Theme.animDuration
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Icon {
                        name: profile.modelData.icon
                        filled: profile.selected
                        size: 24
                        color: profile.selected ? Theme.accent : Theme.foreground
                    }

                    Column {
                        Layout.fillWidth: true

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: profile.modelData.label
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.DemiBold
                            color: Theme.foreground
                        }

                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: profile.modelData.detail
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.foregroundDim
                        }
                    }
                }
            }
        }
    }

    // ---- keep awake (Caffeine.qml) ----
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4

        SectionLabel {
            Layout.fillWidth: true
            Layout.leftMargin: 2
            text: "Keep awake"
        }

        Text {
            text: Caffeine.remainingText
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            // minutes: -1 = off, 0 = until turned off
            model: [
                {
                    minutes: -1,
                    label: "Off"
                },
                {
                    minutes: 30,
                    label: "30 min"
                },
                {
                    minutes: 60,
                    label: "1 hour"
                },
                {
                    minutes: 120,
                    label: "2 hours"
                },
                {
                    minutes: 0,
                    label: "Always"
                }
            ]

            MouseArea {
                id: choice
                required property var modelData

                // Which chip is "current": off, indefinite, or the chosen timer.
                readonly property bool selected: modelData.minutes === -1 ? !Caffeine.active : Caffeine.active && (modelData.minutes === 0 ? Caffeine.until === 0 : root.caffeineChoice === modelData.minutes)

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 34
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.minutes < 0) {
                        Caffeine.disable();
                    } else {
                        root.caffeineChoice = modelData.minutes;
                        Caffeine.enable(modelData.minutes);
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: choice.selected ? Theme.accent : choice.containsMouse ? Theme.surfaceHigh : Theme.surface

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animDuration
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: choice.modelData.label
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: choice.selected ? Font.DemiBold : Font.Normal
                    color: choice.selected ? Theme.background : Theme.foreground
                }
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
