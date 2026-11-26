import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common
import qs.services

// Alt+Tab window switcher: hold Alt, tap Tab to step through windows (in
// workspace order, then left to right within each; live previews), release
// Alt to switch.
//
//   Alt+Tab        open with the focused window selected / next one
//   Alt+Shift+Tab  previous one
//   release Alt    switch to the selected window
//   ← → / click    select (click switches)        Esc  cancel
//
// The strip only appears after `showDelay`, so a quick tap doesn't flash it
// (and, starting on the focused window, changes nothing).
//
// Release of Alt is caught two ways (either commits, once): by this overlay
// (it holds the keyboard while open) and by a Hyprland release bind
// (hypr/binds.lua) as a backup.
//
//   qs -c nyx ipc call alttab next | prev | commit | cancel
Scope {
    id: root

    property bool open: false // cycling (Alt held)
    property bool shown: false // strip visible (after the delay)
    property var windows: [] // HyprlandToplevels, in spatial order (see reader)
    property int index: 0
    property int pendingSteps: 0 // Tabs pressed before the list arrived
    property bool loading: false
    property bool commitPending: false // Alt released before the list arrived

    readonly property int showDelay: 150

    function step(delta) {
        if (!open) {
            open = true;
            pendingSteps = 0;
            commitPending = false;
            index = 0;
            windows = [];
            loading = true;
            reader.running = true;
            showTimer.restart();
            return;
        }
        if (loading) {
            pendingSteps += delta;
            return;
        }
        if (windows.length > 0)
            index = (index + delta + windows.length) % windows.length;
    }

    function commit() {
        if (!open)
            return;
        // Released before the window list arrived: switch once it's here
        // (with the Tabs pressed meanwhile), instead of dropping them.
        if (loading) {
            commitPending = true;
            shown = false;
            showTimer.stop();
            return;
        }
        const t = windows[index] ?? null;
        close();
        if (t) {
            focusLater.address = HyprDispatch.address(t);
            focusLater.restart();
        }
    }

    function close() {
        open = false;
        commitPending = false;
        shown = false;
        showTimer.stop();
    }

    // The window list, fresh from Hyprland, mapped to quickshell toplevels
    // for the live previews. focusHistoryID only marks the focused window
    // (the starting point); the order itself is spatial, on purpose.
    Process {
        id: reader
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                if (!root.open)
                    return;
                // Spatial order: workspace by workspace (1, 2, 3…, special
                // workspaces last), and within one, left to right / top to
                // bottom, like the overview.
                let clients = [];
                try {
                    const wsKey = c => (c.workspace?.id ?? 0) > 0 ? c.workspace.id : 100000 - (c.workspace?.id ?? 0);
                    clients = JSON.parse(text).filter(c => c.mapped && !c.hidden).sort((a, b) => (wsKey(a) - wsKey(b)) || (a.at[0] - b.at[0]) || (a.at[1] - b.at[1]));
                } catch (e) {}
                const byAddress = new Map(Hyprland.toplevels.values.map(t => [HyprDispatch.address(t), t]));
                const pairs = clients.map(c => ({
                            t: byAddress.get(c.address),
                            focused: c.focusHistoryID === 0
                        })).filter(p => p.t);
                root.windows = pairs.map(p => p.t);
                const n = root.windows.length;
                // Start on the focused window, then apply Tabs pressed while
                // the list was loading.
                const current = Math.max(0, pairs.findIndex(p => p.focused));
                root.index = n > 0 ? ((current + root.pendingSteps) % n + n) % n : 0;
                root.pendingSteps = 0;
                if (n === 0)
                    root.close();
                else if (root.commitPending)
                    root.commit();
            }
        }
    }

    Timer {
        id: showTimer
        interval: root.showDelay
        onTriggered: if (root.open)
            root.shown = true
    }

    // After the overlay lets go of the keyboard (Hyprland won't focus a
    // window while a layer holds it exclusively).
    Timer {
        id: focusLater
        property string address
        interval: 60
        onTriggered: Hyprland.dispatch(`hl.dsp.focus({ window = "address:${address}" })`)
    }

    IpcHandler {
        target: "alttab"

        function next(): void {
            root.step(1);
        }
        function prev(): void {
            root.step(-1);
        }
        function commit(): void {
            root.commit();
        }
        function cancel(): void {
            root.close();
        }
    }

    // Keybinds (hypr/binds.lua: hl.dsp.global("nyx:<name>")). The commit
    // bind is a release bind, so Hyprland sends it as a "released" event.
    GlobalShortcut {
        appid: "nyx"
        name: "alttab-next"
        description: "Alt-Tab: next window"
        onPressed: root.step(1)
    }
    GlobalShortcut {
        appid: "nyx"
        name: "alttab-prev"
        description: "Alt-Tab: previous window"
        onPressed: root.step(-1)
    }
    GlobalShortcut {
        appid: "nyx"
        name: "alttab-commit"
        description: "Alt-Tab: focus the selected window (on Alt release)"
        onReleased: root.commit()
    }

    // The window is only created while it's needed (LazyLoader), so a closed
    // overlay holds no items, images or textures.
    LazyLoader {
        active: root.open

        PanelWindow {
            id: win

            screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
            // Mapped as soon as Alt+Tab is pressed (to hold the keyboard and see
            // Alt's release), drawn only once `shown`.
            visible: root.open
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nyx-alttab"
            WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            color: "transparent"

            readonly property int cardW: 240
            readonly property int cardH: 190
            readonly property int maxW: (screen?.width ?? 1920) - 120
            implicitWidth: Math.max(cardW + 32, Math.min(maxW, root.windows.length * (cardW + 12) + 20))
            implicitHeight: cardH + 32
            // Click-through until it's drawn.
            mask: Region {
                item: root.shown ? panel : null
            }

            onVisibleChanged: if (visible)
                keys.forceActiveFocus()
            // Created already visible (LazyLoader): the handler above won't fire.
            Component.onCompleted: if (visible)
                keys.forceActiveFocus()

            Item {
                id: keys
                focus: true
                Keys.onReleased: event => {
                    if (event.key === Qt.Key_Alt)
                        root.commit();
                }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape)
                        root.close();
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        root.commit();
                    else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right)
                        root.step(1);
                    else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Left)
                        root.step(-1);
                    else
                        return;
                    event.accepted = true;
                }
            }

            Rectangle {
                id: panel
                anchors.fill: parent
                radius: 20
                color: Theme.background
                border.width: 1
                border.color: Theme.surfaceHigh
                opacity: root.shown ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.ms(100)
                    }
                }

                ListView {
                    id: strip
                    anchors.fill: parent
                    anchors.margins: 16
                    orientation: ListView.Horizontal
                    spacing: 12
                    clip: true
                    interactive: false
                    model: root.shown ? root.windows : []
                    currentIndex: root.index
                    highlightFollowsCurrentItem: false
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: MouseArea {
                        id: card
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === root.index
                        readonly property string appId: modelData?.wayland?.appId || modelData?.lastIpcObject?.class || ""
                        readonly property var entry: DesktopEntries.heuristicLookup(appId)

                        width: win.cardW
                        height: strip.height
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: root.index = index
                        onClicked: {
                            root.index = index;
                            root.commit();
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 14
                            color: card.selected ? Theme.surfaceHigh : "transparent"
                            border.width: card.selected ? 2 : 0
                            border.color: Theme.accent
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            // Live preview (app icon until the first frame).
                            ClippingRectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: Theme.surface

                                ScreencopyView {
                                    id: preview
                                    anchors.fill: parent
                                    captureSource: root.shown ? card.modelData?.wayland ?? null : null
                                    live: true
                                    paintCursor: false
                                    constraintSize: Qt.size(width, height)
                                }

                                IconImage {
                                    anchors.centerIn: parent
                                    visible: !preview.hasContent
                                    implicitSize: 48
                                    source: Quickshell.iconPath(card.entry?.icon || card.appId.toLowerCase(), true)
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                IconImage {
                                    implicitSize: 18
                                    source: Quickshell.iconPath(card.entry?.icon || card.appId.toLowerCase(), true)
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: card.modelData?.title || card.entry?.name || card.appId
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSize - 1
                                    font.weight: card.selected ? Font.DemiBold : Font.Normal
                                    color: card.selected ? Theme.foreground : Theme.foregroundDim
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
