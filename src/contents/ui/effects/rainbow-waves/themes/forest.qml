import QtQuick

QtObject {
    property string themeId: "rwm-forest"
    property string name: "Forest"
    property bool enabled: true

    property var background: [
        "#060E06",
        "#0A1408",
        "#0C180A",
        "#081007",
        "#050C05"
    ]

    property string effect: "#D4A020"

    property var ghosts: [
        "#2D5A1E",
        "#4A7C30",
        "#5C4A20",
        "#3D6828"
    ]

    property var waveMain: [
        "#1A4A0E",
        "#2D6B18",
        "#3D8224",
        "#4E7A1A",
        "#5C6B14",
        "#6B5C10",
        "#4A3A12",
        "#3A5E1A",
        "#527A2A",
        "#6A8C2E"
    ]

    property var waveHighlight: [
        "#3A8020",
        "#52A030",
        "#68B83E",
        "#7AAA30",
        "#8A9A24",
        "#9A8820",
        "#7A6020",
        "#5E8E2E",
        "#80AA44",
        "#9ABE4A"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
