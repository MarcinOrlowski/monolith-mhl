import QtQuick

QtObject {
    property string themeId: "rwm-fire"
    property string name: "Fire"
    property bool enabled: true

    property var background: [
        "#451A03",
        "#7C2D12",
        "#581C87",
        "#1E1B4B",
        "#0C0A09"
    ]

    property string effect: "#FDE047"

    property var ghosts: [
        "#FACC15",
        "#F97316",
        "#EF4444",
        "#A21CAF"
    ]

    property var waveMain: [
        "#FACC15",
        "#F59E0B",
        "#F97316",
        "#EA580C",
        "#EF4444",
        "#DC2626",
        "#E11D48",
        "#BE185D",
        "#A21CAF",
        "#7C3AED"
    ]

    property var waveHighlight: [
        "#FDE047",
        "#FACC15",
        "#FB923C",
        "#F97316",
        "#F87171",
        "#EF4444",
        "#F43F5E",
        "#E11D48",
        "#C026D3",
        "#8B5CF6"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
