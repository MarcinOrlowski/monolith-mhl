import QtQuick

QtObject {
    property string themeId: "rwm-nebula"
    property string name: "Nebula"
    property bool enabled: true

    property var background: [
        "#07050F",
        "#0D0A1E",
        "#110D2A",
        "#0A0618",
        "#060410"
    ]

    property string effect: "#E040FB"

    property var ghosts: [
        "#7B2FBE",
        "#C724B1",
        "#4A4AC8",
        "#9C27B0"
    ]

    property var waveMain: [
        "#6A0DAD",
        "#8B1FA8",
        "#B5179E",
        "#C9184A",
        "#D63AF9",
        "#9D4EDD",
        "#3A0CA3",
        "#4361EE",
        "#7209B7",
        "#E040FB"
    ]

    property var waveHighlight: [
        "#A020F0",
        "#C34BC8",
        "#E040D0",
        "#F04070",
        "#EE6EFD",
        "#C07AF8",
        "#6A4FEB",
        "#7A8FF8",
        "#A83FE8",
        "#EE72FD"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
