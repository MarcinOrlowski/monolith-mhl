import QtQuick

QtObject {
    property string themeId: "rwm-arctic"
    property string name: "Arctic"
    property bool enabled: true

    property var background: [
        "#050D1A",
        "#071220",
        "#06111E",
        "#040C18",
        "#030912"
    ]

    property string effect: "#A8E6F0"

    property var ghosts: [
        "#B0D8E8",
        "#C8E8F4",
        "#9ECCE0",
        "#D0EEF8"
    ]

    property var waveMain: [
        "#5BA8C4",
        "#6EC0D8",
        "#82D0E8",
        "#9ECCE0",
        "#7AB8D0",
        "#4E90AA",
        "#A8D4E4",
        "#B8DCEC",
        "#3D7A96",
        "#C4E8F4"
    ]

    property var waveHighlight: [
        "#A0D4E8",
        "#B8E4F4",
        "#C8EEF8",
        "#D8F4FC",
        "#C0E0EE",
        "#94C8DC",
        "#E0F4FC",
        "#EAF8FE",
        "#88BCCC",
        "#F0FAFD"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
