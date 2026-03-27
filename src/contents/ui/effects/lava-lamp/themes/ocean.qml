import QtQuick

QtObject {
    property string themeId: "llm-ocean"
    property string name: "Ocean"
    property bool enabled: true

    property string gradientMode: "corners"
    property var gradientColors: ["#0080FF", "#004080", "#00FFFF", "#0080FF"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#0a1a2a", "#051020", "#0a1a2a", "#051020"]
    property bool glowEnabled: true
    property real glowIntensity: 5.0
    property real glowInnerThreshold: 0.75
    property real glowMidThreshold: 0.35
    property real glowOuterThreshold: 0.05
    property real glowMinFieldStrength: 0.01
}
