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
        dimLevel: 100,
        shineEnabled: false,
        shineMode: 0,
        shineChannel: 2,
        shineIntensity: 60,
        shineSpeedIndex: 3,
        shineColor: "#ffffff",
        shineWidth: 30
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

    property bool shineEnabled: false
    property int shineMode: 0          // 0 = wave field, 1 = spotlight
    property int shineChannel: 2       // 0 = color, 1 = alpha, 2 = both
    property real shineIntensity: 0.6  // 0..1
    property real shineSpeedMult: 1.0
    property string shineColor: "#ffffff"
    property real shineWidth: 0.3      // 0..1, fraction of shine field that passes

    readonly property color _dotCol: Qt.color(dotColor)
    readonly property color _bgCol: Qt.color(bgColor)
    readonly property color _shineCol: Qt.color(shineColor)

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

        shineEnabled = s.shineEnabled;
        shineMode = s.shineMode;
        shineChannel = s.shineChannel;
        shineIntensity = Math.min(1.0, Math.max(0.0, s.shineIntensity / 100.0));
        shineSpeedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.shineSpeedIndex] ?? 1.0;
        shineColor = s.shineColor;
        shineWidth = Math.min(1.0, Math.max(0.05, s.shineWidth / 100.0));
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
        property real shineEnabled: effectRoot.shineEnabled ? 1.0 : 0.0
        property real shineMode: effectRoot.shineMode
        property real shineChannel: effectRoot.shineChannel
        property real shineIntensity: effectRoot.shineIntensity
        property real iShineTime: 0
        property real shineColorR: effectRoot._shineCol.r
        property real shineColorG: effectRoot._shineCol.g
        property real shineColorB: effectRoot._shineCol.b
        property real shineWidth: effectRoot.shineWidth

        // iTime / iShineTime are accumulated in seconds; shader wave constants are tuned for it.
        FrameAnimation {
            running: effect.visible && !effectRoot.fpsCap && !effectRoot.paused
            onTriggered: {
                effect.iTime += frameTime * effectRoot.speedMult
                effect.iShineTime += frameTime * effectRoot.shineSpeedMult
            }
        }

        Timer {
            running: effect.visible && effectRoot.fpsCap && !effectRoot.paused
            repeat: true
            interval: Math.ceil(1000 / Math.min(240, Math.max(1, effectRoot.fpsLimit)))
            onTriggered: {
                var dt = interval / 1000.0
                effect.iTime += dt * effectRoot.speedMult
                effect.iShineTime += dt * effectRoot.shineSpeedMult
            }
        }

        vertexShader: "shaders/dot-waves.vert.qsb"
        fragmentShader: "shaders/dot-waves.frag.qsb"
    }
}
