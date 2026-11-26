pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Colours and fonts come from the stylix scheme (../../../theming.nix), which
// home-manager writes to ~/.config/nyx/theme.json; the greeter points
// NYX_THEME at the same file in the store. The file is watched, so a rebuild
// recolours everything live. The fallbacks below are only a plain dark
// scheme for when the file is missing; they are not a copy of the palette.
// Keep this file (and Icon.qml) free of `qs.*` imports: the greeter
// (misc/nixos/apps/quickshell_greeter.nix) copies both into a flat folder.
Singleton {
    FileView {
        id: themeFile
        path: Quickshell.env("NYX_THEME") || `${Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"}/nyx/theme.json`
        // Read synchronously at startup, so nothing draws in fallback colours first.
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
    readonly property var scheme: {
        try {
            return JSON.parse(themeFile.text() || "{}");
        } catch (e) {
            console.warn("Theme: can't parse", themeFile.path, e);
            return {};
        }
    }

    readonly property color background: scheme.base00 ?? "#101010"
    readonly property color surface: scheme.base01 ?? "#202020"
    readonly property color surfaceHigh: scheme.base02 ?? "#303030"
    readonly property color muted: scheme.base03 ?? "#484848"
    readonly property color foregroundDim: scheme.base04 ?? "#808080"
    readonly property color foreground: scheme.base05 ?? "#f0f0f0"
    readonly property color accent: scheme.base0D ?? "#6699ff"
    readonly property color success: scheme.base0B ?? "#33bb66"
    readonly property color urgent: scheme.base08 ?? "#ee4466"
    readonly property color magenta: scheme.base0E ?? "#bb88ff"

    // Privacy indicators (macOS-style: orange mic, green camera, purple screen).
    // The mic orange is fixed on purpose (not in the scheme).
    readonly property color privacyMic: "#ff9f0a"
    readonly property color privacyCamera: success
    readonly property color privacyScreen: magenta

    // Translucent surfaces; Hyprland blurs what's behind them (layer rule in
    // hypr/windows.lua).
    readonly property color glass: Qt.rgba(background.r, background.g, background.b, 0.78)
    readonly property color glassTile: Qt.rgba(surface.r, surface.g, surface.b, 0.8)
    readonly property color glassTileHover: Qt.rgba(surfaceHigh.r, surfaceHigh.g, surfaceHigh.b, 0.88)
    readonly property color glassBorder: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)

    readonly property string font: scheme.fontSans ?? "Noto Sans"
    readonly property string fontMono: scheme.fontMono ?? "monospace"
    readonly property int fontSize: 13

    // Sharp: crisp square-cornered line icons (Rounded looked soft).
    readonly property string iconFont: "Material Symbols Sharp"
    readonly property int iconSize: 18

    readonly property int barHeight: 34
    readonly property int radius: 12
    // Power saving (services/PowerSaver.qml sets it): UI animations jump
    // straight to their end. Wrap every animation length in ms():
    //   NumberAnimation { duration: Theme.ms(200) }
    // Looping spinners / pulses check `reduceMotion` themselves instead
    // (a 0 ms infinite loop would spin the CPU).
    property bool reduceMotion: false
    readonly property int animDuration: reduceMotion ? 0 : 160

    function ms(duration) {
        return reduceMotion ? 0 : duration;
    }
}
