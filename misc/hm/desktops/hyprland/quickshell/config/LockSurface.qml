import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

// macOS-style lock screen: blurred wallpaper, big date/time on top, avatar +
// password field below, battery at the bottom.
//
// Deliberately offers nothing but unlocking: no power actions, media
// controls or anything else that would act on the session while locked.
Item {
    id: root

    required property var context

    readonly property string home: Quickshell.env("HOME")
    readonly property string user: Quickshell.env("USER")
    property string fullName: ""

    // Fade in when the lock appears.
    opacity: 0
    Component.onCompleted: {
        fadeIn.start();
        password.forceActiveFocus();
    }
    NumberAnimation {
        id: fadeIn
        target: root
        property: "opacity"
        to: 1
        duration: 350
        easing.type: Easing.OutCubic
    }

    // Real name from the passwd GECOS field, if set.
    Process {
        running: true
        command: ["getent", "passwd", root.user]
        stdout: SplitParser {
            onRead: line => {
                const gecos = (line.split(":")[4] || "").split(",")[0];
                if (gecos)
                    root.fullName = gecos;
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // ---- background ----
    // The picture is a plain Image filling the screen (cropped, never
    // stretched), shown as-is. Once engaged, a blurred copy fades in on top:
    // a second Image of the same file (decoded once, via Qt's image cache)
    // blurred with a layer effect, i.e. Qt blurs what that Image itself
    // renders. (A separate hidden capture could grab the texture before the
    // async load finished and blur leftover garbage.)
    // (Same picture as the login screen: assets/images/wallpapers/lockscreen.png.)
    Image {
        id: wallpaper
        anchors.fill: parent
        source: `file://${root.home}/Pictures/Wallpapers/lockscreen.png`
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
    }

    // Blurred, slightly dimmed copy: fades in once the user starts unlocking.
    Image {
        anchors.fill: parent
        source: wallpaper.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        opacity: root.context.engaged ? 1 : 0
        visible: opacity > 0 && status === Image.Ready

        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            // Keep the blur within the screen (no dark/see-through edges).
            autoPaddingEnabled: false
            blurEnabled: true
            blurMax: 64
            blur: 1.0
            brightness: -0.05
            saturation: 0.15
        }
    }

    // Light scrim at rest (keeps the clock legible), darker when engaged.
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.context.engaged ? 0.12 : 0.08

        Behavior on opacity {
            NumberAnimation {
                duration: 350
            }
        }
    }

    // ---- date + time ----
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.1
        spacing: -8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
            font.family: Theme.font
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: Qt.rgba(1, 1, 1, 0.85)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.family: Theme.font
            font.pixelSize: 120
            font.weight: Font.Bold
            color: Qt.rgba(1, 1, 1, 0.92)
        }
    }

    // ---- user + password ----
    Column {
        id: login
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.6
        spacing: 12

        // Avatar: ~/.face if present, else the user's initial.
        ClippingRectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 84
            height: 84
            radius: 42
            color: Qt.rgba(1, 1, 1, 0.18)

            Image {
                id: face
                anchors.fill: parent
                source: `file://${root.home}/.face`
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: face.status !== Image.Ready
                text: (root.fullName || root.user || "?").charAt(0).toUpperCase()
                font.family: Theme.font
                font.pixelSize: 36
                font.weight: Font.DemiBold
                color: "white"
            }

            // Click the avatar to start unlocking.
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.context.engage();
                    password.forceActiveFocus();
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.fullName || root.user
            font.family: Theme.font
            font.pixelSize: 17
            font.weight: Font.DemiBold
            color: "white"
        }

        // Password pill (shakes on failure).
        Rectangle {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: 260
            height: 38
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.16)
            border.width: 1
            border.color: root.context.error ? Qt.rgba(0.93, 0.33, 0.59, 0.8) : Qt.rgba(1, 1, 1, 0.25)

            // Hidden at rest but still focused, so the first keystroke lands
            // here (and engages the lock screen).
            opacity: root.context.engaged ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }

            transform: Translate {
                id: shake
                y: root.context.engaged ? 0 : 10

                Behavior on y {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }
            }

            SequentialAnimation {
                id: shakeAnim
                loops: 1
                NumberAnimation {
                    target: shake
                    property: "x"
                    to: -14
                    duration: 50
                }
                NumberAnimation {
                    target: shake
                    property: "x"
                    to: 14
                    duration: 80
                }
                NumberAnimation {
                    target: shake
                    property: "x"
                    to: -8
                    duration: 70
                }
                NumberAnimation {
                    target: shake
                    property: "x"
                    to: 0
                    duration: 60
                }
            }

            Connections {
                target: root.context
                function onFailed() {
                    shakeAnim.restart();
                }
            }

            TextInput {
                id: password
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 40
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "●"
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 1
                color: "white"
                clip: true
                focus: true
                enabled: !root.context.busy

                // Shared across monitors via the context.
                text: root.context.currentText
                onTextChanged: root.context.currentText = text

                onAccepted: root.context.tryUnlock()
                // Esc clears; Esc on an empty field goes back to the clear wallpaper.
                Keys.onEscapePressed: {
                    if (root.context.currentText === "")
                        root.context.disengage();
                    else
                        root.context.currentText = "";
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !password.text && !root.context.busy
                    text: "Enter Password"
                    font: password.font
                    color: Qt.rgba(1, 1, 1, 0.55)
                }
            }

            // Submit arrow / busy spinner.
            MouseArea {
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                cursorShape: Qt.PointingHandCursor
                enabled: root.context.engaged
                onClicked: root.context.tryUnlock()

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(1, 1, 1, 0.22)
                    visible: password.text !== "" || root.context.busy
                }

                Icon {
                    id: submitIcon
                    anchors.centerIn: parent
                    visible: password.text !== "" || root.context.busy
                    name: root.context.busy ? "progress_activity" : "arrow_forward"
                    size: 18
                    color: "white"

                    RotationAnimation on rotation {
                        running: root.context.busy
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 900
                    }
                }
            }
        }

        // Hint / status line, with a fingerprint icon while the reader listens.
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Icon {
                id: fingerprintIcon
                anchors.verticalCenter: parent.verticalCenter
                visible: root.context.fingerprintReady
                name: "fingerprint"
                size: 18
                color: root.context.error ? Theme.urgent : Qt.rgba(1, 1, 1, 0.75)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    const c = root.context;
                    if (!c.engaged)
                        return c.fingerprintReady ? "Touch the fingerprint sensor or start typing" : "Click or start typing to unlock";
                    if (c.error)
                        return c.error;
                    if (c.busy)
                        return "Checking…";
                    // pam_fprintd feedback, e.g. "Failed to match fingerprint".
                    if (c.fingerprintReady && c.fingerprintMessage && !/place|swipe/i.test(c.fingerprintMessage))
                        return c.fingerprintMessage;
                    return c.fingerprintReady ? "Touch the fingerprint sensor or enter your password" : "Touch your YubiKey or enter your password";
                }
                font.family: Theme.font
                font.pixelSize: Theme.fontSize - 1
                color: root.context.error ? Theme.urgent : Qt.rgba(1, 1, 1, 0.6)
            }
        }
    }


    // ---- bottom-right: battery ----
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 32
        spacing: 6
        visible: Battery.present

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: Battery.icon
            filled: true
            color: Battery.low ? Theme.urgent : "white"
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${Math.round(Battery.percent * 100)}%` + (Battery.shortEstimate ? `  ·  ${Battery.shortEstimate}` : "")
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            color: "white"
        }
    }
}
