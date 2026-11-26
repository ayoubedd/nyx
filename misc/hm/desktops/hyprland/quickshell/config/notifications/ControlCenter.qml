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
    // Stay mapped until the slide-out animation finishes. Compared against the
    // fixed implicitWidth: the window's width changes as it maps and unmaps,
    // which looped back into `visible`.
    visible: open || content.x < implicitWidth

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
        // Tall enough for the detail view too while one is open.
        height: Math.min(Math.max(column.implicitHeight, root.showingDetail ? detailView.implicitHeight : 0) + 2 * padding, parent.height)
        x: root.open ? 0 : root.implicitWidth + 16
        radius: 20
        color: Theme.glass
        border.width: 1
        border.color: Theme.glassBorder
        clip: true

        readonly property int padding: 10
        focus: root.open
        // Esc backs out of a detail view first, then closes the center.
        Keys.onEscapePressed: {
            if (Notifs.centerDetail)
                Notifs.centerDetail = "";
            else
                Notifs.centerOpen = false;
        }

        Behavior on x {
            NumberAnimation {
                duration: Theme.ms(240)
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.ms(220)
                easing.type: Easing.OutCubic
            }
        }

        Flickable {
            anchors.fill: parent
            anchors.margins: content.padding
            contentHeight: column.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            // Pushed aside and faded while a detail view covers it.
            opacity: root.showingDetail ? 0 : 1
            enabled: !root.showingDetail
            transform: Translate {
                x: root.showingDetail ? -40 : 0
                Behavior on x {
                    NumberAnimation {
                        duration: Theme.ms(240)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.ms(200)
                }
            }

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
                            // Icon: on/off. Rest: details (WifiDetail.qml).
                            hasDetail: true
                            onIconClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                            onClicked: Notifs.centerDetail = "wifi"
                        }

                        ControlToggle {
                            icon: "bluetooth"
                            title: "Bluetooth"
                            subtitle: !(root.btAdapter?.enabled ?? false) ? "Off" : root.btConnected.length ? root.btConnected[0].name : "On"
                            checked: root.btAdapter?.enabled ?? false
                            // Icon: on/off. Rest: devices (BluetoothDetail.qml).
                            hasDetail: true
                            onIconClicked: if (root.btAdapter)
                                root.btAdapter.enabled = !root.btAdapter.enabled
                            onClicked: Notifs.centerDetail = "bluetooth"
                        }
                    }

                    Tile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true

                        ControlToggle {
                            icon: "do_not_disturb_on"
                            title: "Do Not Disturb"
                            subtitle: Notifs.dnd ? Notifs.dndReason : Notifs.dndScheduleOn ? `Off · from ${Notifs.clockText(Notifs.dndFrom)}` : "Off"
                            checked: Notifs.dnd
                            // Icon: on/off. Rest: schedule + screen sharing.
                            hasDetail: true
                            onIconClicked: Notifs.toggleDnd()
                            onClicked: Notifs.centerDetail = "dnd"
                        }

                        // Icon: on/off. Rest of the tile: duration options.
                        ControlToggle {
                            icon: "coffee"
                            title: "Keep Awake"
                            subtitle: Caffeine.active ? Caffeine.remainingText : Caffeine.autoActive ? `Auto · ${Caffeine.autoReason || "ending soon"}` : "Off"
                            checked: Caffeine.inhibiting
                            hasDetail: true
                            onIconClicked: Caffeine.toggle()
                            onClicked: Notifs.centerDetail = "caffeine"
                        }
                    }
                }

                // Brightness (laptops) + night light (NightLight.qml / hyprsunset).
                Tile {
                    width: parent.width
                    spacing: 8

                    RowLayout {
                        width: parent.width

                        // "Display ›": scale / resolution (DisplayDetail.qml).
                        MouseArea {
                            id: displayHeading
                            Layout.fillWidth: true
                            implicitHeight: 24
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifs.centerDetail = "display"

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                SectionLabel {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Display"
                                    color: displayHeading.containsMouse ? Theme.foreground : Theme.foregroundDim
                                }

                                Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: "chevron_right"
                                    size: 16
                                    color: displayHeading.containsMouse ? Theme.foreground : Theme.foregroundDim
                                }
                            }
                        }

                        // Night light toggle pill (› next to it: schedule etc.).
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

                        // Night light options (NightLightDetail.qml).
                        MouseArea {
                            id: nightMore
                            implicitWidth: 24
                            implicitHeight: 24
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifs.centerDetail = "nightlight"

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: nightMore.containsMouse ? Theme.glassTileHover : "transparent"
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "chevron_right"
                                size: 16
                                color: Theme.foregroundDim
                            }
                        }
                    }

                    Slider {
                        width: parent.width
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
                        width: parent.width
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

                    // "Sound ›": devices, balance, meters… (SoundDetail.qml).
                    MouseArea {
                        id: soundHeading
                        width: parent.width
                        implicitHeight: 22
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.centerDetail = "sound"

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            SectionLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Sound"
                                color: soundHeading.containsMouse ? Theme.foreground : Theme.foregroundDim
                            }

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "chevron_right"
                                size: 16
                                color: soundHeading.containsMouse ? Theme.foreground : Theme.foregroundDim
                            }
                        }
                    }

                    Slider {
                        width: parent.width
                        icon: (root.sink?.audio.muted ?? false) ? "volume_off" : "volume_up"
                        value: root.sink?.audio.volume ?? 0
                        onMoved: v => {
                            root.sink.audio.muted = false;
                            root.sink.audio.volume = v;
                        }
                    }
                }

                // ---- session: lock / sleep / power (detail view) ----
                SessionTile {
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

        // ---- detail view ----
        // Slides in over the whole center: back button + title + the
        // control's options (detailPages below). Esc or ← goes back.
        Item {
            id: detailView

            readonly property var page: root.detailPages[Notifs.centerDetail] ?? null

            anchors.fill: parent
            anchors.margins: content.padding
            implicitHeight: detailHeader.implicitHeight + 12 + detailLoader.implicitHeight
            visible: opacity > 0
            opacity: root.showingDetail ? 1 : 0
            transform: Translate {
                x: root.showingDetail ? 0 : 60
                Behavior on x {
                    NumberAnimation {
                        duration: Theme.ms(240)
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.ms(200)
                }
            }

            RowLayout {
                id: detailHeader
                width: parent.width
                spacing: 8

                MouseArea {
                    id: back
                    implicitWidth: 32
                    implicitHeight: 32
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.centerDetail = ""

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: back.containsMouse ? Theme.glassTileHover : Theme.glassTile
                        border.width: 1
                        border.color: Theme.glassBorder
                    }

                    Icon {
                        anchors.centerIn: parent
                        name: "arrow_back"
                        size: 18
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: detailView.page?.title ?? ""
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }
            }

            Loader {
                id: detailLoader
                y: detailHeader.implicitHeight + 12
                width: parent.width
                // Keep the last page while sliding out.
                active: !!detailView.page || detailView.visible
                sourceComponent: detailView.page?.component ?? lastComponent
                property Component lastComponent: null
                onSourceComponentChanged: if (sourceComponent)
                    lastComponent = sourceComponent
            }
        }
    }

    // Detail views, by Notifs.centerDetail key.
    readonly property bool showingDetail: open && !!detailPages[Notifs.centerDetail]
    readonly property var detailPages: ({
            caffeine: {
                title: "Keep Awake",
                component: caffeineDetail
            },
            power: {
                title: "Power",
                component: powerDetail
            },
            dnd: {
                title: "Do Not Disturb",
                component: dndDetail
            },
            nightlight: {
                title: "Night Light",
                component: nightLightDetail
            },
            display: {
                title: "Display",
                component: displayDetail
            },
            sound: {
                title: "Sound",
                component: soundDetail
            },
            wifi: {
                title: "Wi-Fi",
                component: wifiDetail
            },
            bluetooth: {
                title: "Bluetooth",
                component: bluetoothDetail
            }
        })

    Component {
        id: soundDetail
        SoundDetail {}
    }

    Component {
        id: wifiDetail
        WifiDetail {}
    }

    Component {
        id: bluetoothDetail
        BluetoothDetail {}
    }

    Component {
        id: nightLightDetail
        NightLightDetail {}
    }

    Component {
        id: displayDetail
        DisplayDetail {}
    }

    Component {
        id: dndDetail
        DndDetail {}
    }

    Component {
        id: caffeineDetail
        CaffeineDetail {}
    }

    Component {
        id: powerDetail
        PowerDetail {}
    }
}
