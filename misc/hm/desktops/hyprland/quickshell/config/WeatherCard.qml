import QtQuick
import QtQuick.Layouts

// Compact weather card for the dashboard Home tab (data: Weather.qml).
Rectangle {
    id: root

    function deg(v) {
        return `${Math.round(v)}°`;
    }

    radius: Theme.radius
    color: Theme.surface
    implicitWidth: 280
    implicitHeight: 96

    // ---- loading / error ----
    Row {
        anchors.centerIn: parent
        visible: !Weather.ready
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: Weather.error ? "cloud_off" : "cloud"
            size: 18
            color: Theme.foregroundDim
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.error || "Loading weather…"
            font.family: Theme.font
            font.pixelSize: Theme.fontSize - 1
            color: Theme.foregroundDim
        }
    }

    // ---- weather ----
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        visible: Weather.ready
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Icon {
                name: Weather.icon
                filled: true
                size: 34
                color: Theme.foreground
            }

            Text {
                text: root.deg(Weather.temperature)
                font.family: Theme.font
                font.pixelSize: 28
                font.weight: Font.DemiBold
                color: Theme.foreground
            }

            Column {
                Layout.fillWidth: true

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: `${Weather.condition} · feels ${root.deg(Weather.feelsLike)}`
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    text: {
                        const today = Weather.daily[0];
                        const range = today ? `H ${root.deg(today.max)}  L ${root.deg(today.min)}` : "";
                        return [Weather.city, range].filter(s => !!s).join(" · ");
                    }
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foregroundDim
                }
            }
        }

        // Next three days.
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: Weather.daily.slice(1, 4)

                Row {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.formatDate(modelData.date, "ddd")
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foregroundDim
                    }

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: Weather.iconFor(modelData.code, true)
                        filled: true
                        size: 15
                        color: Theme.foregroundDim
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: `${root.deg(modelData.max)}/${root.deg(modelData.min)}`
                        font.family: Theme.font
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.foreground
                    }
                }
            }
        }
    }
}
