import QtQuick

QtObject {
    property string themeId: "rwm-sunset"
    property string name: "Sunset"
    property bool enabled: true

    property var background: [
        "#0E7490",
        "#1E3A5F",
        "#312E81",
        "#581C87",
        "#1E1B4B"
    ]

    property string effect: "#F472B6"

    property var ghosts: [
        "#06B6D4",
        "#D946EF",
        "#F472B6",
        "#A855F7"
    ]

    property var waveMain: [
        "#0EA5E9",
        "#06B6D4",
        "#A855F7",
        "#D946EF",
        "#EC4899",
        "#F43F5E",
        "#F97316",
        "#EAB308",
        "#7C3AED",
        "#4F46E5"
    ]

    property var waveHighlight: [
        "#67E8F9",
        "#22D3EE",
        "#C084FC",
        "#E879F9",
        "#F472B6",
        "#FB7185",
        "#FB923C",
        "#FACC15",
        "#A78BFA",
        "#818CF8"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
