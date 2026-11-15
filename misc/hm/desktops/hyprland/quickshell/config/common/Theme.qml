pragma Singleton

import QtQuick
import Quickshell

// Mirrors the stylix base16 scheme in ../../../theming.nix.
// Keep this file (and Icon.qml) free of `qs.*` imports: the greeter
// (misc/nixos/apps/quickshell_greeter.nix) copies both into a flat folder.
Singleton {
    readonly property color background: "#161616" // base00
    readonly property color surface: "#252525" // base01
    readonly property color surfaceHigh: "#353535" // base02
    readonly property color muted: "#484848" // base03
    readonly property color foregroundDim: "#7b7c7e" // base04
    readonly property color foreground: "#f2f4f8" // base05
    readonly property color accent: "#78a9ff" // base0D
    readonly property color success: "#25be6a" // base0B
    readonly property color urgent: "#ee5396" // base08

    // Privacy indicators (macOS-style: orange mic, green camera, purple screen).
    readonly property color privacyMic: "#ff9f0a"
    readonly property color privacyCamera: "#25be6a" // base0B
    readonly property color privacyScreen: "#be95ff" // base0E

    // Translucent surfaces; Hyprland blurs what's behind them (layer rule in
    // hypr/windows.lua).
    readonly property color glass: Qt.rgba(background.r, background.g, background.b, 0.78)
    readonly property color glassTile: Qt.rgba(surface.r, surface.g, surface.b, 0.8)
    readonly property color glassTileHover: Qt.rgba(surfaceHigh.r, surfaceHigh.g, surfaceHigh.b, 0.88)
    readonly property color glassBorder: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)

    readonly property string font: "Noto Sans"
    readonly property int fontSize: 13

    readonly property string iconFont: "Material Symbols Rounded"
    readonly property int iconSize: 18

    readonly property int barHeight: 34
    readonly property int radius: 12
    readonly property int animDuration: 160
}
