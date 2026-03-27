import QtQuick

QtObject {
    property string themeId: "rwm-dusk"
    property string name: "Dusk"
    property bool enabled: true

    property var background: [
        "#1A2E1A",
        "#0F1F14",
        "#1A1F0F",
        "#2A2A1A",
        "#0A0F0A"
    ]

    property string effect: "#F0D080"

    property var ghosts: [
        "#C49A40",
        "#6B8A55",
        "#3D5C3A",
        "#1A332A"
    ]

    property var waveMain: [
        "#D4A84A",
        "#C49A40",
        "#A68A35",
        "#6B8A55",
        "#4A6B42",
        "#3D5C3A",
        "#2D4A35",
        "#1F3A28",
        "#1A332A",
        "#0F2018"
    ]

    property var waveHighlight: [
        "#F0D080",
        "#D4AA50",
        "#B89A45",
        "#7DA065",
        "#5C7D52",
        "#4E6D4A",
        "#3E5B45",
        "#304B38",
        "#2B443A",
        "#1A3128"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
