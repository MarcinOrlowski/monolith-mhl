/***********************************************************************
 *
 * Monolith MHL: Beautiful animated wallpapers for Plasma 6
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright ©2026 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/monolith-mhl
 *
 **********************************************************************/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import "../../EffectSettings.js" as EffectSettings

Item {
    id: effectRoot
    anchors.fill: parent

    // --- Input from hub ---
    property var configuration: null

    // --- Schema (must match DotWavesConfig.qml) ---
    readonly property var _defaults: ({
        spacing: 22,
        dotRadius: 14,
        density: 100,
        contrast: 18,
        maxAlpha: 35,
        dotColor: "#c8c8c8",
        bgColor: "#1c1c1c",
        speedIndex: 3,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Parsed settings (reactive properties for bindings) ---
    property real speedMult: 1.0
    property real dimLevel: 1.0
    property bool fpsCap: true
    property int fpsLimit: 30
    property bool paused: false
    property real spacing: 22
    property real dotRadius: 1.4
    property real density: 1.0
    property real contrast: 1.8
    property real maxAlpha: 0.35
    property string dotColor: "#c8c8c8"
    property string bgColor: "#1c1c1c"

    readonly property color _dotCol: Qt.color(dotColor)
    readonly property color _bgCol: Qt.color(bgColor)

    function togglePause() { paused = !paused }

    function _readSettings() {
        var json = configuration ? configuration.EffectDotWavesSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _applySettings() {
        var s = _readSettings();
        speedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.speedIndex] ?? 1.0;
        fpsCap = s.fpsCap;
        fpsLimit = s.fpsLimit;
        dimLevel = s.dimCap ? s.dimLevel / 100.0 : 1.0;

        spacing = Math.max(4, s.spacing);
        dotRadius = Math.max(0.1, s.dotRadius / 10.0);
        density = Math.min(1.0, Math.max(0.0, s.density / 100.0));
        contrast = Math.max(0.1, s.contrast / 10.0);
        maxAlpha = Math.min(1.0, Math.max(0.0, s.maxAlpha / 100.0));
        dotColor = s.dotColor;
        bgColor = s.bgColor;
    }

    // --- Outputs for hub ---
    readonly property bool hasError: effect.status === ShaderEffect.Error
    readonly property string errorLog: effect.log || ""
    readonly property string effectName: "Dot Waves"
    readonly property url configUrl: Qt.resolvedUrl("DotWavesConfig.qml")

    // No themes -> no per-effect context menu actions.
    readonly property list<PlasmaCore.Action> effectActions: []

    // React to config changes (JSON blob)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectDotWavesSettings") {
                effectRoot._applySettings();
            }
        }
    }

    Component.onCompleted: _applySettings()

    // --- Shader effect ---
    // CRITICAL: Property order must match the std140 uniform block in dot-waves.frag
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0
        property real iWidth: width
        property real iHeight: height
        property real spacing: effectRoot.spacing
        property real dotRadius: effectRoot.dotRadius
        property real maxAlpha: effectRoot.maxAlpha
        property real density: effectRoot.density
        property real contrast: effectRoot.contrast
        property real dimLevel: effectRoot.dimLevel
        property real dotColorR: effectRoot._dotCol.r
        property real dotColorG: effectRoot._dotCol.g
        property real dotColorB: effectRoot._dotCol.b
        property real bgColorR: effectRoot._bgCol.r
        property real bgColorG: effectRoot._bgCol.g
        property real bgColorB: effectRoot._bgCol.b

        // iTime is accumulated in seconds; shader wave constants are tuned for it.
        FrameAnimation {
            running: effect.visible && !effectRoot.fpsCap && !effectRoot.paused
            onTriggered: effect.iTime += frameTime * effectRoot.speedMult
        }

        Timer {
            running: effect.visible && effectRoot.fpsCap && !effectRoot.paused
            repeat: true
            interval: Math.ceil(1000 / Math.min(240, Math.max(1, effectRoot.fpsLimit)))
            onTriggered: effect.iTime += (interval / 1000.0) * effectRoot.speedMult
        }

        vertexShader: "shaders/dot-waves.vert.qsb"
        fragmentShader: "shaders/dot-waves.frag.qsb"
    }
}
