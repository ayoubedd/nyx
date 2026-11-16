pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Emoji data for the launcher's picker: ~/.local/share/nyx/emoji.json, built
// by ../../emoji/build.py from Unicode's emoji-test.txt + CLDR keywords.
//
// list: [{ char, name, group, keywords }] in Unicode order.
Singleton {
    id: root

    property var groups: []
    property var list: []
    property bool available: false

    readonly property string dataFile: `${Quickshell.env("XDG_DATA_HOME") || Quickshell.env("HOME") + "/.local/share"}/nyx/emoji.json`

    // Material icon per group (same order as build.py).
    readonly property var groupIcons: ({
            Smileys: "sentiment_satisfied",
            People: "waving_hand",
            Nature: "pets",
            Food: "restaurant",
            Travel: "flight",
            Activities: "sports_soccer",
            Objects: "lightbulb",
            Symbols: "emoji_symbols",
            Flags: "flag"
        })

    function byChar(c) {
        return list.find(e => e.char === c) ?? null;
    }

    FileView {
        path: root.dataFile
        printErrors: false
        // Loaded once (lazily the first time `list` is used would also do,
        // but it's ~100 KB).
        onLoaded: {
            try {
                const d = JSON.parse(text());
                root.groups = d.groups;
                root.list = d.emoji.map(e => ({
                            char: e[0],
                            name: e[1],
                            group: e[2],
                            keywords: e[3]
                        }));
                root.available = true;
            } catch (err) {
                console.warn("emoji: bad data file", err);
            }
        }
    }
}
