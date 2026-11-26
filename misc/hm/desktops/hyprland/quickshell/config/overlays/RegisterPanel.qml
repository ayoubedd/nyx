import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services

// Vim-style register panel (services/Registers.qml), Super+' :
//
//   a-z        put that register on the clipboard     (vim "ap)
//   Shift+a-z  store the current clipboard in it       (vim "ay)
//   Ctrl+a-z   clear it
//   1-9        put one of the 9 latest clipboard entries (vim's "1-"9)
//   Esc        close
//
// Super+Shift+' opens it in store mode: a plain letter stores.
// Putting only sets the clipboard; nothing is typed.
//
//   qs -c nyx ipc call registerpanel open
//   qs -c nyx ipc call registerpanel storeMode
Scope {
    id: root

    property bool open: false
    property bool storeMode: false

    function show(store) {
        Ui.closeAll();
        Notifs.centerOpen = false;
        storeMode = store;
        Registers.lastError = "";
        Registers.refresh();
        Clipboard.refresh();
        open = true;
    }

    function close() {
        open = false;
    }

    function put(r) {
        Registers.put(r);
        close();
    }

    function store(r) {
        Registers.store(r);
        close();
    }

    function putRecent(i) {
        const e = Clipboard.entries[i];
        if (!e)
            return;
        Clipboard.use(e, "", false);
        close();
    }

    readonly property var recent: Clipboard.entries.slice(0, 9)
    readonly property var empty: Registers.names.split("").filter(r => !Registers.registers[r])

    IpcHandler {
        target: "registerpanel"

        function open(): void {
            root.open ? root.close() : root.show(false);
        }
        function storeMode(): void {
            root.show(true);
        }
    }

    // Keybinds (hypr/binds.lua: hl.dsp.global("nyx:<name>")).
    GlobalShortcut {
        appid: "nyx"
        name: "registers"
        description: "Toggle the clipboard registers panel"
        onPressed: root.open ? root.close() : root.show(false)
    }
    GlobalShortcut {
        appid: "nyx"
        name: "registers-store"
        description: "Store the clipboard in a register"
        onPressed: root.show(true)
    }

    property bool windowVisible: false

    // The window is only created while it's needed (LazyLoader), so a closed
    // overlay holds no items, images or textures.
    // It stays loaded until its fade-out has finished.
    LazyLoader {
        active: root.open || root.windowVisible

        PanelWindow {
            id: win

            // Starts false and follows root.open from the next tick, so the
            // open animation runs on a freshly created window.
            property bool presented: false
            Component.onCompleted: {
                root.windowVisible = visible;
                if (visible)
                    keys.forceActiveFocus();
                Qt.callLater(() => presented = Qt.binding(() => root.open));
            }

            screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
            visible: root.open || card.opacity > 0
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nyx-registers"
            WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            color: "transparent"
            implicitWidth: 560
            implicitHeight: card.implicitHeight

            HyprlandFocusGrab {
                windows: [win]
                active: root.open
                onCleared: root.close()
            }

            onVisibleChanged: {
                root.windowVisible = visible;
                if (visible)
                    keys.forceActiveFocus();
            }

            Rectangle {
                id: card
                width: parent.width
                implicitHeight: body.implicitHeight + 32
                radius: 18
                color: Theme.background
                border.width: 1
                border.color: Theme.surfaceHigh
                opacity: win.presented ? 1 : 0
                scale: win.presented ? 1 : 0.97

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.ms(140)
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.ms(160)
                        easing.type: Easing.OutCubic
                    }
                }

                Item {
                    id: keys
                    focus: true
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.close();
                            event.accepted = true;
                            return;
                        }
                        const t = event.text;
                        if (!t || t.length !== 1)
                            return;
                        const ctrl = event.modifiers & Qt.ControlModifier;
                        // Ctrl+letter gives a control character as text; use the key.
                        if (ctrl && event.key >= Qt.Key_A && event.key <= Qt.Key_Z) {
                            Registers.clear(String.fromCharCode(event.key).toLowerCase());
                        } else if (t >= "1" && t <= "9") {
                            root.putRecent(Number(t) - 1);
                        } else if (t >= "A" && t <= "Z") {
                            root.store(t.toLowerCase());
                        } else if (t >= "a" && t <= "z") {
                            if (root.storeMode)
                                root.store(t);
                            else
                                root.put(t);
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    id: body
                    x: 16
                    y: 16
                    width: parent.width - 32
                    spacing: 12

                    // Header.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            implicitWidth: 34
                            implicitHeight: 34
                            radius: 10
                            color: root.storeMode ? Theme.accent : Theme.surfaceHigh

                            Text {
                                anchors.centerIn: parent
                                text: "\""
                                font.family: "monospace"
                                font.pixelSize: 20
                                font.weight: Font.Bold
                                color: root.storeMode ? Theme.background : Theme.foreground
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: root.storeMode ? "Store clipboard in register…" : "Registers"
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize + 1
                                font.weight: Font.DemiBold
                                color: Theme.foreground
                            }

                            Text {
                                Layout.fillWidth: true
                                text: Registers.lastError || (root.storeMode ? "Press a letter to store the current clipboard there · Esc cancel" : "a–z put on clipboard · Shift+a–z store clipboard · Ctrl+a–z clear · Esc close")
                                elide: Text.ElideRight
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize - 3
                                color: Registers.lastError ? Theme.urgent : Theme.foregroundDim
                            }
                        }
                    }

                    // ---- named registers ----
                    Text {
                        text: "Named"
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        font.weight: Font.DemiBold
                        color: Theme.foregroundDim
                    }

                    Text {
                        visible: Registers.filled.length === 0
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: "No registers yet. Copy something, then press Shift + a letter to keep it in that register."
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Repeater {
                            model: Registers.filled

                            RegisterRow {
                                required property var modelData
                                Layout.fillWidth: true
                                key: modelData.name
                                preview: modelData.isImage ? `Image · ${modelData.type.replace("image/", "").toUpperCase()} · ${Registers.sizeText(modelData.size)}` : modelData.preview || "(empty text)"
                                dim: modelData.isImage
                                // Click: put (or store, in store mode). Right-click: clear.
                                onLeftClicked: root.storeMode ? root.store(modelData.name) : root.put(modelData.name)
                                onRightClicked: Registers.clear(modelData.name)
                            }
                        }
                    }

                    // Free letters, compact.
                    Text {
                        visible: Registers.filled.length > 0 && root.empty.length > 0
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: `Free: ${root.empty.join(" ")}`
                        font.family: "monospace"
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }

                    // ---- recent clipboard (1-9) ----
                    Text {
                        visible: !root.storeMode && root.recent.length > 0
                        text: "Recent clipboard"
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        font.weight: Font.DemiBold
                        color: Theme.foregroundDim
                    }

                    ColumnLayout {
                        visible: !root.storeMode
                        Layout.fillWidth: true
                        spacing: 2

                        Repeater {
                            model: root.recent

                            RegisterRow {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                key: String(index + 1)
                                preview: modelData.isImage ? `Image · ${modelData.imageInfo}` : modelData.preview.replace(/\s+/g, " ").trim()
                                dim: true
                                onLeftClicked: root.putRecent(index)
                            }
                        }
                    }
                }
            }
        }
    }

    // One register: [a]  preview text…
    component RegisterRow: MouseArea {
        id: row

        property string key
        property string preview
        property bool dim: false
        signal leftClicked
        signal rightClicked

        implicitHeight: 30
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                row.rightClicked();
            else
                row.leftClicked();
        }

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: row.containsMouse ? Theme.surface : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 8
            spacing: 10

            Rectangle {
                implicitWidth: 24
                implicitHeight: 22
                radius: 6
                color: Theme.surfaceHigh

                Text {
                    anchors.centerIn: parent
                    text: row.key
                    font.family: "monospace"
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.Bold
                    color: Theme.foreground
                }
            }

            Text {
                Layout.fillWidth: true
                text: row.preview
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                font.family: row.dim ? Theme.font : "monospace"
                font.pixelSize: Theme.fontSize - 2
                color: row.dim ? Theme.foregroundDim : Theme.foreground
            }
        }
    }
}
