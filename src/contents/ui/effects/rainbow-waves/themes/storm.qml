import QtQuick

QtObject {
    property string themeId: "rwm-storm"
    property string name: "Storm"
    property bool enabled: true

    property var background: [
        "#080C12",
        "#0D1520",
        "#0A1018",
        "#111824",
        "#060810"
    ]

    property string effect: "#B8D8FF"

    property var ghosts: [
        "#1C2B3A",
        "#253545",
        "#1A2838",
        "#0F1E2C"
    ]

    property var waveMain: [
        "#1C2E40",
        "#253848",
        "#1A3050",
        "#2C3C50",
        "#182838",
        "#203550",
        "#1E3060",
        "#2A3E55",
        "#153040",
        "#203858"
    ]

    property var waveHighlight: [
        "#5580A8",
        "#6890B8",
        "#7AAACE",
        "#4870A0",
        "#5888B5",
        "#3D6898",
        "#6090C0",
        "#88B8E8",
        "#4878A8",
        "#A0C8F0"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
