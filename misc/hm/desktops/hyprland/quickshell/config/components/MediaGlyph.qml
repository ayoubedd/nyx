import QtQuick
import qs.common

// Standard media symbols drawn as plain shapes (solid play triangle, pause
// bars, skip triangle + bar), so they look the same everywhere instead of
// depending on the icon font's fill/size axes.
//
//   MediaGlyph { kind: "play" }   // "play" | "pause" | "next" | "prev"
Canvas {
    id: root

    property string kind: "play"
    property color color: Theme.foreground
    property int size: 18

    implicitWidth: size
    implicitHeight: size

    onKindChanged: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        const s = Math.min(width, height);
        const ox = (width - s) / 2, oy = (height - s) / 2;
        const P = (fx, fy) => [ox + fx * s, oy + fy * s];

        ctx.reset();
        ctx.fillStyle = root.color;
        ctx.strokeStyle = root.color;
        // A thin stroke in the same color softens the corners a little.
        ctx.lineWidth = Math.max(1, s * 0.06);
        ctx.lineJoin = "round";

        function triangle(a, b, c) {
            ctx.beginPath();
            ctx.moveTo(...P(...a));
            ctx.lineTo(...P(...b));
            ctx.lineTo(...P(...c));
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
        }

        function bar(x0, x1) {
            const [ax, ay] = P(x0, 0.2);
            const [bx, by] = P(x1, 0.8);
            ctx.beginPath();
            ctx.rect(ax, ay, bx - ax, by - ay);
            ctx.fill();
            ctx.stroke();
        }

        switch (root.kind) {
        case "pause":
            bar(0.26, 0.42);
            bar(0.58, 0.74);
            break;
        case "next":
            triangle([0.22, 0.2], [0.22, 0.8], [0.66, 0.5]);
            bar(0.7, 0.8);
            break;
        case "prev":
            triangle([0.78, 0.2], [0.78, 0.8], [0.34, 0.5]);
            bar(0.2, 0.3);
            break;
        default: // play (optically nudged right)
            triangle([0.3, 0.18], [0.3, 0.82], [0.84, 0.5]);
        }
    }
}
