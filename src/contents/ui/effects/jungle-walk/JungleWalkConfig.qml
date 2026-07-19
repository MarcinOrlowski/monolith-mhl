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
import "../../EffectSettings.js" as EffectSettings

Item {
    id: effectConfig

    // --- JSON blob bound from hub config.qml ---
    property string cfg_EffectJungleWalkSettings

    property var hubConfiguration: null

    // --- Schema: key → default value (single source of truth) ---
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

    // --- Backing properties ---
    property int _density: 60
    property string _leafColor: "#3a8a2e"
    property string _bgColor: "#0b241a"
    property string _lightColor: "#d2eca0"
    property bool _showFog: true
    property bool _showRays: true
    property bool _showParticles: true
    property bool _showVignette: true
    property int _speedIndex: 3
    property bool _fpsCap: true
    property int _fpsLimit: 30
    property bool _dimCap: false
    property int _dimLevel: 100

    // --- Load / save plumbing ---
    property bool _loading: false

    onCfg_EffectJungleWalkSettingsChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(cfg_EffectJungleWalkSettings, _defaults)
        _density = s.density
        _leafColor = s.leafColor
        _bgColor = s.bgColor
        _lightColor = s.lightColor
        _showFog = s.showFog
        _showRays = s.showRays
        _showParticles = s.showParticles
        _showVignette = s.showVignette
        _speedIndex = s.speedIndex
        _fpsCap = s.fpsCap
        _fpsLimit = s.fpsLimit
        _dimCap = s.dimCap
        _dimLevel = s.dimLevel
        _loading = false
    }

    function _save() {
        if (_loading) return
        cfg_EffectJungleWalkSettings = EffectSettings.save({
            density: _density,
            leafColor: _leafColor,
            bgColor: _bgColor,
            lightColor: _lightColor,
            showFog: _showFog,
            showRays: _showRays,
            showParticles: _showParticles,
            showVignette: _showVignette,
            speedIndex: _speedIndex,
            fpsCap: _fpsCap,
            fpsLimit: _fpsLimit,
            dimCap: _dimCap,
            dimLevel: _dimLevel
        })
    }

    on_DensityChanged: _save()
    on_LeafColorChanged: _save()
    on_BgColorChanged: _save()
    on_LightColorChanged: _save()
    on_ShowFogChanged: _save()
    on_ShowRaysChanged: _save()
    on_ShowParticlesChanged: _save()
    on_ShowVignetteChanged: _save()
    on_SpeedIndexChanged: _save()
    on_FpsCapChanged: _save()
    on_FpsLimitChanged: _save()
    on_DimCapChanged: _save()
    on_DimLevelChanged: _save()

    // Restore all settings to their schema defaults
    function reset() {
        cfg_EffectJungleWalkSettings = EffectSettings.save(_defaults)
    }

    // --- Page definitions for sidebar navigation ---
    readonly property var pages: [
        { moduleId: "appearance", text: qsTr("Appearance"), icon: "preferences-desktop-color", page: "JungleWalkAppearancePage.qml" },
        { moduleId: "scene", text: qsTr("Scene"), icon: "view-visible", page: "JungleWalkScenePage.qml" },
        { moduleId: "animation", text: qsTr("Animation"), icon: "media-playback-start", page: "JungleWalkAnimationPage.qml" }
    ]
}
