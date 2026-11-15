import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.common
import qs.components

// A Wi-Fi network in the network menu:
//   (signal)  Name                         🔒
//             Saved · WPA2
// Click: connect (unknown secured networks first ask for a password).
// Known networks show a "forget" button on hover.
Column {
    id: root

    required property var network
    property string signalIcon: "wifi"
    property bool askPassword: false
    property string error: ""

    readonly property bool secured: network.security !== WifiSecurityType.Open
    readonly property bool busy: network.stateChanging

    function securityName(t) {
        switch (t) {
        case WifiSecurityType.Open:
            return "Open";
        case WifiSecurityType.Sae:
        case WifiSecurityType.Wpa3SuiteB192:
            return "WPA3";
        case WifiSecurityType.Wpa2Psk:
        case WifiSecurityType.Wpa2Eap:
            return "WPA2";
        case WifiSecurityType.WpaPsk:
        case WifiSecurityType.WpaEap:
            return "WPA";
        case WifiSecurityType.StaticWep:
        case WifiSecurityType.DynamicWep:
            return "WEP";
        default:
            return "Secured";
        }
    }

    function showError(text) {
        error = text;
        clearError.restart();
    }

    function submit() {
        if (!password.text)
            return;
        error = "";
        root.network.connectWithPsk(password.text);
        password.text = "";
    }

    width: parent ? parent.width : 0
    spacing: 4

    Timer {
        id: clearError
        interval: 5000
        onTriggered: root.error = ""
    }

    Connections {
        target: root.network
        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets && root.secured) {
                if (root.askPassword || root.network.known)
                    root.showError("Wrong password");
                root.askPassword = true;
            } else {
                root.showError("Couldn't connect");
            }
        }
        function onConnectedChanged() {
            if (root.network.connected) {
                root.askPassword = false;
                root.error = "";
            }
        }
    }

    MouseArea {
        id: row
        width: parent.width
        implicitHeight: 40
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.busy)
                return;
            if (!root.network.known && root.secured)
                root.askPassword = !root.askPassword;
            else
                root.network.connect();
        }

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: 10
            color: row.containsMouse || root.askPassword ? Theme.surfaceHigh : "transparent"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 15
                color: Theme.surfaceHigh

                Icon {
                    anchors.centerIn: parent
                    name: root.signalIcon
                    filled: true
                    size: 16
                    color: Theme.foreground
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: root.network.name
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.Medium
                    color: Theme.foreground
                }

                Text {
                    Layout.fillWidth: true
                    text: root.busy ? "Connecting…" : root.error ? root.error : [root.network.known ? "Saved" : "", root.securityName(root.network.security)].filter(s => s).join(" · ")
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 3
                    color: root.error && !root.busy ? Theme.urgent : Theme.foregroundDim
                }
            }

            // Forget (saved networks, on hover).
            MouseArea {
                id: forget
                visible: root.network.known && row.containsMouse && !root.busy
                implicitWidth: 24
                implicitHeight: 24
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.network.forget()

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: forget.containsMouse ? Theme.muted : "transparent"
                }

                Icon {
                    anchors.centerIn: parent
                    name: "close"
                    size: 15
                    color: Theme.foregroundDim
                }
            }

            Icon {
                visible: root.secured && !forget.visible
                name: "lock"
                size: 14
                color: Theme.foregroundDim
            }
        }
    }

    // Password field (unknown secured networks).
    Rectangle {
        visible: root.askPassword
        width: parent.width
        height: 34
        radius: height / 2
        color: Theme.surfaceHigh
        border.width: 1
        border.color: password.activeFocus ? Theme.accent : "transparent"

        onVisibleChanged: if (visible)
            password.forceActiveFocus()

        TextInput {
            id: password
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 40
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foreground
            clip: true

            onAccepted: root.submit()
            Keys.onEscapePressed: root.askPassword = false

            Text {
                visible: !password.text
                anchors.verticalCenter: parent.verticalCenter
                text: "Password"
                font: password.font
                color: Theme.foregroundDim
            }
        }

        // Join button.
        MouseArea {
            id: join
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26
            enabled: password.text.length > 0
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.submit()

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: join.enabled ? Theme.accent : Theme.muted
            }

            Icon {
                anchors.centerIn: parent
                name: "arrow_forward"
                size: 15
                color: join.enabled ? Theme.background : Theme.foregroundDim
            }
        }
    }
}
