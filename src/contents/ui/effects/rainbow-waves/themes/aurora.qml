import QtQuick

QtObject {
    property string themeId: "rwm-aurora"
    property string name: "Aurora"
    property bool enabled: true

    property var background: [
        "#042F2E",
        "#134E4A",
        "#1E3A5F",
        "#4C1D95",
        "#1E1B4B"
    ]

    property string effect: "#5EEAD4"

    property var ghosts: [
        "#14B8A6",
        "#22C55E",
        "#8B5CF6",
        "#D946EF"
    ]

    property var waveMain: [
        "#2DD4BF",
        "#14B8A6",
        "#10B981",
        "#22C55E",
        "#A3E635",
        "#84CC16",
        "#8B5CF6",
        "#A855F7",
        "#D946EF",
        "#EC4899"
    ]

    property var waveHighlight: [
        "#99F6E4",
        "#2DD4BF",
        "#34D399",
        "#4ADE80",
        "#BEF264",
        "#A3E635",
        "#A78BFA",
        "#C084FC",
        "#E879F9",
        "#F472B6"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
