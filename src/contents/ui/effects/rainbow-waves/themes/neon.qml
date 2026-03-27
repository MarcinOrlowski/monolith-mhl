import QtQuick

QtObject {
    property string themeId: "rwm-neon"
    property string name: "Neon"
    property bool enabled: true

    property var background: [
        "#08060F",
        "#0A0812",
        "#0C0A16",
        "#070610",
        "#05040C"
    ]

    property string effect: "#00F5FF"

    property var ghosts: [
        "#FF00AA",
        "#00EEFF",
        "#39FF14",
        "#CC00FF"
    ]

    property var waveMain: [
        "#FF0080",
        "#FF0050",
        "#CC00FF",
        "#7700FF",
        "#0044FF",
        "#00CCFF",
        "#00FF88",
        "#AAFF00",
        "#FF6600",
        "#FF0066"
    ]

    property var waveHighlight: [
        "#FF55AA",
        "#FF5580",
        "#DD55FF",
        "#AA55FF",
        "#4488FF",
        "#55DDFF",
        "#55FFAA",
        "#CCFF44",
        "#FF9944",
        "#FF5590"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
