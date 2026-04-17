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
    property string cfg_EffectLavaLampSettings

    property var hubConfiguration: null

    // --- Schema: key → default value (single source of truth) ---
    readonly property var _defaults: ({
        themeId: "llm-heat",
        randomInitialTheme: true,
        autoCycle: true,
        cycleInterval: 15,
        cycleIntervalUnit: 1,
        transitionDuration: 3,
        cycleInRandomOrder: true,
        orbCount: 35,
        showGlow: true,
        showBackgroundGradient: true,
        speedIndex: 3,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Backing properties ---
    property string _themeId: "llm-heat"
    property bool _randomInitialTheme: true
    property bool _autoCycle: true
    property int _cycleInterval: 15
    property int _cycleIntervalUnit: 1
    property int _transitionDuration: 3
    property bool _cycleInRandomOrder: true
    property int _orbCount: 35
    property bool _showGlow: true
    property bool _showBackgroundGradient: true
    property int _speedIndex: 3
    property bool _fpsCap: true
    property int _fpsLimit: 30
    property bool _dimCap: false
    property int _dimLevel: 100

    // --- Load / save plumbing ---
    property bool _loading: false

    onCfg_EffectLavaLampSettingsChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(cfg_EffectLavaLampSettings, _defaults)
        _themeId = s.themeId
        _randomInitialTheme = s.randomInitialTheme
        _autoCycle = s.autoCycle
        _cycleInterval = s.cycleInterval
        _cycleIntervalUnit = s.cycleIntervalUnit
        _transitionDuration = s.transitionDuration
        _cycleInRandomOrder = s.cycleInRandomOrder
        _orbCount = s.orbCount
        _showGlow = s.showGlow
        _showBackgroundGradient = s.showBackgroundGradient
        _speedIndex = s.speedIndex
        _fpsCap = s.fpsCap
        _fpsLimit = s.fpsLimit
        _dimCap = s.dimCap
        _dimLevel = s.dimLevel
        _loading = false
    }

    function _save() {
        if (_loading) return
        cfg_EffectLavaLampSettings = EffectSettings.save({
            themeId: _themeId,
            randomInitialTheme: _randomInitialTheme,
            autoCycle: _autoCycle,
            cycleInterval: _cycleInterval,
            cycleIntervalUnit: _cycleIntervalUnit,
            transitionDuration: _transitionDuration,
            cycleInRandomOrder: _cycleInRandomOrder,
            orbCount: _orbCount,
            showGlow: _showGlow,
            showBackgroundGradient: _showBackgroundGradient,
            speedIndex: _speedIndex,
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
    on_OrbCountChanged: _save()
    on_ShowGlowChanged: _save()
    on_ShowBackgroundGradientChanged: _save()
    on_SpeedIndexChanged: _save()
    on_FpsCapChanged: _save()
    on_FpsLimitChanged: _save()
    on_DimCapChanged: _save()
    on_DimLevelChanged: _save()

    // --- External config sync (e.g. "Set Current Theme" context menu) ---
    Connections {
        target: effectConfig.hubConfiguration
        enabled: effectConfig.hubConfiguration !== null
        function onValueChanged(key, value) {
            if (key === "EffectLavaLampSettings") {
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
        { moduleId: "animation", text: qsTr("Animation"), icon: "media-playback-start", page: "LavaLampAnimationPage.qml" },
        { moduleId: "theme", text: qsTr("Theme"), icon: "preferences-desktop-color", page: "LavaLampThemePage.qml" },
        { moduleId: "rendering", text: qsTr("Rendering"), icon: "preferences-desktop-display", page: "LavaLampRenderingPage.qml" }
    ]
}
