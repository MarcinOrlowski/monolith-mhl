import QtQuick

QtObject {
    property string themeId: "rwm-cherry"
    property string name: "Cherry"
    property bool enabled: true

    property var background: [
        "#1A0008",
        "#2B0010",
        "#3B0018",
        "#1F000D",
        "#0F0005"
    ]

    property string effect: "#FF4D7D"

    property var ghosts: [
        "#7A0025",
        "#B5003A",
        "#8B1A3A",
        "#5C001A"
    ]

    property var waveMain: [
        "#8B0020",
        "#A3002B",
        "#C0003A",
        "#7A1030",
        "#B52050",
        "#6B0018",
        "#9B1040",
        "#D03060",
        "#5A0015",
        "#C04060"
    ]

    property var waveHighlight: [
        "#E8305A",
        "#F04D70",
        "#FF6080",
        "#D83060",
        "#F05578",
        "#C82848",
        "#E84068",
        "#FF7090",
        "#D04870",
        "#FF8090"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
