import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd

// Login screen, styled like the lock screen (LockSurface.qml).
//
// Config comes from the wrapper script's environment:
//   NYX_GREETER_USER          username shown by default
//   NYX_GREETER_SESSIONS_DIR  wayland-sessions/*.desktop to offer
//   NYX_GREETER_SESSION_NAME  default session (by Name=)
//   NYX_GREETER_SESSION       JSON command, fallback if no sessions are found
//   NYX_GREETER_STATE         writable dir; remembers the last session
//   NYX_GREETER_LAUNCHED      marker touched right before launching
//   NYX_GREETER_WALLPAPER     background image path
//
// Flow: Enter -> Greetd.createSession(user); PAM prompts that need an answer
// get the typed password, info messages (e.g. "touch your security key") are
// shown; readyToLaunch -> remember the session, touch the marker, launch the
// session and quit (cage then exits and greetd starts the session).
FloatingWindow {
    id: root

    readonly property string defaultUser: Quickshell.env("NYX_GREETER_USER") ?? ""
    readonly property var fallbackCommand: JSON.parse(Quickshell.env("NYX_GREETER_SESSION") || '["Hyprland"]')
    readonly property string defaultSessionName: Quickshell.env("NYX_GREETER_SESSION_NAME") || ""
    readonly property string sessionsDir: Quickshell.env("NYX_GREETER_SESSIONS_DIR") ?? ""
    readonly property string stateDir: Quickshell.env("NYX_GREETER_STATE") ?? ""
    readonly property string launchedMarker: Quickshell.env("NYX_GREETER_LAUNCHED") ?? ""
    readonly property string wallpaperPath: Quickshell.env("NYX_GREETER_WALLPAPER") ?? ""

    // [{ name, exec }] from the .desktop files; `sessionIndex` is the choice.
    property var sessions: []
    property int sessionIndex: 0
    property bool sessionMenuOpen: false
    readonly property var session: sessions[sessionIndex] ?? null
    readonly property string sessionName: session?.name ?? (defaultSessionName || "Hyprland")
    // Exec= as a plain argv (like the fallback command): field codes (%U, …)
    // dropped, split into words, "quoted args" kept together. Not wrapped in
    // `sh -c`: greetd already runs the command through /bin/sh (to source the
    // profile) and the nested command string doesn't survive that, so the
    // session would exit immediately.
    function argv(exec) {
        return (exec.replace(/\s*%[a-zA-Z]/g, "").match(/"[^"]*"|\S+/g) ?? []).map(w => w.replace(/^"(.*)"$/, "$1"));
    }
    readonly property var sessionCommand: session && argv(session.exec).length > 0 ? argv(session.exec) : fallbackCommand

    // Read the installed sessions and the last choice.
    Process {
        id: listSessions
        command: ["sh", "-c", `
            for f in "$1"/*.desktop; do
                [ -e "$f" ] || continue
                n=$(sed -n 's/^Name=//p' "$f" | head -1)
                e=$(sed -n 's/^Exec=//p' "$f" | head -1)
                [ -n "$e" ] && printf 'S\\t%s\\t%s\\n' "$n" "$e"
            done
            [ -r "$2/last-session" ] && printf 'L\\t%s\\n' "$(cat "$2/last-session")"
        `, "sh", root.sessionsDir, root.stateDir]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = [];
                let last = "";
                for (const line of text.split("\n")) {
                    const f = line.split("\t");
                    if (f[0] === "S" && f.length >= 3)
                        found.push({
                            name: f[1] || f[2],
                            exec: f.slice(2).join("\t")
                        });
                    else if (f[0] === "L")
                        last = f[1];
                }
                root.sessions = found;
                const pick = [last, root.defaultSessionName].map(n => found.findIndex(s => s.name === n)).find(i => i >= 0);
                root.sessionIndex = pick ?? 0;
            }
        }
    }

    // Remember the session and mark "launched" before handing over: cage may
    // crash on its way out, and the wrapper must not fall back to tuigreet.
    Process {
        id: prepareLaunch
        command: ["sh", "-c", `
            [ -n "$1" ] && [ -d "$1" ] && printf '%s' "$2" > "$1/last-session"
            [ -n "$3" ] && touch "$3"
            exit 0
        `, "sh", root.stateDir, root.sessionName, root.launchedMarker]
        // quit = true: exit once launched so greetd can start the session.
        onExited: Greetd.launch(root.sessionCommand, [], true)
    }

    property string user: defaultUser
    property bool editingUser: defaultUser === ""
    property bool engaged: editingUser
    property bool busy: false
    property bool launching: false
    property string info: ""
    property string error: ""

    function login() {
        if (busy || launching)
            return;
        if (!user) {
            editingUser = true;
            userInput.forceActiveFocus();
            return;
        }
        engaged = true;
        busy = true;
        error = "";
        info = "";
        Greetd.createSession(user);
    }

    function fail(message) {
        busy = false;
        password.text = "";
        error = message;
        shakeAnim.restart();
        if (Greetd.state !== GreetdState.Inactive)
            Greetd.cancelSession();
    }

    color: Theme.background

    Connections {
        target: Greetd

        function onAuthMessage(message, isError, responseRequired, echoResponse) {
            if (responseRequired) {
                // Answer every prompt with what was typed; the field is
                // cleared when the attempt ends (fail / launch), so a second
                // prompt doesn't get an empty answer.
                Greetd.respond(password.text);
            } else if (isError) {
                root.error = message;
            } else {
                root.info = message;
            }
        }

        function onAuthFailure(message) {
            root.fail(message || "Incorrect password");
        }

        function onReadyToLaunch() {
            root.launching = true;
            password.text = "";
            root.info = `Starting ${root.sessionName}…`;
            prepareLaunch.running = true; // then Greetd.launch (onExited)
        }

        function onError(err) {
            root.fail(err);
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function focusInput() {
        if (editingUser)
            userInput.forceActiveFocus();
        else
            password.forceActiveFocus();
    }

    Component.onCompleted: {
        listSessions.running = true;
        focusInput();
    }

    // cage may activate the window a moment after it maps; grab focus again
    // so the first keystrokes of the password aren't lost.
    Timer {
        running: true
        interval: 400
        onTriggered: root.focusInput()
    }

    // ---- background ----
    // The picture is a plain Image filling the screen (cropped, never
    // stretched), shown as-is. Once engaged, a blurred copy fades in on top:
    // a second Image of the same file (decoded once, via Qt's image cache)
    // blurred with a layer effect, i.e. Qt blurs what that Image itself
    // renders. (A separate hidden capture could grab the texture before the
    // async load finished and blur leftover garbage.)
    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.wallpaperPath ? `file://${root.wallpaperPath}` : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
    }

    // Blurred, slightly dimmed copy: fades in once engaged.
    Image {
        anchors.fill: parent
        source: wallpaper.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        opacity: root.engaged ? 1 : 0
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
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.engaged ? 0.12 : 0.08

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
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.58
        spacing: 12

        // Avatar: first letter of the username.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 84
            height: 84
            radius: 42
            color: Qt.rgba(1, 1, 1, 0.18)

            Text {
                anchors.centerIn: parent
                text: (root.user || "?").charAt(0).toUpperCase()
                font.family: Theme.font
                font.pixelSize: 36
                font.weight: Font.DemiBold
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.engaged = true;
                    password.forceActiveFocus();
                }
            }
        }

        // Username: shown as text (hover: highlight + ✎); click to switch to an
        // input pill styled like the password field. Enter confirms and moves
        // to the password, Esc cancels back to the previous name.
        Item {
            id: userArea

            property string previousUser: ""

            function startEditing() {
                previousUser = root.user;
                root.editingUser = true;
                root.engaged = true;
                userInput.text = root.user;
                userInput.selectAll();
                userInput.forceActiveFocus();
            }

            function finishEditing() {
                if (!root.user)
                    return;
                root.editingUser = false;
                password.forceActiveFocus();
            }

            function cancelEditing() {
                if (!previousUser)
                    return;
                root.user = previousUser;
                root.editingUser = false;
                password.forceActiveFocus();
            }

            anchors.horizontalCenter: parent.horizontalCenter
            width: 260
            height: 38

            // Display mode: just the centered name (hover highlight, click to
            // edit).
            MouseArea {
                id: nameButton

                visible: !root.editingUser
                anchors.centerIn: parent
                width: nameText.implicitWidth + 28
                height: 32
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: userArea.startEditing()

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: nameButton.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : "transparent"
                }

                Text {
                    id: nameText
                    anchors.centerIn: parent
                    text: root.user
                    font.family: Theme.font
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                    color: "white"
                }
            }

            // Edit mode: input pill like the password field.
            Rectangle {
                visible: root.editingUser
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                border.color: userInput.activeFocus ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(1, 1, 1, 0.25)

                // Same layout as the password field (text 18px from the left,
                // room for the → button on the right).
                TextInput {
                    id: userInput
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 40
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize + 1
                    color: "white"
                    selectionColor: Qt.rgba(1, 1, 1, 0.3)
                    clip: true
                    onTextEdited: root.user = text.trim()
                    onAccepted: userArea.finishEditing()
                    Keys.onEscapePressed: userArea.cancelEditing()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !userInput.text
                        text: "Username"
                        font: userInput.font
                        color: Qt.rgba(1, 1, 1, 0.55)
                    }
                }

                // Confirm arrow.
                MouseArea {
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    visible: userInput.text !== ""
                    cursorShape: Qt.PointingHandCursor
                    onClicked: userArea.finishEditing()

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Qt.rgba(1, 1, 1, 0.22)
                    }

                    Icon {
                        anchors.centerIn: parent
                        name: "arrow_forward"
                        size: 18
                        color: "white"
                    }
                }
            }
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
            border.color: root.error ? Qt.rgba(0.93, 0.33, 0.59, 0.8) : Qt.rgba(1, 1, 1, 0.25)
            opacity: root.engaged ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }

            transform: Translate {
                id: shake
                y: root.engaged ? 0 : 10

                Behavior on y {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutCubic
                    }
                }
            }

            SequentialAnimation {
                id: shakeAnim
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
                enabled: !root.busy && !root.launching

                onTextEdited: {
                    root.engaged = true;
                    root.error = "";
                }
                onAccepted: root.login()
                Keys.onEscapePressed: {
                    if (text === "")
                        root.engaged = root.editingUser;
                    text = "";
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !password.text && !root.busy
                    text: "Enter Password"
                    font: password.font
                    color: Qt.rgba(1, 1, 1, 0.55)
                }
            }

            MouseArea {
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                enabled: root.engaged
                cursorShape: Qt.PointingHandCursor
                onClicked: root.login()

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(1, 1, 1, 0.22)
                }

                Icon {
                    anchors.centerIn: parent
                    name: root.busy || root.launching ? "progress_activity" : "arrow_forward"
                    size: 18
                    color: "white"

                    RotationAnimation on rotation {
                        running: root.busy || root.launching
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 900
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.error || root.info || (root.engaged ? "Touch your security key or enter your password" : "Click or start typing to log in")
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: root.error ? Theme.urgent : Qt.rgba(1, 1, 1, 0.6)
        }
    }

    // ---- bottom: power (login screen only; nothing to protect yet) ----
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
        spacing: 28

        Repeater {
            model: [
                {
                    icon: "restart_alt",
                    label: "Restart",
                    command: ["systemctl", "reboot"]
                },
                {
                    icon: "power_settings_new",
                    label: "Shut Down",
                    command: ["systemctl", "poweroff"]
                }
            ]

            MouseArea {
                id: action
                required property var modelData
                property bool armed: false

                implicitWidth: 72
                implicitHeight: 76
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!armed) {
                        armed = true;
                        disarm.restart();
                        return;
                    }
                    Quickshell.execDetached(modelData.command);
                }

                Timer {
                    id: disarm
                    interval: 3000
                    onTriggered: action.armed = false
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 46
                        height: 46
                        radius: 23
                        color: action.armed ? Qt.rgba(0.93, 0.33, 0.59, 0.55) : action.containsMouse ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(1, 1, 1, 0.16)

                        Icon {
                            anchors.centerIn: parent
                            name: action.modelData.icon
                            size: 22
                            color: "white"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: action.armed ? "Confirm?" : action.modelData.label
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Qt.rgba(1, 1, 1, action.containsMouse || action.armed ? 1 : 0.7)
                    }
                }
            }
        }
    }

    // ---- bottom-right: session picker ----
    // Click to choose which desktop to log into; the choice is remembered.
    MouseArea {
        id: sessionButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        implicitWidth: sessionRow.implicitWidth + 24
        implicitHeight: 36
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.sessions.length > 1
        onClicked: root.sessionMenuOpen = !root.sessionMenuOpen

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: root.sessionMenuOpen || sessionButton.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
        }

        Row {
            id: sessionRow
            anchors.centerIn: parent
            spacing: 8

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "desktop_windows"
                size: 18
                color: "white"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.sessionName
                font.family: Theme.font
                font.pixelSize: Theme.fontSize
                color: "white"
            }

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                visible: sessionButton.enabled
                name: root.sessionMenuOpen ? "expand_more" : "expand_less"
                size: 18
                color: Qt.rgba(1, 1, 1, 0.75)
            }
        }
    }

    // Session list (opens upwards from the button).
    Rectangle {
        visible: root.sessionMenuOpen
        anchors.right: sessionButton.right
        anchors.bottom: sessionButton.top
        anchors.bottomMargin: 8
        width: Math.max(sessionButton.width, sessionList.implicitWidth + 16)
        height: sessionList.implicitHeight + 16
        radius: 16
        color: Qt.rgba(0, 0, 0, 0.55)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.15)

        Column {
            id: sessionList
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            Repeater {
                model: root.sessions

                MouseArea {
                    id: option
                    required property var modelData
                    required property int index
                    readonly property bool current: index === root.sessionIndex

                    width: Math.max(sessionList.width, optionRow.implicitWidth + 24)
                    implicitWidth: optionRow.implicitWidth + 24
                    implicitHeight: 34
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.sessionIndex = index;
                        root.sessionMenuOpen = false;
                        root.focusInput();
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: option.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                    }

                    Row {
                        id: optionRow
                        anchors.verticalCenter: parent.verticalCenter
                        x: 12
                        spacing: 10

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: "check"
                            size: 16
                            color: "white"
                            opacity: option.current ? 1 : 0
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: option.modelData.name
                            font.family: Theme.font
                            font.pixelSize: Theme.fontSize
                            font.weight: option.current ? Font.DemiBold : Font.Normal
                            color: "white"
                        }
                    }
                }
            }
        }
    }
}
