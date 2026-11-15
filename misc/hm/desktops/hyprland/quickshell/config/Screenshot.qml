import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Screenshot tool (replaces the grim/slurp keybind mode).
//
// Opening freezes every monitor first (grim per output), then shows those
// frames as an overlay to select from, so the result is exactly what was on
// screen. Modes: region (drag), window (hover + click), screen (click).
// Actions: copy, save (~/Pictures/Screenshots, also copied), edit (satty).
// Cropping is done from the frozen frame at full resolution (ImageMagick).
//
//   qs -c nyx ipc call screenshot open      (region mode)
//   qs -c nyx ipc call screenshot window
//   qs -c nyx ipc call screenshot screen
//
// Keys: R/W/S switch mode · Enter copy · Ctrl+S save · E edit · Esc close
Scope {
    id: root

    readonly property string dir: `${Quickshell.env("XDG_RUNTIME_DIR")}/nyx-shot`
    readonly property string home: Quickshell.env("HOME")

    property bool active: false
    property bool capturing: false
    property string mode: "region" // "region" | "window" | "screen"
    property var monitors: ({}) // name -> { x, y, w, h (logical), scale, ws }
    property var clients: [] // { x, y, w, h (logical, global), ws, floating, order }
    property var selection: null // { screen, x, y, w, h } logical, screen-local
    property real stamp: 0 // cache-buster for the frozen images

    function open(m) {
        if (active || capturing)
            return;
        Ui.closeAll();
        Notifs.centerOpen = false;
        mode = m || "region";
        selection = null;
        capturing = true;
        capture.running = true;
    }

    function close() {
        active = false;
        selection = null;
    }

    function setMode(m) {
        mode = m;
        selection = null;
        if (m === "screen")
            selectScreen(Hyprland.focusedMonitor?.name);
    }

    function selectScreen(name) {
        const mon = monitors[name];
        if (mon)
            selection = {
                screen: name,
                x: 0,
                y: 0,
                w: mon.w,
                h: mon.h
            };
    }

    // Topmost window under a screen-local point, as a screen-local rect.
    function windowAt(name, lx, ly) {
        const mon = monitors[name];
        if (!mon)
            return null;
        const gx = lx + mon.x, gy = ly + mon.y;
        const hit = clients.filter(c => c.ws === mon.ws && gx >= c.x && gx < c.x + c.w && gy >= c.y && gy < c.y + c.h).sort((a, b) => (b.floating - a.floating) || (a.order - b.order))[0];
        if (!hit)
            return null;
        const x = Math.max(0, hit.x - mon.x), y = Math.max(0, hit.y - mon.y);
        return {
            screen: name,
            x: x,
            y: y,
            w: Math.min(mon.w, hit.x - mon.x + hit.w) - x,
            h: Math.min(mon.h, hit.y - mon.y + hit.h) - y
        };
    }

    function finish(action) {
        const s = selection;
        const mon = s ? monitors[s.screen] : null;
        if (!mon || s.w < 2 || s.h < 2)
            return;
        const px = v => Math.round(v * mon.scale);
        const geometry = `${px(s.w)}x${px(s.h)}+${px(s.x)}+${px(s.y)}`;
        const ts = Qt.formatDateTime(new Date(), "yyyyMMdd_HH'h'mm'm'ss's'");
        const dest = `${home}/Pictures/Screenshots/${ts}_${mode}.png`;
        close();
        Quickshell.execDetached(["sh", "-c", finishScript, "sh", action, `${dir}/${s.screen}.png`, geometry, `${dir}/${ts}.png`, dest, dest.replace(home, "~")]);
    }

    // $1 action  $2 frozen frame  $3 crop geometry  $4 temp output  $5 dest  $6 dest for display
    readonly property string finishScript: `
        action=$1 src=$2 geo=$3 out=$4 dest=$5 shown=$6
        magick "$src" -crop "$geo" +repage "$out" || exit 1
        notify() {
            busctl --user call org.freedesktop.Notifications /org/freedesktop/Notifications \
                org.freedesktop.Notifications Notify susssasa{sv}i \
                Screenshot 0 "$1" "$2" "$3" 0 1 urgency y 0 -1 >/dev/null
        }
        case "$action" in
            copy)
                wl-copy -t image/png < "$out"
                notify "$out" "Screenshot copied" "Copied to the clipboard." ;;
            save)
                mkdir -p "$(dirname "$dest")"
                cp "$out" "$dest"
                wl-copy -t image/png < "$dest"
                notify "$dest" "Screenshot saved" "$shown (also copied)" ;;
            edit)
                mkdir -p "$(dirname "$dest")"
                satty --filename "$out" --output-filename "$dest" \
                    --copy-command "wl-copy -t image/png" --early-exit ;;
        esac
    `

    // Freeze all outputs, then read monitor + window geometry.
    Process {
        id: capture
        command: ["sh", "-c", `
            dir="$1"
            mkdir -p "$dir"
            find "$dir" -name '*.png' -mmin +60 -delete 2>/dev/null
            mons=$(hyprctl monitors -j)
            for m in $(printf '%s' "$mons" | jq -r '.[].name'); do
                grim -o "$m" "$dir/$m.png" &
            done
            wait
            printf '%s' "$mons" | jq -c .
            hyprctl clients -j | jq -c .
        `, "sh", root.dir]

        stdout: StdioCollector {
            onStreamFinished: {
                root.capturing = false;
                try {
                    const lines = text.trim().split("\n");
                    const mons = {};
                    for (const m of JSON.parse(lines[0]))
                        mons[m.name] = {
                            x: m.x,
                            y: m.y,
                            w: m.width / m.scale,
                            h: m.height / m.scale,
                            scale: m.scale,
                            ws: m.activeWorkspace.id
                        };
                    root.monitors = mons;
                    root.clients = JSON.parse(lines[1]).filter(c => c.mapped && !c.hidden).map(c => ({
                                x: c.at[0],
                                y: c.at[1],
                                w: c.size[0],
                                h: c.size[1],
                                ws: c.workspace.id,
                                floating: c.floating ? 1 : 0,
                                order: c.focusHistoryID
                            }));
                } catch (e) {
                    console.warn("screenshot: capture failed", e);
                    return;
                }
                root.stamp = Date.now();
                root.active = true;
                if (root.mode === "screen")
                    root.selectScreen(Hyprland.focusedMonitor?.name);
            }
        }
    }

    IpcHandler {
        target: "screenshot"

        function open(): void {
            root.open("region");
        }
        function region(): void {
            root.open("region");
        }
        function window(): void {
            root.open("window");
        }
        function screen(): void {
            root.open("screen");
        }
    }

    // ---- one overlay per monitor ----
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win

            required property var modelData
            readonly property string name: modelData.name
            readonly property bool focusedScreen: Hyprland.focusedMonitor?.name === name

            // Selection on this screen, or the live preview while choosing.
            readonly property var sel: root.selection?.screen === name ? root.selection : null
            property var preview: null
            readonly property var shown: sel ?? preview

            screen: modelData
            visible: root.active

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore // cover the bar too
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "nyx-screenshot"
            WlrLayershell.keyboardFocus: root.active && focusedScreen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            color: "black"

            onVisibleChanged: {
                preview = null;
                if (visible && focusedScreen)
                    keys.forceActiveFocus();
            }

            // Frozen frame.
            Image {
                anchors.fill: parent
                source: root.active ? `file://${root.dir}/${win.name}.png?${root.stamp}` : ""
                cache: false
                smooth: true
            }

            // Dim everything except the selection/preview.
            Item {
                anchors.fill: parent

                readonly property real sx: win.shown ? win.shown.x : 0
                readonly property real sy: win.shown ? win.shown.y : 0
                readonly property real sw: win.shown ? win.shown.w : 0
                readonly property real sh: win.shown ? win.shown.h : 0
                readonly property color dim: Qt.rgba(0, 0, 0, 0.45)

                Rectangle {
                    x: 0
                    y: 0
                    width: parent.width
                    height: parent.sy
                    color: parent.dim
                }
                Rectangle {
                    x: 0
                    y: parent.sy + parent.sh
                    width: parent.width
                    height: parent.height - y
                    color: parent.dim
                }
                Rectangle {
                    x: 0
                    y: parent.sy
                    width: parent.sx
                    height: parent.sh
                    color: parent.dim
                }
                Rectangle {
                    x: parent.sx + parent.sw
                    y: parent.sy
                    width: parent.width - x
                    height: parent.sh
                    color: parent.dim
                }

                // Selection outline + size.
                Rectangle {
                    visible: !!win.shown
                    x: parent.sx
                    y: parent.sy
                    width: parent.sw
                    height: parent.sh
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.accent

                    Rectangle {
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 6
                        anchors.left: parent.left
                        visible: parent.width > 40 && parent.y > 30
                        width: sizeText.implicitWidth + 12
                        height: 20
                        radius: 6
                        color: Theme.background

                        Text {
                            id: sizeText
                            anchors.centerIn: parent
                            text: win.shown ? `${Math.round(win.shown.w)} × ${Math.round(win.shown.h)}` : ""
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.foreground
                        }
                    }
                }
            }

            // Pointer: drag a region, or pick a window / the screen.
            MouseArea {
                id: picker
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.CrossCursor

                property point start
                property bool dragging: false

                function rectTo(mx, my) {
                    const x = Math.min(start.x, mx), y = Math.min(start.y, my);
                    return {
                        screen: win.name,
                        x: x,
                        y: y,
                        w: Math.abs(mx - start.x),
                        h: Math.abs(my - start.y)
                    };
                }

                onPressed: mouse => {
                    if (root.mode !== "region")
                        return;
                    start = Qt.point(mouse.x, mouse.y);
                    dragging = true;
                    root.selection = null;
                }

                onPositionChanged: mouse => {
                    if (root.mode === "region")
                        win.preview = dragging ? rectTo(mouse.x, mouse.y) : null;
                    else if (root.mode === "window")
                        win.preview = root.windowAt(win.name, mouse.x, mouse.y);
                    else
                        win.preview = root.monitors[win.name] ? {
                            screen: win.name,
                            x: 0,
                            y: 0,
                            w: win.width,
                            h: win.height
                        } : null;
                }

                onReleased: mouse => {
                    if (root.mode !== "region" || !dragging)
                        return;
                    dragging = false;
                    const r = rectTo(mouse.x, mouse.y);
                    win.preview = null;
                    if (r.w > 3 && r.h > 3)
                        root.selection = r;
                }

                onClicked: mouse => {
                    if (root.mode === "window") {
                        const w = root.windowAt(win.name, mouse.x, mouse.y);
                        if (w)
                            root.selection = w;
                    } else if (root.mode === "screen") {
                        root.selectScreen(win.name);
                    }
                }

                onExited: if (!dragging)
                    win.preview = null
            }

            // Keyboard shortcuts.
            Item {
                id: keys
                focus: true
                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    if (event.key === Qt.Key_Escape)
                        root.close();
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        root.finish("copy");
                    else if (ctrl && event.key === Qt.Key_S)
                        root.finish("save");
                    else if (event.key === Qt.Key_E)
                        root.finish("edit");
                    else if (event.key === Qt.Key_R)
                        root.setMode("region");
                    else if (event.key === Qt.Key_W)
                        root.setMode("window");
                    else if (event.key === Qt.Key_S)
                        root.setMode("screen");
                    else
                        return;
                    event.accepted = true;
                }
            }

            // ---- toolbar ----
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 36
                width: toolbar.implicitWidth + 16
                height: 52
                radius: height / 2
                color: Theme.background
                border.width: 1
                border.color: Theme.surfaceHigh

                RowLayout {
                    id: toolbar
                    anchors.centerIn: parent
                    spacing: 4

                    ShotButton {
                        icon: "crop"
                        label: "Region"
                        selected: root.mode === "region"
                        onClicked: root.setMode("region")
                    }
                    ShotButton {
                        icon: "select_window"
                        label: "Window"
                        selected: root.mode === "window"
                        onClicked: root.setMode("window")
                    }
                    ShotButton {
                        icon: "fullscreen"
                        label: "Screen"
                        selected: root.mode === "screen"
                        onClicked: root.setMode("screen")
                    }

                    Rectangle {
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6
                        implicitWidth: 1
                        implicitHeight: 24
                        color: Theme.surfaceHigh
                    }

                    // Hint until something is selected, then the actions.
                    Text {
                        visible: !root.selection
                        Layout.leftMargin: 6
                        Layout.rightMargin: 10
                        text: root.mode === "region" ? "Drag to select an area" : root.mode === "window" ? "Click a window" : "Click a screen"
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        color: Theme.foregroundDim
                    }

                    ShotButton {
                        visible: !!root.selection
                        icon: "content_copy"
                        label: "Copy"
                        onClicked: root.finish("copy")
                    }
                    ShotButton {
                        visible: !!root.selection
                        icon: "save"
                        label: "Save"
                        onClicked: root.finish("save")
                    }
                    ShotButton {
                        visible: !!root.selection
                        icon: "edit"
                        label: "Edit"
                        onClicked: root.finish("edit")
                    }

                    ShotButton {
                        icon: "close"
                        label: ""
                        onClicked: root.close()
                    }
                }
            }
        }
    }
}
