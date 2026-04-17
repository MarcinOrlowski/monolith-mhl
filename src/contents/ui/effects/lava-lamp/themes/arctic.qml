import QtQuick

QtObject {
    property string themeId: "llm-arctic"
    property string name: "Arctic"
    property bool enabled: true

    property string gradientMode: "corners"
    property var gradientColors: ["#FFFFFF", "#80D4FF", "#A0E8FF", "#CCF2FF"]
    property bool backgroundGradientEnabled: true
    property var backgroundColors: ["#102840", "#061020", "#0a2038", "#040c18"]
    property bool glowEnabled: true
    property real glowIntensity: 4.0
    property real glowInnerThreshold: 0.65
    property real glowMidThreshold: 0.25
    property real glowOuterThreshold: 0.04
    property real glowMinFieldStrength: 0.004
}
