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

    // --- Schema (must match JungleWalkConfig.qml) ---
    readonly property var _defaults: ({
        density: 60,
        leafColor: "#3a8a2e",
        bgColor: "#0b241a",
        lightColor: "#d2eca0",
        showFog: true,
        showRays: true,
        showParticles: true,
        showVignette: true,
        speedIndex: 3,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Parsed settings (reactive properties for bindings) ---
    property real speedMult: 1.0
    property bool fpsCap: true
    property int fpsLimit: 30
    property bool paused: false
    property real dimLevel: 1.0

    property real density: 0.6
    property string leafColor: "#3a8a2e"
    property string bgColor: "#0b241a"
    property string lightColor: "#d2eca0"
    property bool showFog: true
    property bool showRays: true
    property bool showParticles: true
    property bool showVignette: true

    readonly property color _leafCol: Qt.color(leafColor)
    readonly property color _bgCol: Qt.color(bgColor)
    readonly property color _lightCol: Qt.color(lightColor)

    function togglePause() { paused = !paused }

    function _readSettings() {
        var json = configuration ? configuration.EffectJungleWalkSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _applySettings() {
        var s = _readSettings();
        speedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.speedIndex] ?? 1.0;
        fpsCap = s.fpsCap;
        fpsLimit = s.fpsLimit;
        dimLevel = s.dimCap ? s.dimLevel / 100.0 : 1.0;

        density = Math.min(1.0, Math.max(0.0, s.density / 100.0));
        leafColor = s.leafColor;
        bgColor = s.bgColor;
        lightColor = s.lightColor;
        showFog = s.showFog;
        showRays = s.showRays;
        showParticles = s.showParticles;
        showVignette = s.showVignette;
    }

    // --- Outputs for hub ---
    readonly property bool hasError: effect.status === ShaderEffect.Error
    readonly property string errorLog: effect.log || ""
    readonly property string effectName: "Jungle Walk"
    readonly property url configUrl: Qt.resolvedUrl("JungleWalkConfig.qml")

    // No themes -> no per-effect context menu actions.
    readonly property list<PlasmaCore.Action> effectActions: []

    // React to config changes (JSON blob)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectJungleWalkSettings") {
                effectRoot._applySettings();
            }
        }
    }

    Component.onCompleted: _applySettings()

    // --- Shader effect ---
    // CRITICAL: Property order must match the std140 uniform block in jungle-walk.frag
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0
        property real iWidth: width
        property real iHeight: height
        property real density: effectRoot.density
        property real dimLevel: effectRoot.dimLevel
        property real leafColorR: effectRoot._leafCol.r
        property real leafColorG: effectRoot._leafCol.g
        property real leafColorB: effectRoot._leafCol.b
        property real bgColorR: effectRoot._bgCol.r
        property real bgColorG: effectRoot._bgCol.g
        property real bgColorB: effectRoot._bgCol.b
        property real lightColorR: effectRoot._lightCol.r
        property real lightColorG: effectRoot._lightCol.g
        property real lightColorB: effectRoot._lightCol.b
        property real showFog: effectRoot.showFog ? 1.0 : 0.0
        property real showRays: effectRoot.showRays ? 1.0 : 0.0
        property real showParticles: effectRoot.showParticles ? 1.0 : 0.0
        property real showVignette: effectRoot.showVignette ? 1.0 : 0.0

        // iTime is accumulated in seconds; the forward-motion constants in the
        // shader are tuned for it. speedMult scales the walk pace.
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

        vertexShader: "shaders/jungle-walk.vert.qsb"
        fragmentShader: "shaders/jungle-walk.frag.qsb"
    }
}
