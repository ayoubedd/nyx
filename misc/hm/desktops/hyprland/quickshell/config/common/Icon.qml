import QtQuick

// Material Symbols glyph by ligature name, e.g. Icon { name: "wifi" }.
Text {
    property string name
    property bool filled: false
    property int size: Theme.iconSize

    text: name
    color: Theme.foreground
    font.family: Theme.iconFont
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": filled ? 1 : 0,
            "wght": 400,
            "opsz": size
        })
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
