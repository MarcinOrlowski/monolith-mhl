import QtQuick

QtObject {
    property string themeId: "llm-heat"
    property string name: "Heat"
    property bool enabled: true

    property string gradientMode: "vertical"
    property var gradientColors: ["#ff6b00", "#ff0000", "#ff6b00", "#ff0000"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#381c0e", "#1c0e07", "#381c0e", "#1c0e07"]
    property bool glowEnabled: true
    property real glowIntensity: 3.0
    property real glowInnerThreshold: 0.7
    property real glowMidThreshold: 0.3
    property real glowOuterThreshold: 0.05
    property real glowMinFieldStrength: 0.005
}
