import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Night light detail view of the notification center (services/NightLight.qml):
// on/off, warmth, and the schedule (off / sunset to sunrise / custom times).
ColumnLayout {
    id: root

    spacing: 12

    // ---- status + switch + warmth ----
    Tile {
        Layout.fillWidth: true
        spacing: 12

        RowLayout {
            width: parent.width
            spacing: 12

            Rectangle {
                implicitWidth: 44
                implicitHeight: 44
                radius: 22
                color: NightLight.on ? Theme.accent : Theme.surfaceHigh

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    name: "nightlight"
                    filled: NightLight.on
                    size: 22
                    color: NightLight.on ? Theme.background : Theme.foreground
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: NightLight.on ? `On · ${NightLight.temperature}K` : "Off"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: NightLight.scheduleText || "No schedule"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }
            }

            Toggle {
                checked: NightLight.on
                onToggled: NightLight.toggle()
            }
        }

        // Warmth (also what the schedule turns on with).
        RowLayout {
            width: parent.width
            spacing: 10

            Text {
                text: "Warmth"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 2
                color: Theme.foregroundDim
            }

            Slider {
                Layout.fillWidth: true
                icon: "nightlight"
                value: NightLight.on ? NightLight.warmth : (NightLight.neutral - NightLight.nightTemp) / (NightLight.neutral - NightLight.warmest)
                onMoved: v => NightLight.setWarmth(Math.max(0.05, v))
            }
        }
    }

    // ---- schedule ----
    Text {
        Layout.leftMargin: 4
        text: "Schedule"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        Layout.fillWidth: true
        spacing: 2

        Choice {
            icon: "do_not_disturb_on"
            label: "Off"
            detail: "Only when you turn it on"
            selected: NightLight.mode === "off"
            onClicked: NightLight.setMode("off")
        }

        Choice {
            icon: "wb_twilight"
            label: "Sunset to sunrise"
            detail: NightLight.sunKnown ? `${NightLight.clockText(NightLight.sunset)} – ${NightLight.clockText(NightLight.sunrise)}${Weather.city ? ` · ${Weather.city}` : ""}` : "Waiting for your location (19:00 – 07:00 until then)"
            selected: NightLight.mode === "sunset"
            onClicked: NightLight.setMode("sunset")
        }

        Choice {
            icon: "schedule"
            label: "Custom"
            detail: `${NightLight.clockText(NightLight.from)} – ${NightLight.clockText(NightLight.to)}`
            selected: NightLight.mode === "custom"
            onClicked: NightLight.setMode("custom")
        }

        TimeRow {
            visible: NightLight.mode === "custom"
            label: "From"
            minutes: NightLight.from
            onChanged: m => NightLight.setTimes(m, NightLight.to)
        }

        TimeRow {
            visible: NightLight.mode === "custom"
            label: "Until"
            minutes: NightLight.to
            onChanged: m => NightLight.setTimes(NightLight.from, m)
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        wrapMode: Text.WordWrap
        text: "Turning it on or off by hand lasts until the schedule's next switch. Sunset and sunrise follow your location (from the weather lookup)."
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foregroundDim
    }

    // Radio row: (icon)  Label / detail      ✓
    component Choice: MouseArea {
        id: choice

        property string icon
        property string label
        property string detail
        property bool selected: false

        width: parent ? parent.width : 0
        implicitHeight: 44
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: 10
            color: choice.containsMouse ? Theme.glassTileHover : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 12

            Icon {
                name: choice.icon
                size: 18
                color: choice.selected ? Theme.accent : Theme.foregroundDim
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: choice.label
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: choice.selected ? Font.DemiBold : Font.Normal
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: choice.detail
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: Theme.foregroundDim
                }
            }

            Icon {
                visible: choice.selected
                name: "check"
                size: 18
                color: Theme.accent
            }
        }
    }
}
