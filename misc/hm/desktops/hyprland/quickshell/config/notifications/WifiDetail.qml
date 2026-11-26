import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Networking
import qs.common
import qs.services
import qs.components

// Wi-Fi detail view of the notification center (fuller than the bar's
// network menu): the current connection's details (signal, band, speed,
// security, IP, gateway, DNS, MAC) with Disconnect / Forget; saved networks
// with "connect automatically" and Forget; joining a hidden network.
// Details come from nmcli, refreshed every 5 s while the view is open.
ColumnLayout {
    id: root

    spacing: 12

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var current: wifi?.networks.values.find(n => n.connected) ?? null

    // From nmcli.
    property var info: ({}) // GENERAL.* / IP4.* fields
    property var link: null // { ssid, freq, rate, signal, security }
    property var saved: [] // [{ name, autoconnect, uuid, active }]

    property bool joinOpen: false

    // nmcli -t escapes ":" inside values as "\:".
    function fields(line) {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[++i];
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }
        out.push(cur);
        return out;
    }

    function band(freq) {
        const f = parseInt(freq);
        return f >= 5925 ? "6 GHz" : f >= 4900 ? "5 GHz" : f > 0 ? "2.4 GHz" : "";
    }

    function nm(args) {
        Quickshell.execDetached(["nmcli", ...args]);
        refreshSoon.restart();
    }

    Timer {
        id: refreshSoon
        interval: 1200
        onTriggered: reader.running = true
    }

    Timer {
        running: Notifs.centerOpen && Notifs.centerDetail === "wifi"
        interval: 5000
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!reader.running)
            reader.running = true
    }

    Process {
        id: reader
        command: ["sh", "-c", `
            dev=$1
            [ -n "$dev" ] && nmcli -t -f GENERAL.CONNECTION,GENERAL.HWADDR,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS device show "$dev" 2>/dev/null
            echo "@@"
            [ -n "$dev" ] && nmcli -t -f IN-USE,SSID,FREQ,RATE,SIGNAL,SECURITY device wifi list ifname "$dev" --rescan no 2>/dev/null | grep '^\\*'
            echo "@@"
            nmcli -t -f NAME,TYPE,AUTOCONNECT,UUID,ACTIVE connection show 2>/dev/null | grep ':802-11-wireless:'
        `, "sh", root.wifi?.name ?? ""]
        stdout: StdioCollector {
            onStreamFinished: {
                const [a, b, c] = text.split("@@\n");
                const info = {};
                for (const l of (a ?? "").split("\n")) {
                    const i = l.indexOf(":");
                    if (i < 0)
                        continue;
                    const k = l.slice(0, i).replace(/\[\d+\]$/, "");
                    const v = l.slice(i + 1);
                    info[k] = info[k] ? `${info[k]}, ${v}` : v;
                }
                root.info = info;
                const w = (b ?? "").split("\n").find(l => l.startsWith("*"));
                if (w) {
                    const f = root.fields(w);
                    root.link = {
                        ssid: f[1],
                        freq: f[2],
                        rate: f[3],
                        signal: f[4],
                        security: f[5]
                    };
                } else {
                    root.link = null;
                }
                root.saved = (c ?? "").split("\n").filter(l => l).map(l => {
                    const f = root.fields(l);
                    return {
                        name: f[0],
                        autoconnect: f[2] === "yes",
                        uuid: f[3],
                        active: f[4] === "yes"
                    };
                }).sort((x, y) => (y.active - x.active) || x.name.localeCompare(y.name));
            }
        }
    }

    // ---- switch ----
    Tile {
        Layout.fillWidth: true

        SwitchRow {
            icon: Networking.wifiEnabled ? "wifi" : "wifi_off"
            label: "Wi-Fi"
            detail: !Networking.wifiEnabled ? "Off" : root.current ? `Connected to ${root.current.name}` : "Not connected"
            checked: Networking.wifiEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    // ---- current connection ----
    Tile {
        visible: !!root.current
        Layout.fillWidth: true
        spacing: 10

        RowLayout {
            width: parent.width
            spacing: 10

            Icon {
                name: "wifi"
                size: 20
                color: Theme.accent
            }

            Text {
                Layout.fillWidth: true
                text: root.current?.name ?? ""
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            PillButton {
                text: "Disconnect"
                onClicked: root.current?.disconnect()
            }

            PillButton {
                text: "Forget"
                onClicked: {
                    root.current?.forget();
                    refreshSoon.restart();
                }
            }
        }

        GridLayout {
            width: parent.width
            columns: 2
            columnSpacing: 12
            rowSpacing: 4

            Repeater {
                model: [
                    ["Signal", root.link ? `${root.link.signal}%` : ""],
                    ["Band", root.link ? root.band(root.link.freq) : ""],
                    ["Speed", root.link?.rate ?? ""],
                    ["Security", root.link?.security || (root.link ? "Open" : "")],
                    ["IP address", (root.info["IP4.ADDRESS"] ?? "").replace(/\/\d+/g, "")],
                    ["Gateway", root.info["IP4.GATEWAY"] ?? ""],
                    ["DNS", root.info["IP4.DNS"] ?? ""],
                    ["MAC address", root.info["GENERAL.HWADDR"] ?? ""]
                ].filter(r => r[1])

                Item {
                    required property var modelData
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    implicitHeight: 20

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: parent.modelData[0]
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, parent.width - 110)
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                        text: parent.modelData[1]
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        font.features: {
                            "tnum": 1
                        }
                        color: Theme.foreground
                    }
                }
            }
        }
    }

    // ---- saved networks ----
    Text {
        visible: root.saved.length > 0
        Layout.leftMargin: 4
        text: `Saved networks (${root.saved.length})`
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 2
        font.weight: Font.DemiBold
        color: Theme.foregroundDim
    }

    Tile {
        visible: root.saved.length > 0
        Layout.fillWidth: true
        spacing: 2

        Repeater {
            model: root.saved

            RowLayout {
                id: savedRow
                required property var modelData
                width: parent.width
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: savedRow.modelData.name
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: savedRow.modelData.active ? Font.DemiBold : Font.Normal
                        color: Theme.foreground
                    }

                    Text {
                        text: savedRow.modelData.active ? "Connected" : savedRow.modelData.autoconnect ? "Connects automatically" : "Manual"
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }
                }

                PillButton {
                    visible: !savedRow.modelData.active
                    text: "Connect"
                    onClicked: root.nm(["connection", "up", "uuid", savedRow.modelData.uuid])
                }

                // Connect automatically.
                Toggle {
                    checked: savedRow.modelData.autoconnect
                    onToggled: root.nm(["connection", "modify", "uuid", savedRow.modelData.uuid, "connection.autoconnect", savedRow.modelData.autoconnect ? "no" : "yes"])
                }

                PillButton {
                    icon: "delete"
                    onClicked: root.nm(["connection", "delete", "uuid", savedRow.modelData.uuid])
                }
            }
        }

        Text {
            width: parent.width
            topPadding: 4
            wrapMode: Text.WordWrap
            text: "The switch is \"connect automatically\"; 🗑 forgets the network."
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 3
            color: Theme.foregroundDim
        }
    }

    // ---- hidden network ----
    Tile {
        Layout.fillWidth: true
        spacing: 8

        MouseArea {
            id: joinHeader
            width: parent.width
            implicitHeight: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.joinOpen = !root.joinOpen

            RowLayout {
                anchors.fill: parent

                Icon {
                    name: "wifi_add"
                    size: 17
                    color: Theme.foregroundDim
                }

                Text {
                    Layout.fillWidth: true
                    text: "Join a hidden network"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.foreground
                }

                Icon {
                    name: root.joinOpen ? "expand_less" : "expand_more"
                    size: 18
                    color: Theme.foregroundDim
                }
            }
        }

        Field {
            id: ssidField
            visible: root.joinOpen
            placeholder: "Network name (SSID)"
        }

        Field {
            id: passField
            visible: root.joinOpen
            placeholder: "Password (leave empty if open)"
            secret: true
        }

        RowLayout {
            visible: root.joinOpen
            width: parent.width

            Item {
                Layout.fillWidth: true
            }

            PillButton {
                text: "Join"
                enabled: ssidField.text.length > 0
                onClicked: {
                    const args = ["device", "wifi", "connect", ssidField.text];
                    if (passField.text)
                        args.push("password", passField.text);
                    args.push("hidden", "yes");
                    if (root.wifi)
                        args.push("ifname", root.wifi.name);
                    root.nm(args);
                    passField.text = "";
                    root.joinOpen = false;
                }
            }
        }
    }

    // Text field in the center's style.
    component Field: Rectangle {
        id: field

        property string placeholder
        property bool secret: false
        property alias text: input.text

        width: parent ? parent.width : 0
        height: 32
        radius: height / 2
        color: Theme.surfaceHigh
        border.width: 1
        border.color: input.activeFocus ? Theme.accent : "transparent"

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: TextInput.AlignVCenter
            echoMode: field.secret ? TextInput.Password : TextInput.Normal
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foreground
            clip: true

            Text {
                visible: !input.text
                anchors.verticalCenter: parent.verticalCenter
                text: field.placeholder
                font: input.font
                color: Theme.foregroundDim
            }
        }
    }
}
