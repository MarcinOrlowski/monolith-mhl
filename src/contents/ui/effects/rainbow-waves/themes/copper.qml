import QtQuick

QtObject {
    property string themeId: "rwm-copper"
    property string name: "Copper"
    property bool enabled: true

    property var background: [
        "#1A0E00",
        "#271500",
        "#1F1000",
        "#2E1A00",
        "#120A00"
    ]

    property string effect: "#FFAA33"

    property var ghosts: [
        "#7A3A00",
        "#A05010",
        "#8B4400",
        "#6B3000"
    ]

    property var waveMain: [
        "#8B4513",
        "#A0522D",
        "#B8621A",
        "#7A3A08",
        "#C07030",
        "#6B3300",
        "#9B5020",
        "#D08030",
        "#804015",
        "#C06010"
    ]

    property var waveHighlight: [
        "#D4703A",
        "#E8884A",
        "#F0A055",
        "#CC7035",
        "#E89045",
        "#C86028",
        "#DC7838",
        "#F0A848",
        "#D07830",
        "#FFBA60"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
