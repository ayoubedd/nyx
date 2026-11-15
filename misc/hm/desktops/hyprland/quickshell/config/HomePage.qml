import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Big clock + world clocks + media player.
ColumnLayout {
    id: root

    property bool active: false

    // Edit to taste: any IANA timezone name works.
    readonly property var zones: [
        {
            city: "Casablanca",
            tz: "Africa/Casablanca"
        },
        {
            city: "New York",
            tz: "America/New_York"
        },
        {
            city: "Bangladesh",
            tz: "Asia/Dhaka"
        }
    ]

    // tz -> UTC offset in minutes. Fetched via `date` because QML's JS engine
    // has no timezone database. Refreshed on open (covers DST changes).
    property var offsets: ({})

    spacing: 14

    onActiveChanged: if (active) {
        offsetsProc.running = true;
        Weather.refreshIfStale();
    }

    SystemClock {
        id: clock
        precision: root.active ? SystemClock.Seconds : SystemClock.Minutes
    }

    Process {
        id: offsetsProc
        command: ["sh", "-c", 'for z in "$@"; do printf "%s %s\\n" "$z" "$(TZ=$z date +%z)"; done', "sh", ...root.zones.map(z => z.tz)]
        stdout: SplitParser {
            onRead: line => {
                const [tz, off] = line.trim().split(" ");
                if (!off || off.length < 5)
                    return;
                const sign = off[0] === "-" ? -1 : 1;
                const minutes = sign * (parseInt(off.slice(1, 3)) * 60 + parseInt(off.slice(3, 5)));
                const next = Object.assign({}, root.offsets);
                next[tz] = minutes;
                root.offsets = next;
            }
        }
    }

    // ---- big clock + weather ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.family: Theme.font
                font.pixelSize: 54
                font.weight: Font.Light
                color: Theme.foreground

                Text {
                    anchors.left: parent.right
                    anchors.leftMargin: 4
                    anchors.baseline: parent.baseline
                    text: Qt.formatDateTime(clock.date, "ss")
                    font.family: Theme.font
                    font.pixelSize: 20
                    color: Theme.foregroundDim
                }
            }

            Text {
                text: Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy")
                font.family: Theme.font
                font.pixelSize: Theme.fontSize + 1
                color: Theme.foregroundDim
            }
        }

        WeatherCard {
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // ---- world clocks ----
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: root.zones

            Rectangle {
                id: zone
                required property var modelData

                readonly property var offset: root.offsets[modelData.tz]
                readonly property int localOffset: -clock.date.getTimezoneOffset()
                readonly property var time: offset === undefined ? null : new Date(clock.date.getTime() + (offset - localOffset) * 60000)
                readonly property real diffHours: offset === undefined ? 0 : (offset - localOffset) / 60
                readonly property int dayDiff: time ? Math.round((new Date(time).setHours(0, 0, 0, 0) - new Date(clock.date).setHours(0, 0, 0, 0)) / 86400000) : 0

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 74
                radius: Theme.radius
                color: Theme.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 1

                    Text {
                        width: parent.width
                        text: zone.modelData.city
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    Text {
                        text: zone.time ? Qt.formatDateTime(zone.time, "HH:mm") : "--:--"
                        font.family: Theme.font
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: {
                            if (!zone.time)
                                return "";
                            const day = zone.dayDiff > 0 ? "Tomorrow" : zone.dayDiff < 0 ? "Yesterday" : "Today";
                            const h = zone.diffHours;
                            return h === 0 ? day : `${day}, ${h > 0 ? "+" : ""}${h}h`;
                        }
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 3
                        color: Theme.foregroundDim
                    }
                }
            }
        }
    }

    // ---- media ----
    MediaPlayer {
        Layout.fillWidth: true
        Layout.fillHeight: true
        active: root.active
    }
}
