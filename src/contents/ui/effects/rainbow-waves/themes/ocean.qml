import QtQuick

QtObject {
    property string themeId: "rwm-ocean"
    property string name: "Ocean"
    property bool enabled: true

    property var background: [
        "#064E3B",
        "#0F4A5C",
        "#1E3A5F",
        "#1E3A8A",
        "#0C1445"
    ]

    property string effect: "#67E8F9"

    property var ghosts: [
        "#06B6D4",
        "#14B8A6",
        "#0EA5E9",
        "#1D4ED8"
    ]

    property var waveMain: [
        "#06B6D4",
        "#0891B2",
        "#0E7490",
        "#14B8A6",
        "#10B981",
        "#059669",
        "#0284C7",
        "#0369A1",
        "#1D4ED8",
        "#1E40AF"
    ]

    property var waveHighlight: [
        "#67E8F9",
        "#22D3EE",
        "#0891B2",
        "#2DD4BF",
        "#34D399",
        "#10B981",
        "#0EA5E9",
        "#0284C7",
        "#3B82F6",
        "#1D4ED8"
    ]

    property string glowCore: "#FFFFFF"
    property string spotColor: "#FFFFFF"
    property string starColor: "#FFFFFF"
}
