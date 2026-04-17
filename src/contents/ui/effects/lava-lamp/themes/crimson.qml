import QtQuick

QtObject {
    property string themeId: "llm-crimson"
    property string name: "Crimson"
    property bool enabled: true

    property string gradientMode: "corners"
    property var gradientColors: ["#DC143C", "#8B0020", "#FF2040", "#AA0030"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#120000", "#080000", "#0e0004", "#050000"]
    property bool glowEnabled: true
    property real glowIntensity: 5.0
    property real glowInnerThreshold: 0.65
    property real glowMidThreshold: 0.28
    property real glowOuterThreshold: 0.05
    property real glowMinFieldStrength: 0.005
}
