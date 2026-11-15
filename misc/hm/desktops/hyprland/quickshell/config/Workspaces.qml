import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland

// Workspace indicators. 1-5 always shown, higher ones only while they exist.
//   empty      small dim dot
//   occupied   pill with the icons of the apps open on it (up to 3, then +N)
//   focused    accent pill with the workspace number + its app icons
//   urgent     pink
Row {
    id: root
    spacing: 6

    readonly property int persistent: 5
    readonly property int maxIcons: 3
    readonly property var ids: {
        const set = new Set(Array.from({ length: persistent }, (_, i) => i + 1));
        for (const ws of Hyprland.workspaces.values)
            if (ws.id > 0)
                set.add(ws.id);
        return [...set].sort((a, b) => a - b);
    }

    function workspace(id) {
        return Hyprland.workspaces.values.find(ws => ws.id === id) ?? null;
    }

    // App ID of a window: Wayland app_id, else Hyprland's class.
    function appIdOf(toplevel) {
        return toplevel?.wayland?.appId || toplevel?.lastIpcObject?.class || "";
    }

    // Icon via the app's .desktop entry, else the app ID itself (icon theme).
    function iconFor(appId) {
        const entry = DesktopEntries.heuristicLookup(appId);
        return Quickshell.iconPath(entry?.icon || appId, true) || Quickshell.iconPath(appId.toLowerCase(), true);
    }

    Repeater {
        model: root.ids

        MouseArea {
            id: cell
            required property int modelData
            readonly property var ws: root.workspace(modelData)
            readonly property bool focused: Hyprland.focusedWorkspace?.id === modelData
            readonly property bool urgent: ws?.urgent ?? false

            // Distinct apps on this workspace, in window order.
            readonly property var apps: {
                const seen = [];
                for (const t of ws?.toplevels.values ?? []) {
                    const id = root.appIdOf(t);
                    if (id && !seen.includes(id))
                        seen.push(id);
                }
                return seen;
            }
            readonly property bool occupied: (ws?.toplevels.values.length ?? 0) > 0
            readonly property bool isPill: focused || occupied

            implicitWidth: pill.width
            implicitHeight: 22
            cursorShape: Qt.PointingHandCursor
            onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${modelData} })`)
            hoverEnabled: true

            // "Workspace 2 · LibreWolf, kitty"
            Tooltip {
                target: cell
                text: {
                    const names = cell.apps.map(id => DesktopEntries.heuristicLookup(id)?.name || id);
                    return `Workspace ${cell.modelData} · ${names.length ? names.join(", ") : "empty"}`;
                }
                show: cell.containsMouse && !cell.pressed
            }

            Rectangle {
                id: pill
                anchors.verticalCenter: parent.verticalCenter
                width: cell.isPill ? Math.max(cell.focused ? 26 : 22, content.implicitWidth + 12) : 8
                height: cell.isPill ? 20 : 8
                radius: height / 2
                clip: true
                color: cell.urgent ? Theme.urgent : cell.focused ? Theme.accent : cell.occupied ? Theme.surfaceHigh : Theme.muted

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    NumberAnimation {
                        duration: Theme.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animDuration
                    }
                }

                Row {
                    id: content
                    anchors.centerIn: parent
                    spacing: 4
                    opacity: cell.isPill ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Theme.animDuration
                        }
                    }

                    // Number only on the focused workspace.
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: cell.focused
                        text: cell.modelData
                        font.family: Theme.font
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: Theme.background
                    }

                    Repeater {
                        model: cell.apps.slice(0, root.maxIcons)

                        Item {
                            required property string modelData
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            opacity: cell.focused ? 1 : 0.8

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                source: root.iconFor(parent.modelData)
                                visible: status === Image.Ready
                            }

                            Icon {
                                anchors.centerIn: parent
                                visible: !appIcon.visible
                                name: "apps"
                                size: 13
                                color: cell.focused ? Theme.background : Theme.foreground
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: cell.apps.length > root.maxIcons
                        text: `+${cell.apps.length - root.maxIcons}`
                        font.family: Theme.font
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: cell.focused ? Theme.background : Theme.foregroundDim
                    }
                }
            }
        }
    }

    WheelHandler {
        onWheel: event => Hyprland.dispatch(`hl.dsp.focus({ workspace = "e${event.angleDelta.y > 0 ? "-" : "+"}1" })`)
    }
}
