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
    property string cfg_EffectTrippyForestSettings

    property var hubConfiguration: null

    // --- Schema: key → default value (single source of truth) ---
    readonly property var _defaults: ({
        themeId: "tfm-spectrum",
        randomInitialTheme: false,
        autoCycle: true,
        cycleInterval: 20,
        cycleIntervalUnit: 1,
        transitionDuration: 4,
        cycleInRandomOrder: true,
        cycleMode: "all",
        showFoliage: true,
        showGlow: true,
        showVortex: true,
        speedIndex: 3,
        rotSpeed: 25,
        whirlSpeed: -35,
        spiral: 45,
        density: 60,
        glow: 60,
        mist: 75,
        fog: 50,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Backing properties ---
    property string _themeId: "tfm-spectrum"
    property bool _randomInitialTheme: false
    property bool _autoCycle: true
    property int _cycleInterval: 20
    property int _cycleIntervalUnit: 1
    property int _transitionDuration: 4
    property bool _cycleInRandomOrder: true
    property string _cycleMode: "all"
    property bool _showFoliage: true
    property bool _showGlow: true
    property bool _showVortex: true
    property int _speedIndex: 3
    property int _rotSpeed: 25
    property int _whirlSpeed: -35
    property int _spiral: 45
    property int _density: 60
    property int _glow: 60
    property int _mist: 75
    property int _fog: 50
    property bool _fpsCap: true
    property int _fpsLimit: 30
    property bool _dimCap: false
    property int _dimLevel: 100

    // --- Load / save plumbing ---
    property bool _loading: false

    onCfg_EffectTrippyForestSettingsChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(cfg_EffectTrippyForestSettings, _defaults)
        _themeId = s.themeId
        _randomInitialTheme = s.randomInitialTheme
        _autoCycle = s.autoCycle
        _cycleInterval = s.cycleInterval
        _cycleIntervalUnit = s.cycleIntervalUnit
        _transitionDuration = s.transitionDuration
        _cycleInRandomOrder = s.cycleInRandomOrder
        _cycleMode = s.cycleMode
        _showFoliage = s.showFoliage
        _showGlow = s.showGlow
        _showVortex = s.showVortex
        _speedIndex = s.speedIndex
        _rotSpeed = s.rotSpeed
        _whirlSpeed = s.whirlSpeed
        _spiral = s.spiral
        _density = s.density
        _glow = s.glow
        _mist = s.mist
        _fog = s.fog
        _fpsCap = s.fpsCap
        _fpsLimit = s.fpsLimit
        _dimCap = s.dimCap
        _dimLevel = s.dimLevel
        _loading = false
    }

    function _save() {
        if (_loading) return
        cfg_EffectTrippyForestSettings = EffectSettings.save({
            themeId: _themeId,
            randomInitialTheme: _randomInitialTheme,
            autoCycle: _autoCycle,
            cycleInterval: _cycleInterval,
            cycleIntervalUnit: _cycleIntervalUnit,
            transitionDuration: _transitionDuration,
            cycleInRandomOrder: _cycleInRandomOrder,
            cycleMode: _cycleMode,
            showFoliage: _showFoliage,
            showGlow: _showGlow,
            showVortex: _showVortex,
            speedIndex: _speedIndex,
            rotSpeed: _rotSpeed,
            whirlSpeed: _whirlSpeed,
            spiral: _spiral,
            density: _density,
            glow: _glow,
            mist: _mist,
            fog: _fog,
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
    on_CycleModeChanged: _save()
    on_ShowFoliageChanged: _save()
    on_ShowGlowChanged: _save()
    on_ShowVortexChanged: _save()
    on_SpeedIndexChanged: _save()
    on_RotSpeedChanged: _save()
    on_WhirlSpeedChanged: _save()
    on_SpiralChanged: _save()
    on_DensityChanged: _save()
    on_GlowChanged: _save()
    on_MistChanged: _save()
    on_FogChanged: _save()
    on_FpsCapChanged: _save()
    on_FpsLimitChanged: _save()
    on_DimCapChanged: _save()
    on_DimLevelChanged: _save()

    // Restore all settings to their schema defaults
    function reset() {
        cfg_EffectTrippyForestSettings = EffectSettings.save(_defaults)
    }

    // --- External config sync (e.g. "Set Current Theme" context menu) ---
    Connections {
        target: effectConfig.hubConfiguration
        enabled: effectConfig.hubConfiguration !== null
        function onValueChanged(key, value) {
            if (key === "EffectTrippyForestSettings") {
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
        { moduleId: "appearance", text: qsTr("Appearance"), icon: "preferences-desktop-color", page: "TrippyForestAppearancePage.qml" },
        { moduleId: "theme", text: qsTr("Theme"), icon: "color-management", page: "TrippyForestThemePage.qml" },
        { moduleId: "layers", text: qsTr("Layers"), icon: "view-visible", page: "TrippyForestLayersPage.qml" },
        { moduleId: "animation", text: qsTr("Animation"), icon: "media-playback-start", page: "TrippyForestAnimationPage.qml" }
    ]
}
