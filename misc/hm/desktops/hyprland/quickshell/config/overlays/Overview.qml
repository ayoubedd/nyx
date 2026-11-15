import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.common
import qs.services
import qs.bar

// Workspace overview: full-screen grid of the workspaces that have windows,
// with live window previews (ScreencopyView per window), on the focused
// monitor. A trailing "+" tile stands for the first free workspace.
//
//   click a workspace   go there
//   click a window      focus it
//   drag a window       move it to another workspace / onto "+" (stays open)
//   arrows / Enter      select / go;  1-9 jump;  Esc close
//
//   qs -c nyx ipc call overview toggle      (Super+Tab)
//
// Previews only capture while the overview is open.
Scope {
    id: root

    property bool open: false
    property int selected: 1

    // Workspaces with windows (empty ones aren't shown).
    readonly property var wsIds: Hyprland.workspaces.values.filter(ws => ws.id > 0 && ws.toplevels.values.length > 0).map(ws => ws.id).sort((a, b) => a - b)

    // First workspace id with no windows, for the "+" tile.
    readonly property int freeId: {
        let id = 1;
        while (wsIds.includes(id))
            id++;
        return id;
    }

    function toggle() {
        if (open)
            close();
        else
            show();
    }

    function show() {
        Ui.closeAll();
        Notifs.centerOpen = false;
        Hyprland.refreshToplevels();
        Hyprland.refreshMonitors();
        Hyprland.refreshWorkspaces();
        Wallpaper.refresh();
        const cur = Hyprland.focusedWorkspace?.id ?? 0;
        selected = wsIds.includes(cur) ? cur : (wsIds[0] ?? freeId);
        // Fresh state (a previous close may have frozen things).
        query = "";
        selectedWindow = null;
        previewOrder = null;
        frozenIds = null;
        pending = null;
        animateMoves = true;
        open = true;
    }

    // Freeze the grid while it fades out: switching workspace right away can
    // drop an empty one from the list, which would otherwise reflow (and
    // slide) the tiles mid-fade. Reset once the window is hidden.
    function close() {
        if (!open)
            return;
        frozenIds = displayIds.slice();
        previewOrder = null;
        animateMoves = false;
        settle.stop();
        open = false;
    }

    function address(t) {
        const a = t?.address ?? "";
        return a.startsWith("0x") ? a : `0x${a}`;
    }

    function goWorkspace(id) {
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${id} })`);
        close();
    }

    // While the overview is open it holds exclusive keyboard focus, and
    // Hyprland won't give a window keyboard focus then (on unmap, focus falls
    // back to the previous window). So close first, then focus once the
    // overlay has released the keyboard.
    function focusWindow(t) {
        if (!t)
            return;
        focusAfterClose.target = t;
        close();
        focusAfterClose.restart();
    }

    Timer {
        id: focusAfterClose
        property var target: null
        interval: 80
        onTriggered: {
            if (target)
                Hyprland.dispatch(`hl.dsp.focus({ window = "address:${root.address(target)}" })`);
            target = null;
        }
    }

    // ---- search + keyboard window selection ------------------------------
    // Typing filters windows by title / app (non-matches fade); Tab cycles
    // the matching windows; Enter focuses the selected one; Delete closes it.
    property string query: ""
    property var selectedWindow: null

    function matches(t) {
        if (!query)
            return true;
        const hay = `${t?.title ?? ""} ${t?.lastIpcObject?.class ?? ""} ${t?.wayland?.appId ?? ""}`.toLowerCase();
        return query.toLowerCase().split(/\s+/).every(word => hay.includes(word));
    }

    // All shown windows in grid order: tile by tile, left-to-right inside.
    // (Array.from + reduce: the list types here don't all support flatMap.)
    readonly property var orderedWindows: Array.from(displayIds).reduce((all, id) => all.concat(Array.from(windowsFor(id)).sort((a, b) => (a.lastIpcObject.at[0] - b.lastIpcObject.at[0]) || (a.lastIpcObject.at[1] - b.lastIpcObject.at[1]))), [])
    readonly property var matchingWindows: orderedWindows.filter(t => matches(t))

    function selectWindow(t) {
        selectedWindow = t;
        if (t?.workspace?.id)
            selected = t.workspace.id;
    }

    function cycleWindow(step) {
        const list = matchingWindows;
        if (list.length === 0)
            return;
        const i = list.indexOf(selectedWindow);
        selectWindow(list[i < 0 ? (step > 0 ? 0 : list.length - 1) : (i + step + list.length) % list.length]);
    }

    // Close a window (graceful, like the app's own close): focus it, close the
    // active window, then return focus to whatever had it (unless that was the
    // closed one). Through the no-warp path so the cursor stays put.
    function closeWindow(t) {
        if (!t)
            return;
        const focused = Hyprland.activeToplevel;
        const dispatches = [`hl.dsp.focus({ window = "address:${address(t)}" })`, `hl.dsp.window.close()`];
        if (focused && focused !== t)
            dispatches.push(`hl.dsp.focus({ window = "address:${address(focused)}" })`);
        if (selectedWindow === t)
            selectedWindow = null;
        dispatchWithoutWarps(dispatches);
        refreshLater.restart();
    }

    // New query: select the first match (type + Enter jumps to it).
    onQueryChanged: selectWindow(query ? (matchingWindows[0] ?? null) : null)

    // Insertion point shown while dragging a window over another workspace:
    // { ws, index, x } (x in that tile's strip content coordinates).
    property var insertHint: null

    // Move a window to workspace `id` at column position `index` (0 = first).
    // Hyprland appends moved windows as the last column, so after the move,
    // focus it and swap it left until it sits at `index`; then refocus the
    // window that was focused before.
    function moveWindow(t, id, index) {
        const from = t.workspace?.id;
        const targetCount = windowsOn(id).length; // columns before the move
        const incoming = {};
        incoming[from] = windowsOn(from).filter(w => w !== t);
        incoming[id] = [...windowsOn(id), t];
        stage(incoming, [...new Set([...wsIds, id])]);

        const focused = Hyprland.activeToplevel;
        const dispatches = [`hl.dsp.window.move({ workspace = ${id}, window = "address:${address(t)}" })`];
        const shifts = Math.max(0, targetCount - (index ?? targetCount));
        if (shifts > 0) {
            dispatches.push(`hl.dsp.focus({ window = "address:${address(t)}" })`);
            for (let i = 0; i < shifts; i++)
                dispatches.push(`hl.dsp.window.swap({ direction = "l" })`);
            if (focused && focused !== t)
                dispatches.push(`hl.dsp.focus({ window = "address:${address(focused)}" })`);
        }
        dispatchWithoutWarps(dispatches);
        refreshLater.restart();
    }

    // Reorder inside a workspace: swap two windows (in the scrolling layout,
    // their columns). Hyprland only swaps the *focused* window with a target,
    // so: focus a, swap with b, then refocus whatever was focused before.
    property var swapTarget: null // window under the cursor while dragging

    function swapWindows(a, b) {
        if (!a || !b || a === b)
            return;
        startGlide();
        const focused = Hyprland.activeToplevel ?? a;
        dispatchWithoutWarps([`hl.dsp.focus({ window = "address:${address(a)}" })`, `hl.dsp.window.swap({ target = "address:${address(b)}" })`, `hl.dsp.focus({ window = "address:${address(focused)}" })`]);
        refreshLater.restart();
    }

    // Run Hyprland dispatches in order with cursor warping off, so moving /
    // refocusing windows doesn't yank the mouse pointer to them. One
    // sequential script, so the option change can't race the dispatches; the
    // user's own cursor:no_warps value is restored afterwards.
    function dispatchWithoutWarps(dispatches) {
        if (dispatches.length > 0)
            Quickshell.execDetached(["sh", "-c", noWarpScript, "sh", ...dispatches]);
    }

    readonly property string noWarpScript: `
        orig=$(hyprctl -j getoption cursor:no_warps | jq -r 'if has("bool") then (if .bool then 1 else 0 end) else (.int // 0) end')
        hyprctl eval 'hl.config({ cursor = { no_warps = true } })' >/dev/null
        for d in "$@"; do
            hyprctl dispatch "$d" >/dev/null
        done
        sleep 0.3
        if [ "$orig" = 1 ]; then v=true; else v=false; fi
        hyprctl eval "hl.config({ cursor = { no_warps = $v } })" >/dev/null
    `

    // While a workspace is dragged, the grid shows the order it would end up
    // in (tiles slide out of the way); null = the real, sorted order.
    property var previewOrder: null
    property bool animateMoves: true

    // Right after a drop, until Hyprland has applied the moves: the tile set
    // is frozen (workspaces may be briefly empty mid-move) and each tile shows
    // the windows headed to it (same objects, so previews keep running).
    property var frozenIds: null
    property var pending: null // wsId -> [toplevels]

    readonly property var displayIds: previewOrder ?? frozenIds ?? wsIds

    function windowsFor(id) {
        return pending?.[id] ?? windowsOn(id);
    }

    // Window previews glide to new positions only right after a move/swap
    // (while Hyprland re-tiles). Otherwise geometry changes apply instantly,
    // so on open they render at their final size instead of growing into it.
    property bool glide: false

    function startGlide() {
        glide = true;
        glideTimer.restart();
    }

    Timer {
        id: glideTimer
        interval: 700
        onTriggered: root.glide = false
    }

    // Show a move's result right away (until Hyprland catches up): `incoming`
    // maps wsId -> the windows that will be there; tiles = `ids`.
    function stage(incoming, ids) {
        startGlide();
        pending = incoming;
        frozenIds = ids.filter(id => (incoming[id] ?? windowsOn(id)).length > 0).sort((a, b) => a - b);
        settle.restart();
    }

    // Commit a previewed order: the workspace shown at position i gets
    // workspace number wsIds[i] (numbers stay sorted, contents move).
    function applyOrder(order) {
        const ids = wsIds.slice();
        const mapping = {};
        order.forEach((src, i) => mapping[src] = ids[i]);
        moveContents(mapping);
    }

    // Move every window of each source workspace to its target, by address
    // (so moves can't collide), then give focus back to the focused window.
    function moveContents(mapping) {
        const moves = [];
        for (const [src, dst] of Object.entries(mapping))
            if (Number(src) !== dst)
                for (const t of Hyprland.toplevels.values.filter(t => t.workspace?.id === Number(src)))
                    moves.push([t, dst]);
        if (moves.length === 0)
            return;
        const focused = Hyprland.activeToplevel;
        const dispatches = moves.map(([t, dst]) => `hl.dsp.window.move({ workspace = ${dst}, window = "address:${address(t)}" })`);
        if (focused)
            dispatches.push(`hl.dsp.focus({ window = "address:${address(focused)}" })`);
        dispatchWithoutWarps(dispatches);
        refreshLater.restart();
    }

    // Drop a reordered preview: snap straight to the final layout (no slide),
    // show each tile's incoming windows right away, then move them for real.
    function commitOrder(order) {
        startGlide();
        const ids = wsIds.slice();
        const incoming = {};
        order.forEach((src, i) => incoming[ids[i]] = windowsOn(src));
        frozenIds = ids;
        pending = incoming;
        animateMoves = false;
        previewOrder = null;
        // Re-enable after the grid has re-laid out (Qt.callLater can run
        // before that, which would animate the snap).
        reenableMoves.restart();
        applyOrder(order);
        settle.restart();
    }

    Timer {
        id: reenableMoves
        interval: 80
        onTriggered: root.animateMoves = true
    }

    // Once Hyprland has applied the moves, tiles go back to live window lists
    // (the same windows, so nothing visibly changes).
    Timer {
        id: settle
        interval: 450
        onTriggered: {
            root.pending = null;
            root.frozenIds = null;
        }
    }

    // Windows on a workspace, bottom to top (tiled first, then floating,
    // most recently focused last).
    function windowsOn(id) {
        return Hyprland.toplevels.values.filter(t => t.workspace?.id === id && t.lastIpcObject?.at).sort((a, b) => ((a.lastIpcObject.floating ? 1 : 0) - (b.lastIpcObject.floating ? 1 : 0)) || ((b.lastIpcObject.focusHistoryID ?? 0) - (a.lastIpcObject.focusHistoryID ?? 0)));
    }

    // Area covered by a workspace's windows, in monitor-local logical px,
    // always including the screen itself. With the scrolling layout, columns
    // off to the side sit outside 0..width.
    function extentOf(id) {
        const mon = Hyprland.focusedMonitor;
        let minX = 0, minY = 0;
        let maxX = mon ? mon.width / mon.scale : 1, maxY = mon ? mon.height / mon.scale : 1;
        for (const t of windowsFor(id)) {
            const m = monitorOf(t);
            const x = t.lastIpcObject.at[0] - (m?.x ?? 0), y = t.lastIpcObject.at[1] - (m?.y ?? 0);
            minX = Math.min(minX, x);
            minY = Math.min(minY, y);
            maxX = Math.max(maxX, x + t.lastIpcObject.size[0]);
            maxY = Math.max(maxY, y + t.lastIpcObject.size[1]);
        }
        return {
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY
        };
    }

    function monitorOf(t) {
        const id = t?.lastIpcObject?.monitor;
        return Hyprland.monitors.values.find(m => m.id === id) ?? Hyprland.focusedMonitor;
    }

    function iconFor(t) {
        const id = t?.wayland?.appId || t?.lastIpcObject?.class || "";
        if (!id)
            return "";
        const entry = DesktopEntries.heuristicLookup(id);
        return Quickshell.iconPath(entry?.icon || id, true);
    }

    Timer {
        id: refreshLater
        interval: 150
        onTriggered: {
            Hyprland.refreshToplevels();
            Hyprland.refreshWorkspaces();
        }
    }

    IpcHandler {
        target: "overview"

        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.show();
        }
        function close(): void {
            root.close();
        }
    }

    PanelWindow {
        id: win

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.open || backdrop.opacity > 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nyx-overview"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                keys.forceActiveFocus();
            } else {
                root.frozenIds = null;
                root.pending = null;
                root.animateMoves = true;
            }
        }

        // Grid geometry (logical px). Tiles use the focused monitor's aspect;
        // one extra cell for the "+" tile.
        readonly property var mon: Hyprland.focusedMonitor
        readonly property real monW: mon ? mon.width / mon.scale : width
        readonly property real monH: mon ? mon.height / mon.scale : height
        // Shown tiles (frozen while closing) + the "+" tile.
        readonly property int count: root.displayIds.length + 1
        readonly property int cols: count <= 4 ? count : Math.ceil(count / 2)
        readonly property int rows: Math.ceil(count / cols)
        readonly property real gap: 24
        readonly property real tileW: Math.min((width * 0.86 - gap * (cols - 1)) / cols, ((height * 0.78 - gap * (rows - 1)) / rows) * monW / monH, width * 0.4)
        readonly property real tileH: tileW * monH / monW

        // Dimmed backdrop (blurred by the Hyprland layer rule). Click = close.
        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.55)
            opacity: root.open ? 1 : 0

            // The only animated part of the overview (the tiles just appear /
            // disappear with it).
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }

        // ---- workspace grid ----
        Grid {
            id: grid
            anchors.centerIn: parent
            columns: win.cols
            spacing: win.gap
            // Tiles aren't animated: they appear with the overlay and vanish
            // the moment it starts closing (only the backdrop fades).
            visible: root.open

            // Tiles slide to their new places when the (preview) order changes.
            move: Transition {
                enabled: root.animateMoves
                NumberAnimation {
                    properties: "x,y"
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Repeater {
                id: tiles
                // ScriptModel turns order changes into moves, so tiles (and
                // their live previews) are kept and animated, not recreated.
                model: ScriptModel {
                    values: root.displayIds
                }

                // The tile itself is the click target ("go to workspace");
                // windows on top have their own handlers.
                MouseArea {
                    id: tile

                    required property int modelData
                    readonly property int wsId: modelData
                    readonly property bool current: Hyprland.focusedWorkspace?.id === wsId
                    readonly property bool isSelected: root.selected === wsId
                    // Window drags highlight the target; workspace drags make
                    // room instead (see tileGhost.moveTo).
                    readonly property bool dropTarget: dragGhost.visible && dragGhost.overWs === wsId
                    readonly property bool beingDragged: tileGhost.visible && tileGhost.fromWs === wsId

                    property point pressAt
                    property bool dragging: false

                    // Where a window dropped at (px, py) would go in this
                    // workspace's left-to-right column order: { index, x },
                    // x = insertion line in strip content coordinates.
                    function insertionAt(px, py) {
                        const p = strip.contentItem.mapFromItem(win.contentItem, px, py);
                        const cols = root.windowsFor(wsId).filter(t => t !== dragGhost.toplevel).map(t => {
                            const m = root.monitorOf(t);
                            const left = (t.lastIpcObject.at[0] - (m?.x ?? 0) - strip.bounds.minX) * strip.s;
                            const w = t.lastIpcObject.size[0] * strip.s;
                            return {
                                left: left,
                                right: left + w,
                                center: left + w / 2
                            };
                        }).sort((a, b) => a.left - b.left);
                        const index = cols.filter(c => c.center < p.x).length;
                        const x = cols.length === 0 ? 0 : index === 0 ? cols[0].left : index >= cols.length ? cols[cols.length - 1].right : (cols[index - 1].right + cols[index].left) / 2;
                        return {
                            index: index,
                            x: x
                        };
                    }

                    // Window preview under a window-level point (topmost first).
                    function windowAt(px, py) {
                        const kids = strip.contentItem.children;
                        for (let i = kids.length - 1; i >= 0; i--) {
                            const k = kids[i];
                            if (!k.isWindowItem)
                                continue;
                            const q = k.mapFromItem(win.contentItem, px, py);
                            if (q.x >= 0 && q.y >= 0 && q.x <= k.width && q.y <= k.height)
                                return k.modelData;
                        }
                        return null;
                    }

                    width: win.tileW
                    height: win.tileH + 22
                    opacity: beingDragged ? 0.35 : 1
                    hoverEnabled: true
                    cursorShape: dragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                    onEntered: if (!tileGhost.visible)
                        root.selected = wsId

                    // Click = go there; drag = move the whole workspace.
                    onPressed: mouse => {
                        pressAt = Qt.point(mouse.x, mouse.y);
                        dragging = false;
                    }
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        if (!dragging && Math.hypot(mouse.x - pressAt.x, mouse.y - pressAt.y) > 8) {
                            dragging = true;
                            tileGhost.start(tile);
                        }
                        if (dragging) {
                            const p = mapToItem(win.contentItem, mouse.x, mouse.y);
                            tileGhost.moveTo(p.x, p.y);
                        }
                    }
                    onReleased: mouse => {
                        if (dragging) {
                            dragging = false;
                            tileGhost.drop();
                        } else {
                            root.goWorkspace(wsId);
                        }
                    }

                    // Workspace number (dot = current).
                    Text {
                        x: 2
                        text: tile.current ? `${tile.wsId}  •` : tile.wsId
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                        color: tile.isSelected ? Theme.accent : Theme.foreground
                    }

                    // Wallpaper with rounded corners (display only).
                    ClippingRectangle {
                        id: screenArea
                        y: 22
                        width: win.tileW
                        height: win.tileH
                        radius: 10
                        color: Theme.surface

                        Image {
                            anchors.fill: parent
                            source: Wallpaper.current ? `file://${Wallpaper.current}` : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 480
                            sourceSize.height: 270
                            opacity: 0.85
                        }
                    }

                    // Windows at their real positions, scaled down, in a strip
                    // that scrolls (mouse wheel) to reach columns that are off
                    // screen in the scrolling layout. Starts at the real screen.
                    Flickable {
                        id: strip

                        readonly property var bounds: root.extentOf(tile.wsId)
                        readonly property real s: win.tileW / win.monW
                        readonly property bool scrollsX: contentWidth > width + 1
                        readonly property bool scrollsY: contentHeight > height + 1

                        // Wheel -> scroll the strip (horizontal first). Also
                        // called by the window previews, whose MouseAreas would
                        // otherwise swallow the wheel event.
                        function scrollBy(angleDelta) {
                            const d = angleDelta.y !== 0 ? angleDelta.y : angleDelta.x;
                            const step = d / 120 * width * 0.25;
                            if (scrollsX)
                                contentX = Math.max(0, Math.min(contentWidth - width, contentX - step));
                            else if (scrollsY)
                                contentY = Math.max(0, Math.min(contentHeight - height, contentY - step));
                        }

                        // Line up with what the monitor shows, instantly.
                        function showScreen() {
                            animateScroll = false;
                            contentX = Math.max(0, Math.min(contentWidth - width, -bounds.minX * s));
                            contentY = Math.max(0, Math.min(contentHeight - height, -bounds.minY * s));
                            animateScroll = true;
                        }

                        x: screenArea.x
                        y: screenArea.y
                        width: screenArea.width
                        height: screenArea.height
                        clip: true
                        // Mouse is for clicking / dragging; scroll with the wheel.
                        interactive: false
                        contentWidth: (bounds.maxX - bounds.minX) * s
                        contentHeight: (bounds.maxY - bounds.minY) * s

                        Component.onCompleted: showScreen()
                        Connections {
                            target: root
                            function onOpenChanged() {
                                if (root.open)
                                    strip.showScreen();
                            }
                        }

                        // Smooth wheel scrolling only; showScreen() jumps.
                        property bool animateScroll: true

                        Behavior on contentX {
                            enabled: strip.animateScroll
                            NumberAnimation {
                                duration: 120
                            }
                        }

                        WheelHandler {
                            onWheel: event => strip.scrollBy(event.angleDelta)
                        }

                        // Insertion line while dragging a window in from
                        // another workspace.
                        Rectangle {
                            z: 5
                            visible: root.insertHint?.ws === tile.wsId
                            x: (root.insertHint?.x ?? 0) - width / 2
                            y: 6
                            width: 4
                            height: strip.contentHeight - 12
                            radius: 2
                            color: Theme.accent
                        }

                        // Outline of what the monitor actually shows.
                        Rectangle {
                            visible: strip.scrollsX || strip.scrollsY
                            x: -strip.bounds.minX * strip.s
                            y: -strip.bounds.minY * strip.s
                            width: win.monW * strip.s
                            height: win.monH * strip.s
                            color: "transparent"
                            radius: 6
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.35)
                        }

                        Repeater {
                            // ScriptModel keeps the delegate (and its running
                            // preview) for windows that stay on this workspace.
                            model: ScriptModel {
                                // win.visible (not root.open): previews stay
                                // through the fade-out instead of vanishing.
                                values: win.visible ? root.windowsFor(tile.wsId) : []
                            }

                            Item {
                                id: winItem

                                required property var modelData
                                readonly property bool isWindowItem: true // for tile.windowAt()
                                readonly property bool isSwapTarget: root.swapTarget === modelData
                                readonly property bool isSelectedWindow: root.selectedWindow === modelData
                                readonly property bool matchesQuery: root.matches(modelData)
                                readonly property var ipc: modelData.lastIpcObject

                                // Faded while dragged, or when it doesn't match the search.
                                opacity: dragGhost.toplevel === modelData ? 0.35 : matchesQuery ? 1 : 0.2

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                    }
                                }

                                // Keyboard-selected window off to the side of a
                                // scrolling workspace: scroll its tile to it.
                                onIsSelectedWindowChanged: if (isSelectedWindow && (strip.scrollsX || strip.scrollsY))
                                    strip.contentX = Math.max(0, Math.min(strip.contentWidth - strip.width, x + width / 2 - strip.width / 2))

                                // After a move/swap, re-tiling resizes and
                                // moves windows, which breaks their capture:
                                // restart it once things settle. Previews
                                // created mid-move (window changed workspace)
                                // restart once the move has landed.
                                onWidthChanged: if (root.glide)
                                    preview.refresh(250)
                                onHeightChanged: if (root.glide)
                                    preview.refresh(250)
                                onXChanged: if (root.glide)
                                    preview.refresh(250)
                                onYChanged: if (root.glide)
                                    preview.refresh(250)
                                Component.onCompleted: if (root.glide)
                                    preview.refresh(600)
                                readonly property var wmon: root.monitorOf(modelData)
                                readonly property real s: win.tileW / (wmon ? wmon.width / wmon.scale : win.monW)

                                // Content coordinates: shifted so the strip
                                // starts at the left-/top-most window.
                                x: (ipc.at[0] - (wmon?.x ?? 0) - strip.bounds.minX) * s
                                y: (ipc.at[1] - (wmon?.y ?? 0) - strip.bounds.minY) * s
                                width: Math.max(8, ipc.size[0] * s)
                                height: Math.max(8, ipc.size[1] * s)

                                // Glide into the new layout when Hyprland
                                // re-tiles after a move (instead of jumping).
                                Behavior on x {
                                    enabled: root.glide
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on y {
                                    enabled: root.glide
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on width {
                                    enabled: root.glide
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on height {
                                    enabled: root.glide
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: Theme.surfaceHigh
                                    clip: true

                                    // Live preview. A capture can fail while
                                    // the window is being moved, and then just
                                    // stops: restart it (a few times in a row;
                                    // reset once frames arrive again).
                                    ScreencopyView {
                                        id: preview

                                        property bool capturing: true
                                        property int retries: 0

                                        anchors.fill: parent
                                        captureSource: win.visible && capturing ? winItem.modelData.wayland : null
                                        live: true
                                        paintCursor: false
                                        constraintSize: Qt.size(width, height)

                                        onStopped: if (win.visible && retries < 5)
                                            restart.restart()
                                        onHasContentChanged: if (hasContent)
                                            retries = 0

                                        Timer {
                                            id: restart
                                            interval: 300
                                            onTriggered: {
                                                preview.retries++;
                                                preview.capturing = false;
                                                Qt.callLater(() => preview.capturing = true);
                                            }
                                        }

                                        // Hyprland's capture fails when the
                                        // window is resized/moved mid-capture,
                                        // and `stopped` isn't always emitted.
                                        // So restart once the geometry has
                                        // settled (debounced), whenever it
                                        // changes right after a move/swap.
                                        function refresh(delay) {
                                            settleRestart.interval = delay;
                                            settleRestart.restart();
                                        }

                                        Timer {
                                            id: settleRestart
                                            interval: 250
                                            onTriggered: {
                                                preview.capturing = false;
                                                Qt.callLater(() => preview.capturing = true);
                                            }
                                        }
                                    }

                                    // No preview yet: app icon.
                                    IconImage {
                                        anchors.centerIn: parent
                                        visible: !preview.hasContent
                                        implicitSize: Math.min(parent.width, parent.height) * 0.4
                                        source: root.iconFor(winItem.modelData)
                                    }
                                }

                                // Hover / swap-target / keyboard-selection outline.
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: winItem.isSwapTarget ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                                    border.width: winItem.isSwapTarget || winItem.isSelectedWindow ? 3 : winMouse.containsMouse ? 2 : 1
                                    border.color: winItem.isSwapTarget || winItem.isSelectedWindow || winMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.15)
                                }

                                // Click = focus, drag = move to another workspace.
                                MouseArea {
                                    id: winMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: dragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                                    // Middle click closes the window.
                                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                                    property point pressAt
                                    property bool dragging: false

                                    onEntered: root.selected = tile.wsId
                                    // Pass the wheel on so the strip scrolls
                                    // even when the cursor is over a window.
                                    onWheel: wheel => strip.scrollBy(wheel.angleDelta)
                                    onPressed: mouse => {
                                        pressAt = Qt.point(mouse.x, mouse.y);
                                        dragging = false;
                                    }
                                    onPositionChanged: mouse => {
                                        // Only the left button drags.
                                        if (!(pressedButtons & Qt.LeftButton))
                                            return;
                                        if (!dragging && Math.hypot(mouse.x - pressAt.x, mouse.y - pressAt.y) > 6) {
                                            dragging = true;
                                            dragGhost.start(winItem.modelData, winItem.width, winItem.height);
                                        }
                                        if (dragging) {
                                            const p = mapToItem(win.contentItem, mouse.x, mouse.y);
                                            dragGhost.moveTo(p.x, p.y);
                                        }
                                    }
                                    onReleased: mouse => {
                                        if (mouse.button === Qt.MiddleButton) {
                                            root.closeWindow(winItem.modelData);
                                        } else if (dragging) {
                                            dragging = false;
                                            dragGhost.drop(tile.wsId);
                                        } else {
                                            root.focusWindow(winItem.modelData);
                                        }
                                    }

                                    // ✕ on hover (top-right): close the window.
                                    MouseArea {
                                        id: closeButton
                                        visible: (winMouse.containsMouse || containsMouse) && !winMouse.dragging && winItem.width > 40
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        width: 20
                                        height: 20
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.closeWindow(winItem.modelData)

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: width / 2
                                            color: closeButton.containsMouse ? Theme.urgent : Qt.rgba(0, 0, 0, 0.6)
                                        }

                                        Icon {
                                            anchors.centerIn: parent
                                            name: "close"
                                            size: 13
                                            color: "white"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Scroll bar when the workspace is wider than the screen.
                    Rectangle {
                        visible: strip.scrollsX
                        x: screenArea.x + 8
                        y: screenArea.y + screenArea.height - 8
                        width: screenArea.width - 16
                        height: 3
                        radius: 1.5
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            x: strip.contentWidth > 0 ? parent.width * strip.contentX / strip.contentWidth : 0
                            width: strip.contentWidth > 0 ? parent.width * strip.width / strip.contentWidth : 0
                            height: parent.height
                            radius: parent.radius
                            color: Qt.rgba(1, 1, 1, 0.7)
                        }
                    }

                    // Selection / drop outline.
                    Rectangle {
                        x: screenArea.x
                        y: screenArea.y
                        width: screenArea.width
                        height: screenArea.height
                        radius: screenArea.radius
                        color: "transparent"
                        border.width: tile.dropTarget || tile.isSelected ? 3 : tile.current ? 1 : 0
                        border.color: tile.dropTarget ? Theme.success : tile.isSelected ? Theme.accent : Qt.rgba(1, 1, 1, 0.4)
                    }
                }
            }

            // "+" tile: first free workspace (click to go, drop a window to move it).
            MouseArea {
                id: newTile

                readonly property int wsId: root.freeId
                readonly property bool isSelected: root.selected === wsId
                readonly property bool dropTarget: (dragGhost.visible || tileGhost.visible) && (dragGhost.overWs === wsId || tileGhost.overWs === wsId)

                width: win.tileW
                height: win.tileH + 22
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selected = wsId
                onClicked: root.goWorkspace(wsId)

                Text {
                    x: 2
                    text: `${newTile.wsId}`
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                    color: newTile.isSelected ? Theme.accent : Theme.foregroundDim
                }

                Rectangle {
                    y: 22
                    width: win.tileW
                    height: win.tileH
                    radius: 10
                    color: newTile.dropTarget ? Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15) : Qt.rgba(1, 1, 1, newTile.containsMouse ? 0.08 : 0.04)
                    border.width: newTile.dropTarget || newTile.isSelected ? 3 : 2
                    border.color: newTile.dropTarget ? Theme.success : newTile.isSelected ? Theme.accent : Qt.rgba(1, 1, 1, 0.25)

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "add"
                            size: 32
                            color: Theme.foregroundDim
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: dragGhost.visible || tileGhost.visible ? "Move to new workspace" : "New workspace"
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 1
                            color: Theme.foregroundDim
                        }
                    }
                }
            }
        }

        // Window being dragged.
        Rectangle {
            id: dragGhost

            property var toplevel: null
            property int overWs: -1

            function start(t, w, h) {
                toplevel = t;
                width = Math.max(60, w);
                height = Math.max(40, h);
                visible = true;
            }

            function hit(item, px, py) {
                const q = item.mapFromItem(win.contentItem, px, py);
                return q.x >= 0 && q.y >= 0 && q.x <= item.width && q.y <= item.height;
            }

            // Over another workspace: move there. Over another window of the
            // same workspace: that window becomes the swap target.
            function moveTo(px, py) {
                x = px - width / 2;
                y = py - height / 2;
                overWs = -1;
                let swap = null;
                let hint = null;
                for (let i = 0; i < tiles.count; i++) {
                    const t = tiles.itemAt(i);
                    if (hit(t, px, py)) {
                        overWs = t.wsId;
                        if (t.wsId === toplevel?.workspace?.id) {
                            const w = t.windowAt(px, py);
                            if (w && w !== toplevel)
                                swap = w;
                        } else {
                            // Another workspace: show where it would go.
                            const ins = t.insertionAt(px, py);
                            hint = {
                                ws: t.wsId,
                                index: ins.index,
                                x: ins.x
                            };
                        }
                        break;
                    }
                }
                if (overWs < 0 && hit(newTile, px, py))
                    overWs = newTile.wsId;
                if (overWs > 0)
                    root.selected = overWs;
                root.swapTarget = swap;
                root.insertHint = hint;
            }

            function drop(fromWs) {
                if (toplevel && root.swapTarget)
                    root.swapWindows(toplevel, root.swapTarget);
                else if (toplevel && overWs > 0 && overWs !== fromWs)
                    // At the shown insertion point (empty / "+": first).
                    root.moveWindow(toplevel, overWs, root.insertHint?.ws === overWs ? root.insertHint.index : 0);
                visible = false;
                toplevel = null;
                overWs = -1;
                root.swapTarget = null;
                root.insertHint = null;
            }

            visible: false
            z: 10
            radius: 6
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
            border.width: 2
            border.color: Theme.accent

            IconImage {
                anchors.centerIn: parent
                implicitSize: Math.min(parent.width, parent.height) * 0.5
                source: root.iconFor(dragGhost.toplevel)
            }
        }

        // Workspace being dragged: a live miniature of its tile.
        ShaderEffectSource {
            id: tileGhost

            property int fromWs: -1
            property int overWs: -1

            function start(tileItem) {
                sourceItem = tileItem;
                fromWs = tileItem.wsId;
                width = tileItem.width * 0.6;
                height = tileItem.height * 0.6;
                visible = true;
            }

            // Hovering a slot moves the dragged workspace into it in the
            // preview, so the tile there slides out of the way.
            //
            // Anti-flicker: the target is computed from the grid's fixed slots
            // (not the tiles, which are mid-animation), and only changes when
            // the cursor is in the middle 60% of a slot. Near edges and in
            // gaps the current preview holds.
            readonly property real deadZone: 0.2

            function moveTo(px, py) {
                x = px - width / 2;
                y = py - height / 2;

                const g = grid.mapFromItem(win.contentItem, px, py);
                const cellW = win.tileW + win.gap;
                const cellH = win.tileH + 22 + win.gap;
                const col = Math.floor(g.x / cellW);
                const row = Math.floor(g.y / cellH);
                const fx = (g.x - col * cellW) / win.tileW;
                const fy = (g.y - row * cellH) / (win.tileH + 22);
                const slot = row * win.cols + col;

                const inside = col >= 0 && col < win.cols && row >= 0 && slot <= root.wsIds.length && fx >= 0 && fx <= 1 && fy >= 0 && fy <= 1;
                if (!inside)
                    return;
                const committed = fx >= deadZone && fx <= 1 - deadZone && fy >= deadZone && fy <= 1 - deadZone;

                // Last slot is the "+" tile.
                if (slot === root.wsIds.length) {
                    overWs = root.freeId;
                    return;
                }
                if (overWs === root.freeId)
                    overWs = -1;
                if (!committed)
                    return;

                const current = root.displayIds;
                if (current.indexOf(fromWs) !== slot) {
                    const order = current.filter(id => id !== fromWs);
                    order.splice(slot, 0, fromWs);
                    root.previewOrder = order;
                }
                overWs = current[slot] ?? -1;
            }

            function drop() {
                const from = fromWs, to = overWs;
                visible = false;
                sourceItem = null;
                fromWs = -1;
                overWs = -1;
                if (from <= 0)
                    return;

                if (to > 0 && !root.wsIds.includes(to)) {
                    // Dropped on "+": move it to the first free workspace.
                    const incoming = {};
                    incoming[from] = [];
                    incoming[to] = root.windowsOn(from);
                    root.animateMoves = false;
                    root.previewOrder = null;
                    root.stage(incoming, [...root.wsIds, to]);
                    reenableMoves.restart();
                    root.moveContents({
                        [from]: to
                    });
                    root.selected = to;
                    return;
                }

                const order = root.displayIds;
                if (order.join() === root.wsIds.join()) {
                    root.previewOrder = null;
                    return;
                }
                root.selected = root.wsIds[order.indexOf(from)];
                root.commitOrder(order);
            }

            visible: false
            z: 10
            live: true
            hideSource: false
            opacity: 0.9
        }

        // Search pill: the query, or a hint about typing / Tab.
        Rectangle {
            visible: root.open
            anchors.horizontalCenter: parent.horizontalCenter
            y: 48
            width: searchRow.implicitWidth + 32
            height: 40
            radius: height / 2
            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.85)
            border.width: 1
            border.color: root.query ? Theme.accent : Theme.glassBorder

            Row {
                id: searchRow
                anchors.centerIn: parent
                spacing: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "search"
                    size: 18
                    color: root.query ? Theme.foreground : Theme.foregroundDim
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.query || "Type to search windows · Tab to cycle · Enter to focus"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    color: root.query ? Theme.foreground : Theme.foregroundDim
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.query !== ""
                    text: root.matchingWindows.length === 1 ? "1 match" : `${root.matchingWindows.length} matches`
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: root.matchingWindows.length ? Theme.foregroundDim : Theme.urgent
                }
            }
        }

        // Keyboard.
        //   type          search (Backspace edits, Esc clears, Esc again closes)
        //   Tab/Shift+Tab cycle through (matching) windows
        //   Enter         focus the selected window, else go to the workspace
        //   Delete        close the selected window
        //   arrows        move between workspaces;  1-9 jump (when not searching)
        Item {
            id: keys
            focus: true
            Keys.onPressed: event => {
                const ids = [...root.wsIds, root.freeId];
                const i = Math.max(0, ids.indexOf(root.selected));
                if (event.key === Qt.Key_Escape) {
                    if (root.query)
                        root.query = "";
                    else
                        root.close();
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (root.selectedWindow)
                        root.focusWindow(root.selectedWindow);
                    else
                        root.goWorkspace(root.selected);
                } else if (event.key === Qt.Key_Tab) {
                    root.cycleWindow(1);
                } else if (event.key === Qt.Key_Backtab) {
                    root.cycleWindow(-1);
                } else if (event.key === Qt.Key_Delete) {
                    root.closeWindow(root.selectedWindow);
                } else if (event.key === Qt.Key_Backspace) {
                    root.query = root.query.slice(0, -1);
                } else if (!root.query && event.key >= Qt.Key_1 && event.key <= Qt.Key_9 && ids.includes(event.key - Qt.Key_0)) {
                    root.goWorkspace(event.key - Qt.Key_0);
                } else if (event.text && event.text.length === 1 && event.text >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                    root.query += event.text;
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Left || event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                    // Arrows select workspaces (Enter then goes there).
                    root.selectedWindow = null;
                    const step = event.key === Qt.Key_Right ? 1 : event.key === Qt.Key_Left ? -1 : event.key === Qt.Key_Down ? win.cols : -win.cols;
                    root.selected = ids[Math.max(0, Math.min(ids.length - 1, i + step))];
                } else {
                    return;
                }
                event.accepted = true;
            }
        }
    }
}
