import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import qs.common
import qs.services
import qs.components
import qs.bar

// macOS-style panel: controls on top, notifications below.
// Opens on the focused monitor; click outside or Esc to close.
PanelWindow {
    id: root

    readonly property bool open: Notifs.centerOpen

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    // Stay mapped until the slide-out animation finishes.
    visible: open || content.x < width

    anchors {
        top: true
        right: true
        bottom: true
    }
    margins {
        top: 8
        right: 8
        bottom: 8
    }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nyx-control-center"
    // Exclusive while open so Esc always reaches the panel.
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"
    implicitWidth: 380

    // Only the visible cards take input; the rest of the column is click-through.
    mask: Region {
        item: content
    }

    HyprlandFocusGrab {
        // Bar clicks pass through, so the bell toggles and other buttons switch.
        windows: [root, ...Ui.bars]
        active: root.open
        onCleared: Notifs.centerOpen = false
    }

    // ---- state for the controls ----
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property var btConnected: btAdapter?.devices.values.filter(d => d.connected) ?? []
    readonly property var sink: Pipewire.defaultAudioSink
    property real brightness: -1

    PwObjectTracker {
        objects: [root.sink]
    }

    // `brightnessctl -m` -> "intel_backlight,backlight,191,38%,504"
    Process {
        id: readBrightness
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: SplitParser {
            onRead: line => {
                const f = line.split(",");
                if (f.length >= 5 && parseInt(f[4]) > 0)
                    root.brightness = parseInt(f[2]) / parseInt(f[4]);
            }
        }
    }

    onOpenChanged: if (open) {
        readBrightness.running = true;
        content.forceActiveFocus();
    }

    // Frosted backdrop behind everything (blurred by Hyprland).
    Rectangle {
        id: content

        width: parent.width
        height: Math.min(column.implicitHeight + 2 * padding, parent.height)
        x: root.open ? 0 : width + 16
        radius: 20
        color: Theme.glass
        border.width: 1
        border.color: Theme.glassBorder

        readonly property int padding: 10
        focus: root.open
        Keys.onEscapePressed: Notifs.centerOpen = false

        Behavior on x {
            NumberAnimation {
                duration: 240
                easing.type: Easing.OutCubic
            }
        }

        Flickable {
            anchors.fill: parent
            anchors.margins: content.padding
            contentHeight: column.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Column {
                id: column
                width: parent.width
                spacing: 10

                // ---- controls ----
                RowLayout {
                    width: parent.width
                    spacing: 10

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true

                        ControlToggle {
                            icon: Networking.wifiEnabled ? "wifi" : "wifi_off"
                            title: "Wi-Fi"
                            subtitle: !Networking.wifiEnabled ? "Off" : root.wifiNetwork?.name ?? "Not connected"
                            checked: Networking.wifiEnabled
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }

                        ControlToggle {
                            icon: "bluetooth"
                            title: "Bluetooth"
                            subtitle: !(root.btAdapter?.enabled ?? false) ? "Off" : root.btConnected.length ? root.btConnected[0].name : "On"
                            checked: root.btAdapter?.enabled ?? false
                            onClicked: if (root.btAdapter)
                                root.btAdapter.enabled = !root.btAdapter.enabled
                        }
                    }

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true

                        ControlToggle {
                            icon: "do_not_disturb_on"
                            title: "Do Not Disturb"
                            subtitle: Notifs.dnd ? "On" : "Off"
                            checked: Notifs.dnd
                            onClicked: Notifs.dnd = !Notifs.dnd
                        }

                        ControlToggle {
                            icon: "coffee"
                            title: "Keep Awake"
                            subtitle: Caffeine.active ? Caffeine.remainingText : "Off"
                            checked: Caffeine.active
                            onClicked: Caffeine.toggle()
                        }
                    }
                }

                // Brightness (laptops) + night light (NightLight.qml / hyprsunset).
                Tile {
                    width: parent.width
                    spacing: 8

                    RowLayout {
                        width: parent.width

                        SectionLabel {
                            Layout.fillWidth: true
                            text: "Display"
                        }

                        // Night light toggle pill.
                        MouseArea {
                            implicitWidth: nightRow.implicitWidth + 18
                            implicitHeight: 24
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NightLight.toggle()

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: NightLight.on ? Theme.accent : parent.containsMouse ? Theme.glassTileHover : Theme.surfaceHigh

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animDuration
                                    }
                                }
                            }

                            Row {
                                id: nightRow
                                anchors.centerIn: parent
                                spacing: 5

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: "nightlight"
                                    filled: NightLight.on
                                    size: 15
                                    color: NightLight.on ? Theme.background : Theme.foreground
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: NightLight.on ? `Night Light · ${NightLight.temperature}K` : "Night Light"
                                    font.family: Theme.font
                                    font.pixelSize: Theme.fontSize - 2
                                    font.weight: NightLight.on ? Font.DemiBold : Font.Normal
                                    color: NightLight.on ? Theme.background : Theme.foreground
                                }
                            }
                        }
                    }

                    Slider {
                        visible: root.brightness >= 0
                        icon: "brightness_6"
                        value: root.brightness
                        onMoved: v => {
                            root.brightness = Math.max(0.01, v);
                            Quickshell.execDetached(["brightnessctl", "-q", "-c", "backlight", "set", `${Math.round(root.brightness * 100)}%`]);
                        }
                    }

                    // Warmth, only while night light is on (left = neutral, right = warmest).
                    Slider {
                        visible: NightLight.on
                        icon: "nightlight"
                        value: NightLight.warmth
                        onMoved: v => NightLight.setWarmth(Math.max(0.05, v))
                    }
                }

                Tile {
                    width: parent.width
                    visible: root.sink?.audio != null
                    spacing: 8

                    SectionLabel {
                        text: "Sound"
                    }

                    Slider {
                        icon: (root.sink?.audio.muted ?? false) ? "volume_off" : "volume_up"
                        value: root.sink?.audio.volume ?? 0
                        onMoved: v => {
                            root.sink.audio.muted = false;
                            root.sink.audio.volume = v;
                        }
                    }
                }

                // ---- power ----
                PowerActions {
                    width: parent.width
                }

                // ---- notifications ----
                RowLayout {
                    width: parent.width
                    height: 32

                    SectionLabel {
                        Layout.fillWidth: true
                        Layout.leftMargin: 4
                        text: "Notifications"
                    }

                    MouseArea {
                        visible: Notifs.count > 0
                        implicitWidth: clearText.implicitWidth + 16
                        implicitHeight: 24
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.clearAll()

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: parent.containsMouse ? Theme.surfaceHigh : Theme.surface
                        }

                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "Clear all"
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize - 2
                            color: Theme.foreground
                        }
                    }
                }

                Tile {
                    width: parent.width
                    visible: Notifs.count === 0

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: "No notifications"
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize
                        color: Theme.foregroundDim
                    }
                }

                // Padding so close buttons (top-left of cards) aren't clipped.
                Column {
                    width: parent.width
                    spacing: 10
                    leftPadding: 6
                    topPadding: 6

                    Repeater {
                        model: ScriptModel {
                            values: Notifs.groups
                            objectProp: "key" // keep delegates when a group changes
                        }

                        NotificationGroup {
                            required property var modelData
                            group: modelData
                            width: column.width - 6
                        }
                    }
                }
            }
        }
    }
}
