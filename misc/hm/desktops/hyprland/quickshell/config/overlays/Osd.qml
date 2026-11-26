import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import qs.common
import qs.services

// On-screen display for volume, microphone mute, brightness, keyboard
// backlight and power profile changes.
//
// Sources:
//   volume / mic     PipeWire (any change: keys, control center, wpctl,
//                    a headset connecting)
//   brightness       the brightness keys call `qs -c nyx ipc call osd brightness`
//                    (no reliable change event)
//   kbd backlight    UPower's KbdBacklight signals (Fn+Space included)
//   power profile    tuned's profile_changed signal (any switch: automatic on
//                    plug/unplug, the battery menu, the launcher, tuned-adm)
// The two D-Bus signals come from one `dbus-monitor` (broadcast signals need
// no privileges), so nothing polls.
//
// Click-through, no keyboard focus, hidden while the control center is open.
Scope {
    id: root

    // "volume" | "mic" | "brightness" | "kbd" | "profile" | "device"
    property string kind: ""
    property bool shown: false
    property string device: "" // set when the output device just changed
    property real brightness: 0
    property int kbdLevel: 0
    property int kbdMax: 2
    property string profile: "" // tuned profile id
    // "device": a Bluetooth device that just connected, with its battery.
    property string deviceName: ""
    property string deviceIcon: "bluetooth"
    property real deviceLevel: 0

    // Kinds drawn with a level bar (the rest are a title line).
    readonly property bool hasLevel: kind === "volume" || kind === "brightness" || kind === "kbd" || kind === "device"

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool volumeMuted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false

    // Ignore the burst of "changes" while PipeWire state loads at startup.
    property bool armed: false

    function show(which) {
        if (!armed || Notifs.centerOpen || (Ui.active?.suppressOsd ?? false))
            return;
        kind = which;
        shown = true;
        hideTimer.restart();
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // ---- Bluetooth device connected: its battery -------------------------
    // Once per connection, when its battery level first becomes known
    // (BlueZ reports it a few seconds after connecting).
    // Addresses already announced (or connected before startup). Kept per
    // connection, not per battery report, so a level that briefly drops out
    // and comes back doesn't pop it again; forgotten on disconnect.
    property var seenDevices: []
    // BlueZ enumerates devices and their batteries over D-Bus a moment
    // after startup: everything connected by then counts as already seen.
    property bool btSettled: false
    readonly property var connectedAddrs: (Bluetooth.defaultAdapter?.devices.values ?? []).filter(d => d.connected).map(d => d.address)
    onConnectedAddrsChanged: if (btSettled)
        seenDevices = seenDevices.filter(a => connectedAddrs.includes(a))

    Timer {
        interval: 6000
        running: true
        onTriggered: {
            root.seenDevices = root.connectedAddrs;
            root.btSettled = true;
        }
    }

    function deviceGlyph(d) {
        const i = d?.icon ?? "";
        return i.includes("audio") || i.includes("headset") || i.includes("headphone") ? "headphones" : i.includes("mouse") ? "mouse" : i.includes("keyboard") ? "keyboard" : i.includes("phone") ? "smartphone" : i.includes("game") ? "stadia_controller" : "bluetooth";
    }

    Connections {
        target: BluetoothBattery
        function onDevicesChanged() {
            if (!root.btSettled)
                return;
            const fresh = BluetoothBattery.devices.filter(d => !root.seenDevices.includes(d.address));
            if (fresh.length === 0)
                return;
            root.seenDevices = root.seenDevices.concat(fresh.map(d => d.address));
            const d = fresh[0];
            root.deviceName = BluetoothBattery.name(d);
            root.deviceIcon = root.deviceGlyph(d);
            root.deviceLevel = BluetoothBattery.level(d);
            root.show("device");
        }
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: root.kind === "device" ? 3000 : 1500
        onTriggered: {
            root.shown = false;
            root.device = "";
        }
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() {
            root.show("volume");
        }
        function onMutedChanged() {
            root.show("volume");
        }
    }

    Connections {
        target: root.source?.audio ?? null
        function onMutedChanged() {
            root.show("mic");
        }
    }

    // New default output (e.g. headphones connected): show its name.
    onSinkChanged: {
        if (!armed || !sink)
            return;
        device = sink.description || sink.nickname || sink.name;
        show("volume");
    }

    // `brightnessctl -m` -> "intel_backlight,backlight,191,38%,504"
    Process {
        id: readBrightness
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: SplitParser {
            onRead: line => {
                const f = line.split(",");
                if (f.length >= 5 && parseInt(f[4]) > 0) {
                    root.brightness = parseInt(f[2]) / parseInt(f[4]);
                    root.show("brightness");
                }
            }
        }
    }

    // ---- keyboard backlight + power profile (D-Bus signals) ----------------

    // dbus-monitor prints "signal ... member=X" then one line per argument.
    property string pendingSignal: ""

    Process {
        id: signals
        running: true
        command: ["dbus-monitor", "--system", "type='signal',interface='org.freedesktop.UPower.KbdBacklight',member='BrightnessChanged'", "type='signal',interface='com.redhat.tuned.control',member='profile_changed'"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("signal ")) {
                    root.pendingSignal = line.includes("member=BrightnessChanged") ? "kbd" : line.includes("member=profile_changed") ? "profile" : "";
                    return;
                }
                const v = line.trim();
                if (root.pendingSignal === "kbd") {
                    const m = v.match(/^int32 (-?\d+)/);
                    if (m) {
                        root.kbdLevel = parseInt(m[1]);
                        root.show("kbd");
                    }
                    root.pendingSignal = "";
                } else if (root.pendingSignal === "profile") {
                    const m = v.match(/^string "(.*)"$/); // first arg: profile name
                    if (m) {
                        root.profile = m[1];
                        TunedProfiles.refresh();
                        root.show("profile");
                    }
                    root.pendingSignal = "";
                }
            }
        }
        // dbus-monitor exits if the bus restarts; reconnect.
        onExited: signalsRetry.restart()
    }

    Timer {
        id: signalsRetry
        interval: 5000
        onTriggered: signals.running = true
    }

    Process {
        id: readKbdMax
        running: true
        command: ["busctl", "--system", "call", "org.freedesktop.UPower", "/org/freedesktop/UPower/KbdBacklight", "org.freedesktop.UPower.KbdBacklight", "GetMaxBrightness"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/^i (\d+)/);
                if (m && parseInt(m[1]) > 0)
                    root.kbdMax = parseInt(m[1]);
            }
        }
    }

    readonly property var profileInfo: TunedProfiles.profiles.find(p => p.id === profile) ?? null

    IpcHandler {
        target: "osd"

        function brightness(): void {
            readBrightness.running = true;
        }
        function volume(): void {
            root.show("volume");
        }
        function mic(): void {
            root.show("mic");
        }
    }

    PanelWindow {
        id: window

        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        visible: root.shown || card.opacity > 0

        anchors.bottom: true
        margins.bottom: 90
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "nyx-osd"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        // Fully click-through.
        mask: Region {}

        implicitWidth: 320
        implicitHeight: card.implicitHeight

        Rectangle {
            id: card

            readonly property bool muted: root.kind === "volume" ? root.volumeMuted : root.kind === "mic" ? root.micMuted : root.kind === "kbd" ? root.kbdLevel <= 0 : false
            readonly property real level: root.kind === "volume" ? root.volume : root.kind === "brightness" ? root.brightness : root.kind === "kbd" ? root.kbdLevel / Math.max(1, root.kbdMax) : root.kind === "device" ? root.deviceLevel : 0

            readonly property string icon: {
                switch (root.kind) {
                case "mic":
                    return root.micMuted ? "mic_off" : "mic";
                case "brightness":
                    return root.brightness < 0.34 ? "brightness_low" : root.brightness < 0.67 ? "brightness_medium" : "brightness_high";
                case "kbd":
                    return "keyboard";
                case "profile":
                    return root.profileInfo?.icon ?? "bolt";
                case "device":
                    return root.deviceIcon;
                default:
                    if (root.volumeMuted || root.volume <= 0)
                        return "volume_off";
                    return root.volume < 0.34 ? "volume_mute" : root.volume < 0.67 ? "volume_down" : "volume_up";
                }
            }

            // Main line (empty for plain volume/brightness).
            readonly property string title: {
                switch (root.kind) {
                case "mic":
                    return root.micMuted ? "Microphone muted" : "Microphone on";
                case "kbd":
                    return "Keyboard backlight";
                case "profile":
                    return root.profileInfo?.label ?? root.profile;
                case "device":
                    return root.deviceName;
                case "volume":
                    return root.device;
                default:
                    return "";
                }
            }
            readonly property bool titleIsHeading: root.kind !== "volume"

            readonly property string subtitle: root.kind === "profile" ? (TunedProfiles.autoProfile === root.profile ? "Power profile · Automatic" : "Power profile") : ""

            // Right-hand value.
            readonly property string value: {
                if (root.kind === "volume" || root.kind === "brightness")
                    return muted ? "Muted" : `${Math.round(level * 100)}%`;
                if (root.kind === "device")
                    return `${Math.round(level * 100)}%`;
                if (root.kind === "kbd") {
                    if (root.kbdLevel <= 0)
                        return "Off";
                    if (root.kbdMax === 2)
                        return root.kbdLevel === 1 ? "Low" : "High";
                    return `${root.kbdLevel}/${root.kbdMax}`;
                }
                return "";
            }

            width: parent.width
            implicitHeight: content.implicitHeight + 28
            radius: 22
            color: Theme.glass
            border.width: 1
            border.color: Theme.glassBorder

            opacity: root.shown ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.ms(200)
                }
            }

            transform: Translate {
                y: root.shown ? 0 : 12
                Behavior on y {
                    NumberAnimation {
                        duration: Theme.ms(220)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            RowLayout {
                id: content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 14

                Icon {
                    size: 24
                    filled: !card.muted
                    color: card.muted ? Theme.foregroundDim : Theme.foreground
                    name: card.icon
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: root.hasLevel ? 6 : 1

                    // Heading (mic, backlight, profile) or the
                    // device name after an output switch (volume, dim).
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: card.title
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: card.titleIsHeading ? Theme.fontSize : Theme.fontSize - 2
                        font.weight: card.titleIsHeading ? Font.DemiBold : Font.Normal
                        color: card.titleIsHeading ? Theme.foreground : Theme.foregroundDim
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: card.subtitle
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }

                    // Level bar (volume, brightness, keyboard backlight).
                    Rectangle {
                        Layout.fillWidth: true
                        visible: root.hasLevel
                        implicitHeight: 6
                        radius: 3
                        color: Theme.surfaceHigh

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, card.level))
                            height: parent.height
                            radius: 3
                            color: card.muted ? Theme.muted : Theme.foreground

                            Behavior on width {
                                NumberAnimation {
                                    duration: Theme.ms(120)
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: card.value !== ""
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: card.value
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: card.muted ? Theme.foregroundDim : Theme.foreground
                }
            }
        }
    }
}
