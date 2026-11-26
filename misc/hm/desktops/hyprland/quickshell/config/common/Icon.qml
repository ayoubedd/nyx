import QtQuick

// Material Symbols glyph by ligature name, e.g. Icon { name: "wifi" }.
//
// Always the outline (line) version: `filled` is accepted but ignored. Many
// filled glyphs are a different, blobby shape, so icons switching to them
// when selected/active looked like a different icon. Selection and on/off
// states show through colour and backgrounds instead.
Text {
    property string name
    property bool filled: false // kept for compatibility; no effect
    property int size: Theme.iconSize

    text: name
    color: Theme.foreground
    font.family: Theme.iconFont
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": 0,
            "wght": 400,
            "opsz": size
        })
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
