import QtQuick
import Quickshell.Networking
import qs.common
import qs.components

// A Wi-Fi network row. Unknown secured networks expand into a password field.
Column {
    id: root

    required property var network
    property string signalIcon: "wifi"
    property bool askPassword: false

    readonly property bool secured: network.security !== WifiSecurityType.Open
    readonly property bool busy: network.stateChanging

    width: parent ? parent.width : 0

    Connections {
        target: root.network
        function onConnectionFailed(reason) {
            if (reason === ConnectionFailReason.NoSecrets && root.secured)
                root.askPassword = true;
        }
        function onConnectedChanged() {
            if (root.network.connected)
                root.askPassword = false;
        }
    }

    MenuItem {
        icon: root.signalIcon
        label: root.network.name
        highlighted: root.network.connected
        detail: root.busy ? "…" : root.network.connected ? "Connected" : root.network.known ? "Saved" : ""
        onClicked: {
            if (root.network.connected)
                root.network.disconnect();
            else if (!root.network.known && root.secured)
                root.askPassword = !root.askPassword;
            else
                root.network.connect();
        }

        Icon {
            visible: root.secured && !root.network.known && !root.network.connected
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            name: "lock"
            size: 14
            color: Theme.foregroundDim
        }
    }

    Rectangle {
        visible: root.askPassword
        width: parent.width
        height: 34
        radius: Theme.radius - 4
        color: Theme.surface
        border.width: 1
        border.color: password.activeFocus ? Theme.accent : Theme.surfaceHigh

        onVisibleChanged: if (visible)
            password.forceActiveFocus()

        TextInput {
            id: password
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: Theme.foreground
            clip: true

            onAccepted: {
                root.network.connectWithPsk(text);
                text = "";
            }
            Keys.onEscapePressed: root.askPassword = false

            Text {
                visible: !password.text
                anchors.verticalCenter: parent.verticalCenter
                text: "Password"
                font: password.font
                color: Theme.foregroundDim
            }
        }
    }
}
