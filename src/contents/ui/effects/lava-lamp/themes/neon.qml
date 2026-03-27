import QtQuick

QtObject {
    property string themeId: "llm-neon"
    property string name: "Neon"
    property bool enabled: true

    property string gradientMode: "corners"
    property var gradientColors: ["#FF00FF", "#00BFFF", "#FF1493", "#7B00FF"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#0a0020", "#000a1a", "#10001a", "#050010"]
    property bool glowEnabled: true
    property real glowIntensity: 5.4
    property real glowInnerThreshold: 0.7
    property real glowMidThreshold: 0.3
    property real glowOuterThreshold: 0.06
    property real glowMinFieldStrength: 0.006
}
