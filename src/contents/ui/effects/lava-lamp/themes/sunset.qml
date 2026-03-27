import QtQuick

QtObject {
    property string themeId: "llm-sunset"
    property string name: "Sunset"
    property bool enabled: true

    property string gradientMode: "corners"
    property var gradientColors: ["#FF6B9D", "#C44DFF", "#FF8C42", "#8B2FC9"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#2a1030", "#1a0820", "#2a1520", "#150818"]
    property bool glowEnabled: true
    property real glowIntensity: 5.5
    property real glowInnerThreshold: 0.7
    property real glowMidThreshold: 0.3
    property real glowOuterThreshold: 0.05
    property real glowMinFieldStrength: 0.008
}
