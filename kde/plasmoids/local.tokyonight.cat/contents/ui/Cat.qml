import QtQuick
import QtQuick.Window

Item {
    id: cat
    implicitWidth: 44
    implicitHeight: 24
    property bool running: true
    property int frame: 0

    // Sprite grid is 22x12. '#' body, 'e' eye, 'n' nose.
    readonly property var body: [
        "...............#...#..",
        "...............##.##..",
        "...............#####..",
        ".....#######..####e#..",
        "...#################n.",
        "...################...",
        "...###############....",
        "....############......"
    ]
    readonly property var tails: [
        [[2,4],[1,3],[1,2],[2,1]],
        [[2,4],[1,3],[0,2],[0,1]],
        [[2,4],[1,4],[0,3],[0,2]],
        [[2,4],[1,3],[0,2],[0,1]]
    ]
    // Per frame: [near legs, far legs], four-step gallop.
    readonly property var legs: [
        [[[4,8],[5,8],[3,9],[2,10],[15,8],[16,9],[17,10]], [[6,8],[5,9],[4,10],[14,8],[15,9],[16,10]]],
        [[[5,8],[6,8],[6,9],[7,10],[14,8],[14,9],[13,10]], [[7,8],[7,9],[6,10],[15,8],[15,9],[16,10]]],
        [[[5,8],[6,8],[7,9],[8,10],[13,8],[12,9],[11,10]], [[7,8],[8,9],[9,10],[14,8],[13,9],[12,10]]],
        [[[4,8],[5,8],[4,9],[4,10],[15,8],[15,9],[15,10]], [[6,8],[6,9],[6,10],[14,8],[14,9],[13,10]]]
    ]
    readonly property var bob: [-1, 0, 1, 0]
    readonly property var colors: ({"#": "#d4be98", "e": "#282828", "n": "#ea6962", "f": "#7c6f64"})

    // The canvas backing store is already scaled by the device pixel ratio, so
    // snap every sprite pixel to whole device pixels to avoid antialiased seams
    // at fractional scaling.
    readonly property real dpr: Screen.devicePixelRatio || 1

    Canvas {
        id: canvas
        anchors.fill: parent
        smooth: false
        antialiasing: false
        renderStrategy: Canvas.Immediate
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);
            const d = cat.dpr;
            const pw = Math.round(width * d), ph = Math.round(height * d);
            const s = Math.max(1, Math.floor(Math.min(pw / 22, ph / 12)));
            const ox = Math.floor((pw - 22 * s) / 2);
            const oy = Math.floor((ph - 12 * s) / 2) + s;
            const f = cat.running ? cat.frame : 3;
            const b = cat.running ? cat.bob[f] : 0;
            function px(x, y, c) {
                ctx.fillStyle = cat.colors[c];
                ctx.fillRect((ox + x * s) / d, (oy + (y + b) * s) / d, s / d, s / d);
            }
            function stroke(list, c) {
                for (let i = 0; i < list.length; i++) px(list[i][0], list[i][1], c);
            }
            stroke(cat.legs[f][1], "f");
            stroke(cat.tails[f], "#");
            for (let y = 0; y < cat.body.length; y++)
                for (let x = 0; x < cat.body[y].length; x++)
                    if (cat.body[y][x] !== ".") px(x, y, cat.body[y][x]);
            stroke(cat.legs[f][0], "#");
        }
    }

    onFrameChanged: canvas.requestPaint()
    onRunningChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onDprChanged: canvas.requestPaint()

    Timer {
        interval: 130
        repeat: true
        running: cat.running && cat.visible && (!cat.Window.window || cat.Window.window.visible)
        onTriggered: cat.frame = (cat.frame + 1) % 4
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: cat.running = !cat.running
        Accessible.role: Accessible.Button
        Accessible.name: cat.running ? "Pause the running cat" : "Resume the running cat"
    }
}
