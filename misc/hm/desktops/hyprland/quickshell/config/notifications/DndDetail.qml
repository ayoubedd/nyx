import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services
import qs.components

// Do Not Disturb detail view of the notification center (services/Notifs.qml):
// the switch, a daily schedule, and "while sharing your screen".
ColumnLayout {
    id: root

    spacing: 12

    // ---- status + switch ----
    Tile {
        Layout.fillWidth: true

        RowLayout {
            width: parent.width
            spacing: 12

            Rectangle {
                implicitWidth: 44
                implicitHeight: 44
                radius: 22
                color: Notifs.dnd ? Theme.accent : Theme.surfaceHigh

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    name: "do_not_disturb_on"
                    filled: Notifs.dnd
                    size: 22
                    color: Notifs.dnd ? Theme.background : Theme.foreground
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: Notifs.dnd ? "On" : "Off"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: Notifs.dnd ? Notifs.dndReason : Notifs.dndSnoozed ? "Turned off until this period ends" : "Notifications pop up as usual"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }
            }

            Toggle {
                checked: Notifs.dnd
                onToggled: Notifs.toggleDnd()
            }
        }
    }

    // ---- automatic ----
    Text {
        Layout.leftMargin: 4
        text: "Turn on automatically"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        Layout.fillWidth: true
        spacing: 10

        // Schedule.
        SwitchRow {
            icon: "schedule"
            label: "On a schedule"
            detail: Notifs.dndScheduleOn ? `Every day, ${Notifs.clockText(Notifs.dndFrom)} – ${Notifs.clockText(Notifs.dndTo)}` : "Off"
            checked: Notifs.dndScheduleOn
            onToggled: Notifs.dndScheduleOn = !Notifs.dndScheduleOn
        }

        TimeRow {
            visible: Notifs.dndScheduleOn
            label: "From"
            minutes: Notifs.dndFrom
            onChanged: m => Notifs.dndFrom = m
        }

        TimeRow {
            visible: Notifs.dndScheduleOn
            label: "Until"
            minutes: Notifs.dndTo
            onChanged: m => Notifs.dndTo = m
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        // Screen sharing.
        SwitchRow {
            icon: "screen_share"
            label: "While sharing your screen"
            detail: Notifs.dndSharing ? "Sharing now" : "Calls, recordings, presentations"
            checked: Notifs.dndWhileSharing
            onToggled: Notifs.dndWhileSharing = !Notifs.dndWhileSharing
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        wrapMode: Text.WordWrap
        text: "While on, notifications go straight to the notification center without popping up. Critical ones (like low battery) still show."
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foregroundDim
    }

    // ---- per-app rules (Notifs.appRules) ----
    Text {
        Layout.leftMargin: 4
        Layout.topMargin: 4
        text: "Apps"
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        Layout.fillWidth: true
        spacing: 4

        Text {
            visible: Object.keys(Notifs.appRules).length === 0
            width: parent.width
            wrapMode: Text.WordWrap
            text: "No app rules. Use ⋯ (or right-click) on a notification to keep an app out of popups or mute it."
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 2
            color: Theme.foregroundDim
        }

        Repeater {
            model: Object.keys(Notifs.appRules).sort((a, b) => (Notifs.appRules[a].name ?? a).localeCompare(Notifs.appRules[b].name ?? b))

            RowLayout {
                id: ruleRow
                required property string modelData
                readonly property var r: Notifs.appRules[modelData] ?? {}

                width: parent.width
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: ruleRow.r.name ?? ruleRow.modelData
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.foreground
                }

                // Segmented: Center only | Muted
                Repeater {
                    model: [
                        {
                            rule: "silent",
                            label: "Center only"
                        },
                        {
                            rule: "mute",
                            label: "Muted"
                        }
                    ]

                    MouseArea {
                        id: seg
                        required property var modelData
                        readonly property bool selected: ruleRow.r.rule === modelData.rule

                        implicitWidth: segText.implicitWidth + 18
                        implicitHeight: 26
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.setAppRule(ruleRow.modelData, modelData.rule, ruleRow.r.name)

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: seg.selected ? Theme.accent : seg.containsMouse ? Theme.glassTileHover : Theme.glassTile
                        }

                        Text {
                            id: segText
                            anchors.centerIn: parent
                            text: seg.modelData.label
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            font.weight: seg.selected ? Font.DemiBold : Font.Normal
                            color: seg.selected ? Theme.background : Theme.foreground
                        }
                    }
                }

                // Remove the rule.
                MouseArea {
                    id: removeRule
                    implicitWidth: 26
                    implicitHeight: 26
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.setAppRule(ruleRow.modelData, "", "")

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: removeRule.containsMouse ? Theme.glassTileHover : "transparent"
                    }

                    Icon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 15
                        color: Theme.foregroundDim
                    }
                }
            }
        }
    }
}
