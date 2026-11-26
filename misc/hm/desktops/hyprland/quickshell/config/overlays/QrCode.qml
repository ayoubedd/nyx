import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common
import qs.services

// Shows text as a QR code to scan with a phone (qrencode):
//
//   qs -c nyx ipc call qr clipboard          the clipboard's text
//   qs -c nyx ipc call qr text "hello"       any text
//   qs -c nyx ipc call qr entry "<cliphist line>"   a clipboard history entry
//
// Also from the launcher ("Show Clipboard as QR Code", and Ctrl+K on a
// clipboard entry). Esc, click outside or the ✕ closes it.
Scope {
    id: root

    property bool open: false
    property string preview: ""
    property string error: ""
    property real stamp: 0

    readonly property string file: `${Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"}/nyx-qr.png`

    function show(kind, value) {
        Ui.closeAll();
        Notifs.centerOpen = false;
        preview = "";
        error = "";
        encoder.command = ["sh", "-c", script, "sh", kind, value ?? "", file];
        encoder.running = true;
    }

    function close() {
        open = false;
    }

    // $1 clipboard|text|entry  $2 the text / cliphist line  $3 output png.
    // Prints "OK <preview>" or "ERR <reason>".
    readonly property string script: `
        case "$1" in
            clipboard) t=$(wl-paste -n -t text/plain 2>/dev/null || wl-paste -n 2>/dev/null) ;;
            entry) t=$(printf '%s\\n' "$2" | cliphist decode 2>/dev/null) ;;
            *) t=$2 ;;
        esac
        [ -n "$t" ] || { echo "ERR empty"; exit 0; }
        # A QR code holds at most 2953 bytes (largest size, lowest error
        # correction). Use medium correction (sturdier scans) while it fits,
        # i.e. up to 2331 bytes, and low beyond that.
        n=$(printf '%s' "$t" | wc -c)
        [ "$n" -le 2953 ] || { echo "ERR long"; exit 0; }
        level=M
        [ "$n" -le 2331 ] || level=L
        printf '%s' "$t" | qrencode -o "$3" -s 12 -m 2 -l "$level" || { echo "ERR encode"; exit 0; }
        printf 'OK %s' "$(printf '%s' "$t" | head -c 400 | tr '\\n\\t' '  ')"
    `

    Process {
        id: encoder
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                if (out.startsWith("OK")) {
                    root.preview = out.slice(3);
                    root.error = "";
                } else {
                    root.error = out.includes("long") ? "Too long for a QR code (2,953 bytes at most; non-Latin letters and emoji count double or more)." : out.includes("empty") ? "Nothing to show: the clipboard has no text." : "Couldn't make a QR code (is qrencode installed? rebuild).";
                }
                root.stamp = Date.now();
                root.open = true;
            }
        }
    }

    IpcHandler {
        target: "qr"

        function clipboard(): void {
            root.show("clipboard", "");
        }
        function text(value: string): void {
            root.show("text", value);
        }
        function entry(line: string): void {
            root.show("entry", line);
        }
        function close(): void {
            root.close();
        }
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
            WlrLayershell.namespace: "nyx-qr"
            WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            color: "transparent"
            implicitWidth: 420
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

            Item {
                id: keys
                focus: true
                Keys.onEscapePressed: root.close()
            }

            Rectangle {
                id: card
                width: parent.width
                implicitHeight: body.implicitHeight + 40
                radius: 20
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

                ColumnLayout {
                    id: body
                    x: 20
                    y: 20
                    width: parent.width - 40
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: root.error ? "No QR code" : "Scan with your phone"
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize + 2
                            font.weight: Font.DemiBold
                            color: Theme.foreground
                        }

                        MouseArea {
                            id: closeButton
                            implicitWidth: 30
                            implicitHeight: 30
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: closeButton.containsMouse ? Theme.surfaceHigh : "transparent"
                            }

                            Icon {
                                anchors.centerIn: parent
                                name: "close"
                                size: 18
                            }
                        }
                    }

                    // The code, on white (scanners need the contrast).
                    Rectangle {
                        visible: !root.error
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 340
                        implicitHeight: 340
                        radius: 12
                        color: "white"

                        Image {
                            anchors.fill: parent
                            anchors.margins: 10
                            source: root.open && !root.error ? `file://${root.file}?${root.stamp}` : ""
                            cache: false
                            fillMode: Image.PreserveAspectFit
                            smooth: false // keep the modules crisp
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        text: root.error || root.preview
                        font.family: root.error ? Theme.font : "monospace"
                        font.pixelSize: Theme.fontSize - 2
                        color: root.error ? Theme.urgent : Theme.foregroundDim
                    }
                }
            }
        }
    }
}
