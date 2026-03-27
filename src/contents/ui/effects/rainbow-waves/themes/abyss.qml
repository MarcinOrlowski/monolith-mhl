import QtQuick

QtObject {
    property string themeId: "rwm-abyss"
    property string name: "Abyss"
    property bool enabled: true

    property var background: [
        "#03090C",
        "#040D12",
        "#05101A",
        "#030A14",
        "#02060A"
    ]

    property string effect: "#1A6B7A"

    property var ghosts: [
        "#0A3040",
        "#083C38",
        "#0C2A3A",
        "#061E30"
    ]

    property var waveMain: [
        "#0C4A5E",
        "#0A3D52",
        "#083348",
        "#0D4258",
        "#0B3A50",
        "#093046",
        "#0A2840",
        "#082238",
        "#061C30",
        "#051828"
    ]

    property var waveHighlight: [
        "#1A7A8E",
        "#156878",
        "#105A6A",
        "#187282",
        "#14647A",
        "#105868",
        "#0E4C5E",
        "#0C4252",
        "#0A3848",
        "#083040"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
