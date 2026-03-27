import QtQuick

QtObject {
    property string themeId: "llm-forest"
    property string name: "Forest"
    property bool enabled: true

    property string gradientMode: "corners"
    property var gradientColors: ["#80FF80", "#006600", "#CCFF80", "#408040"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#1a2a1a", "#0f1f0f", "#1a2a1a", "#0f1f0f"]
    property bool glowEnabled: true
    property real glowIntensity: 3.5
    property real glowInnerThreshold: 0.7
    property real glowMidThreshold: 0.3
    property real glowOuterThreshold: 0.05
    property real glowMinFieldStrength: 0.005
}
