import QtQuick

QtObject {
    property string themeId: "rwm-lavender"
    property string name: "Lavender"
    property bool enabled: true

    property var background: [
        "#0F0820",
        "#180D30",
        "#120A28",
        "#1C1038",
        "#0A0518"
    ]

    property string effect: "#CC99FF"

    property var ghosts: [
        "#4A2070",
        "#5C2880",
        "#6A3090",
        "#3A1858"
    ]

    property var waveMain: [
        "#6B3FA0",
        "#7B4AB0",
        "#8855B8",
        "#5A3090",
        "#9060C0",
        "#7050A8",
        "#A065C8",
        "#6848A0",
        "#9870C0",
        "#B080D0"
    ]

    property var waveHighlight: [
        "#B080E0",
        "#C090F0",
        "#D0A0FF",
        "#A878D8",
        "#C898F0",
        "#9870C8",
        "#D0A8F8",
        "#B890E8",
        "#E0B8FF",
        "#C8A0F0"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
