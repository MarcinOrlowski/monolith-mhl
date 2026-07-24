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
    property string cfg_EffectMicroscopeZoomSettings

    property var hubConfiguration: null

    // --- Schema: key → default value (single source of truth) ---
    readonly property var _defaults: ({
        themeId: "mzm-chlorophyll",
        randomInitialTheme: true,
        autoCycle: true,
        cycleInterval: 15,
        cycleIntervalUnit: 1,
        transitionDuration: 3,
        cycleInRandomOrder: true,
        density: 60,
        showFog: true,
        showRays: true,
        showParticles: true,
        showVignette: true,
        dustAmount: 55,
        dustSize: 22,
        speedIndex: 3,
        rotation: 20,
        microbeMotion: 50,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Backing properties ---
    property string _themeId: "mzm-chlorophyll"
    property bool _randomInitialTheme: true
    property bool _autoCycle: true
    property int _cycleInterval: 15
    property int _cycleIntervalUnit: 1
    property int _transitionDuration: 3
    property bool _cycleInRandomOrder: true
    property int _density: 60
    property bool _showFog: true
    property bool _showRays: true
    property bool _showParticles: true
    property bool _showVignette: true
    property int _dustAmount: 55
    property int _dustSize: 22
    property int _speedIndex: 3
    property int _rotation: 20
    property int _microbeMotion: 50
    property bool _fpsCap: true
    property int _fpsLimit: 30
    property bool _dimCap: false
    property int _dimLevel: 100

    // --- Load / save plumbing ---
    property bool _loading: false

    onCfg_EffectMicroscopeZoomSettingsChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(cfg_EffectMicroscopeZoomSettings, _defaults)
        _themeId = s.themeId
        _randomInitialTheme = s.randomInitialTheme
        _autoCycle = s.autoCycle
        _cycleInterval = s.cycleInterval
        _cycleIntervalUnit = s.cycleIntervalUnit
        _transitionDuration = s.transitionDuration
        _cycleInRandomOrder = s.cycleInRandomOrder
        _density = s.density
        _showFog = s.showFog
        _showRays = s.showRays
        _showParticles = s.showParticles
        _showVignette = s.showVignette
        _dustAmount = s.dustAmount
        _dustSize = s.dustSize
        _speedIndex = s.speedIndex
        _rotation = s.rotation
        _microbeMotion = s.microbeMotion
        _fpsCap = s.fpsCap
        _fpsLimit = s.fpsLimit
        _dimCap = s.dimCap
        _dimLevel = s.dimLevel
        _loading = false
    }

    function _save() {
        if (_loading) return
        cfg_EffectMicroscopeZoomSettings = EffectSettings.save({
            themeId: _themeId,
            randomInitialTheme: _randomInitialTheme,
            autoCycle: _autoCycle,
            cycleInterval: _cycleInterval,
            cycleIntervalUnit: _cycleIntervalUnit,
            transitionDuration: _transitionDuration,
            cycleInRandomOrder: _cycleInRandomOrder,
            density: _density,
            showFog: _showFog,
            showRays: _showRays,
            showParticles: _showParticles,
            showVignette: _showVignette,
            dustAmount: _dustAmount,
            dustSize: _dustSize,
            speedIndex: _speedIndex,
            rotation: _rotation,
            microbeMotion: _microbeMotion,
            fpsCap: _fpsCap,
            fpsLimit: _fpsLimit,
            dimCap: _dimCap,
            dimLevel: _dimLevel
        })
    }

    on_ThemeIdChanged: _save()
    on_RandomInitialThemeChanged: _save()
    on_AutoCycleChanged: _save()
    on_CycleIntervalChanged: _save()
    on_CycleIntervalUnitChanged: _save()
    on_TransitionDurationChanged: _save()
    on_CycleInRandomOrderChanged: _save()
    on_DensityChanged: _save()
    on_ShowFogChanged: _save()
    on_ShowRaysChanged: _save()
    on_ShowParticlesChanged: _save()
    on_ShowVignetteChanged: _save()
    on_DustAmountChanged: _save()
    on_DustSizeChanged: _save()
    on_SpeedIndexChanged: _save()
    on_RotationChanged: _save()
    on_MicrobeMotionChanged: _save()
    on_FpsCapChanged: _save()
    on_FpsLimitChanged: _save()
    on_DimCapChanged: _save()
    on_DimLevelChanged: _save()

    // Restore all settings to their schema defaults
    function reset() {
        cfg_EffectMicroscopeZoomSettings = EffectSettings.save(_defaults)
    }

    // --- External config sync (e.g. "Set Current Theme" context menu) ---
    Connections {
        target: effectConfig.hubConfiguration
        enabled: effectConfig.hubConfiguration !== null
        function onValueChanged(key, value) {
            if (key === "EffectMicroscopeZoomSettings") {
                effectConfig._load()
            }
        }
    }

    // --- Theme scanner (shared by pages) ---
    readonly property alias themeScanner: themeScanner
    ThemeScanner {
        id: themeScanner
    }

    function findThemeIndex(themeId) {
        for (var i = 0; i < themeScanner.themeList.count; i++) {
            if (themeScanner.themeList.get(i).themeId === themeId) {
                return i
            }
        }
        return 0
    }

    // --- Page definitions for sidebar navigation ---
    readonly property var pages: [
        { moduleId: "theme", text: qsTr("Theme"), icon: "preferences-desktop-color", page: "MicroscopeZoomThemePage.qml" },
        { moduleId: "scene", text: qsTr("Scene"), icon: "view-visible", page: "MicroscopeZoomScenePage.qml" },
        { moduleId: "animation", text: qsTr("Animation"), icon: "media-playback-start", page: "MicroscopeZoomAnimationPage.qml" }
    ]
}
