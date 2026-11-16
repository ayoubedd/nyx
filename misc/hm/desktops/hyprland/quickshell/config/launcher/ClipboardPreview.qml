import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.services

// Right pane of the clipboard view: the selected entry in full (text or
// image), decoded from cliphist on demand, with a little metadata.
Item {
    id: root

    property var entry: null

    property string fullText: ""
    property string imageFile: ""

    // Debounced so holding an arrow key doesn't spawn a decoder per row.
    onEntryChanged: {
        fullText = "";
        imageFile = "";
        loadTimer.restart();
    }

    Timer {
        id: loadTimer
        interval: 60
        onTriggered: root.load()
    }

    function load() {
        textDecoder.running = false;
        imageDecoder.running = false;
        if (!entry)
            return;
        if (entry.isImage) {
            imageDecoder.target = Clipboard.imagePath(entry);
            imageDecoder.running = true;
        } else {
            textDecoder.running = true;
        }
    }

    Process {
        id: textDecoder
        command: ["sh", "-c", `printf '%s\\n' "$1" | cliphist decode | head -c 20000`, "sh", root.entry?.line ?? ""]
        stdout: StdioCollector {
            onStreamFinished: root.fullText = text
        }
    }

    Process {
        id: imageDecoder
        property string target
        command: ["sh", "-c", `mkdir -p "$(dirname "$2")" && { [ -s "$2" ] || printf '%s\\n' "$1" | cliphist decode > "$2"; }`, "sh", root.entry?.line ?? "", target]
        onExited: code => {
            if (code === 0)
                root.imageFile = target;
        }
    }

    readonly property int lineCount: fullText ? fullText.split("\n").length : 0

    component Key: Text {
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foregroundDim
    }
    component Value: Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        font.family: Theme.font
        font.pixelSize: Theme.fontSize - 3
        color: Theme.foreground
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Content.
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: Theme.glassTile
            clip: true

            Image {
                visible: !!root.entry?.isImage
                anchors.fill: parent
                anchors.margins: 10
                source: root.imageFile ? `file://${root.imageFile}` : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                mipmap: true
            }

            Flickable {
                visible: !root.entry?.isImage
                anchors.fill: parent
                anchors.margins: 12
                contentHeight: body.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Text {
                    id: body
                    width: parent.width
                    text: root.fullText || root.entry?.preview || ""
                    textFormat: Text.PlainText
                    wrapMode: Text.WrapAnywhere
                    font.family: "monospace"
                    font.pixelSize: Theme.fontSize - 2
                    color: Theme.foreground
                }
            }
        }

        // Metadata.
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 4

            Key {
                text: "Type"
            }
            Value {
                text: !root.entry ? "" : root.entry.isImage ? "Image" : /^\s*https?:\/\/\S+\s*$/.test(root.fullText || root.entry.preview) ? "Link" : "Text"
            }

            Key {
                text: root.entry?.isImage ? "Image" : "Size"
            }
            Value {
                text: !root.entry ? "" : root.entry.isImage ? root.entry.imageInfo : `${root.fullText.length.toLocaleString()} characters · ${root.lineCount} ${root.lineCount === 1 ? "line" : "lines"}`
            }
        }
    }
}
