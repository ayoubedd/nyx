import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Card that drops down under `target`, right-aligned to it.
//
// This is a layer-shell overlay rather than an xdg popup: popups can only get
// keyboard input through a popup grab, and that grab swallows clicks on the
// bar. As an overlay it takes keyboard focus (Esc, Wi-Fi password) while the
// focus grab below still lets bar clicks through.
//
// Open/close through `shown` (or toggle()/close()), not `visible`: with
// `slide`, the window stays mapped until the slide-out animation finishes.
//
// Only one is open at a time (see Ui.qml).
PanelWindow {
    id: root

    required property Item target
    default property alias content: column.data
    property int contentWidth: 280
    // Centered on the screen (e.g. under the clock) instead of under the button.
    property bool centered: false
    // While open, don't show the volume/brightness OSD (menu shows levels).
    property bool suppressOsd: false
    // Slide down from the top edge when opening, back up when closing.
    property bool slide: false

    // Logical open state.
    property bool shown: false

    readonly property var barWindow: target.QsWindow.window
    readonly property real hiddenY: -implicitHeight - 12

    function toggle() {
        if (shown) {
            shown = false;
        } else {
            reposition();
            Ui.open(root);
        }
    }

    function close() {
        shown = false;
    }

    // Right-align with the button that opened it.
    function reposition() {
        if (!barWindow || centered)
            return;
        const p = target.mapToItem(null, 0, 0);
        margins.right = Math.max(8, barWindow.width - (p.x + target.width));
    }

    screen: barWindow?.screen ?? null
    // Stay mapped while sliding out.
    visible: shown || (slide && card.y > hiddenY + 0.5)

    anchors {
        top: true
        right: !root.centered
    }
    margins.top: 6
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nyx-dropdown"
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"
    implicitWidth: contentWidth
    implicitHeight: column.implicitHeight + 16

    onShownChanged: {
        if (shown)
            card.forceActiveFocus();
        else if (Ui.active === root)
            Ui.active = null;
    }

    // Click outside the dropdown and the bar -> close.
    HyprlandFocusGrab {
        windows: [root, ...Ui.bars]
        active: root.shown
        onCleared: root.shown = false
    }

    Rectangle {
        id: card

        width: parent.width
        height: parent.height
        // Without `slide` it simply sits at 0 (instant show/hide).
        y: !root.slide || root.shown ? 0 : root.hiddenY
        opacity: !root.slide || root.shown ? 1 : 0

        Behavior on y {
            enabled: root.slide
            NumberAnimation {
                duration: 280
                easing.type: root.shown ? Easing.OutCubic : Easing.InCubic
            }
        }
        Behavior on opacity {
            enabled: root.slide
            NumberAnimation {
                duration: 240
            }
        }

        focus: true
        // Fields inside (e.g. the Wi-Fi password) handle Esc first.
        Keys.onEscapePressed: root.shown = false
        radius: Theme.radius
        color: Theme.background
        border.width: 1
        border.color: Theme.surfaceHigh

        Column {
            id: column
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2
        }
    }
}
