import QtQuick

QtObject {
    property string themeId: "llm-citrus"
    property string name: "Citrus"
    property bool enabled: true

    property string gradientMode: "vertical"
    property var gradientColors: ["#FFD700", "#FF9800", "#FFD700", "#FF9800"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#2a1e08", "#1a1004", "#2a1e08", "#1a1004"]
    property bool glowEnabled: true
    property real glowIntensity: 4.5
    property real glowInnerThreshold: 0.7
    property real glowMidThreshold: 0.3
    property real glowOuterThreshold: 0.05
    property real glowMinFieldStrength: 0.005
}
