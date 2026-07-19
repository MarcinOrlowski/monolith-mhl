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
    property string cfg_EffectTrippyTunnelSettings

    property var hubConfiguration: null

    // --- Schema: key → default value (single source of truth) ---
    readonly property var _defaults: ({
        themeId: "ttm-spectrum",
        randomInitialTheme: false,
        autoCycle: true,
        cycleInterval: 20,
        cycleIntervalUnit: 1,
        transitionDuration: 4,
        cycleInRandomOrder: true,
        cycleMode: "all",
        showCanopy: true,
        showGlow: true,
        showVortex: true,
        showStars: true,
        showBeams: true,
        showDots: true,
        speedIndex: 3,
        rotSpeed: 15,
        whirlSpeed: -35,
        spiral: 45,
        vortexSwirl: 45,
        tunnelWidth: 100,
        widthOsc: false,
        widthOscRange: 20,
        widthOscInterval: 10,
        widthOscChance: 50,
        holeRadius: 25,
        holeOsc: true,
        holeOscRange: 5,
        holeOscInterval: 120,
        holeOscChance: 25,
        swirlVary: true,
        swirlSpeed: 10,
        swirlBurst: true,
        swirlVaryMargin: 40,
        swirlVaryInterval: 120,
        swirlVaryChance: 25,
        transitionTime: 10,
        layerCount: 9,
        density: 60,
        glow: 60,
        mist: 75,
        fog: 50,
        canopyOpacity: 100,
        vortexOpacity: 100,
        bloom: 70,
        bloomRadius: 40,
        starCount: 40,
        starSpeed: 50,
        starLength: 35,
        starOpacity: 65,
        beamCount: 220,
        beamSpeed: 20,
        beamLength: 45,
        beamOpacity: 50,
        dotCount: 60,
        dotSpeed: 60,
        dotOpacity: 100,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Backing properties ---
    property string _themeId: "ttm-spectrum"
    property bool _randomInitialTheme: false
    property bool _autoCycle: true
    property int _cycleInterval: 20
    property int _cycleIntervalUnit: 1
    property int _transitionDuration: 4
    property bool _cycleInRandomOrder: true
    property string _cycleMode: "all"
    property bool _showCanopy: true
    property bool _showGlow: true
    property bool _showVortex: true
    property bool _showStars: true
    property bool _showBeams: true
    property bool _showDots: true
    property int _speedIndex: 3
    property int _rotSpeed: 25
    property int _whirlSpeed: -35
    property int _spiral: 45
    property int _vortexSwirl: 45
    property int _tunnelWidth: 100
    property bool _widthOsc: false
    property int _widthOscRange: 20
    property int _widthOscInterval: 10
    property int _widthOscChance: 50
    property int _holeRadius: 25
    property bool _holeOsc: false
    property int _holeOscRange: 20
    property int _holeOscInterval: 10
    property int _holeOscChance: 50
    property bool _swirlVary: false
    property int _swirlSpeed: 20
    property bool _swirlBurst: false
    property int _swirlVaryMargin: 10
    property int _swirlVaryInterval: 8
    property int _swirlVaryChance: 100
    property int _transitionTime: 10
    property int _layerCount: 9
    property int _density: 60
    property int _glow: 60
    property int _mist: 75
    property int _fog: 50
    property int _canopyOpacity: 100
    property int _vortexOpacity: 100
    property int _bloom: 70
    property int _bloomRadius: 40
    property int _starCount: 40
    property int _starSpeed: 100
    property int _starLength: 35
    property int _starOpacity: 100
    property int _beamCount: 220
    property int _beamSpeed: 100
    property int _beamLength: 45
    property int _beamOpacity: 100
    property int _dotCount: 60
    property int _dotSpeed: 100
    property int _dotOpacity: 100
    property bool _fpsCap: true
    property int _fpsLimit: 30
    property bool _dimCap: false
    property int _dimLevel: 100

    // --- Load / save plumbing ---
    property bool _loading: false

    onCfg_EffectTrippyTunnelSettingsChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(cfg_EffectTrippyTunnelSettings, _defaults)
        _themeId = s.themeId
        _randomInitialTheme = s.randomInitialTheme
        _autoCycle = s.autoCycle
        _cycleInterval = s.cycleInterval
        _cycleIntervalUnit = s.cycleIntervalUnit
        _transitionDuration = s.transitionDuration
        _cycleInRandomOrder = s.cycleInRandomOrder
        _cycleMode = s.cycleMode
        _showCanopy = s.showCanopy
        _showGlow = s.showGlow
        _showVortex = s.showVortex
        _showStars = s.showStars
        _showBeams = s.showBeams
        _showDots = s.showDots
        _speedIndex = s.speedIndex
        _rotSpeed = s.rotSpeed
        _whirlSpeed = s.whirlSpeed
        _spiral = s.spiral
        _vortexSwirl = s.vortexSwirl
        _tunnelWidth = s.tunnelWidth
        _widthOsc = s.widthOsc
        _widthOscRange = s.widthOscRange
        _widthOscInterval = s.widthOscInterval
        _widthOscChance = s.widthOscChance
        _holeRadius = s.holeRadius
        _holeOsc = s.holeOsc
        _holeOscRange = s.holeOscRange
        _holeOscInterval = s.holeOscInterval
        _holeOscChance = s.holeOscChance
        _swirlVary = s.swirlVary
        _swirlSpeed = s.swirlSpeed
        _swirlBurst = s.swirlBurst
        _swirlVaryMargin = s.swirlVaryMargin
        _swirlVaryInterval = s.swirlVaryInterval
        _swirlVaryChance = s.swirlVaryChance
        _transitionTime = s.transitionTime
        _layerCount = s.layerCount
        _density = s.density
        _glow = s.glow
        _mist = s.mist
        _fog = s.fog
        _canopyOpacity = s.canopyOpacity
        _vortexOpacity = s.vortexOpacity
        _bloom = s.bloom
        _bloomRadius = s.bloomRadius
        _starCount = s.starCount
        _starSpeed = s.starSpeed
        _starLength = s.starLength
        _starOpacity = s.starOpacity
        _beamCount = s.beamCount
        _beamSpeed = s.beamSpeed
        _beamLength = s.beamLength
        _beamOpacity = s.beamOpacity
        _dotCount = s.dotCount
        _dotSpeed = s.dotSpeed
        _dotOpacity = s.dotOpacity
        _fpsCap = s.fpsCap
        _fpsLimit = s.fpsLimit
        _dimCap = s.dimCap
        _dimLevel = s.dimLevel
        _loading = false
    }

    function _save() {
        if (_loading) return
        cfg_EffectTrippyTunnelSettings = EffectSettings.save({
            themeId: _themeId,
            randomInitialTheme: _randomInitialTheme,
            autoCycle: _autoCycle,
            cycleInterval: _cycleInterval,
            cycleIntervalUnit: _cycleIntervalUnit,
            transitionDuration: _transitionDuration,
            cycleInRandomOrder: _cycleInRandomOrder,
            cycleMode: _cycleMode,
            showCanopy: _showCanopy,
            showGlow: _showGlow,
            showVortex: _showVortex,
            showStars: _showStars,
            showBeams: _showBeams,
            showDots: _showDots,
            speedIndex: _speedIndex,
            rotSpeed: _rotSpeed,
            whirlSpeed: _whirlSpeed,
            spiral: _spiral,
            vortexSwirl: _vortexSwirl,
            tunnelWidth: _tunnelWidth,
            widthOsc: _widthOsc,
            widthOscRange: _widthOscRange,
            widthOscInterval: _widthOscInterval,
            widthOscChance: _widthOscChance,
            holeRadius: _holeRadius,
            holeOsc: _holeOsc,
            holeOscRange: _holeOscRange,
            holeOscInterval: _holeOscInterval,
            holeOscChance: _holeOscChance,
            swirlVary: _swirlVary,
            swirlSpeed: _swirlSpeed,
            swirlBurst: _swirlBurst,
            swirlVaryMargin: _swirlVaryMargin,
            swirlVaryInterval: _swirlVaryInterval,
            swirlVaryChance: _swirlVaryChance,
            transitionTime: _transitionTime,
            layerCount: _layerCount,
            density: _density,
            glow: _glow,
            mist: _mist,
            fog: _fog,
            canopyOpacity: _canopyOpacity,
            vortexOpacity: _vortexOpacity,
            bloom: _bloom,
            bloomRadius: _bloomRadius,
            starCount: _starCount,
            starSpeed: _starSpeed,
            starLength: _starLength,
            starOpacity: _starOpacity,
            beamCount: _beamCount,
            beamSpeed: _beamSpeed,
            beamLength: _beamLength,
            beamOpacity: _beamOpacity,
            dotCount: _dotCount,
            dotSpeed: _dotSpeed,
            dotOpacity: _dotOpacity,
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
    on_ShowCanopyChanged: _save()
    on_ShowGlowChanged: _save()
    on_ShowVortexChanged: _save()
    on_ShowStarsChanged: _save()
    on_ShowBeamsChanged: _save()
    on_ShowDotsChanged: _save()
    on_SpeedIndexChanged: _save()
    on_RotSpeedChanged: _save()
    on_WhirlSpeedChanged: _save()
    on_SpiralChanged: _save()
    on_VortexSwirlChanged: _save()
    on_TunnelWidthChanged: _save()
    on_WidthOscChanged: _save()
    on_WidthOscRangeChanged: _save()
    on_WidthOscIntervalChanged: _save()
    on_WidthOscChanceChanged: _save()
    on_HoleRadiusChanged: _save()
    on_HoleOscChanged: _save()
    on_HoleOscRangeChanged: _save()
    on_HoleOscIntervalChanged: _save()
    on_HoleOscChanceChanged: _save()
    on_SwirlVaryChanged: _save()
    on_SwirlSpeedChanged: _save()
    on_SwirlBurstChanged: _save()
    on_SwirlVaryMarginChanged: _save()
    on_SwirlVaryIntervalChanged: _save()
    on_SwirlVaryChanceChanged: _save()
    on_TransitionTimeChanged: _save()
    on_LayerCountChanged: _save()
    on_DensityChanged: _save()
    on_GlowChanged: _save()
    on_MistChanged: _save()
    on_FogChanged: _save()
    on_CanopyOpacityChanged: _save()
    on_VortexOpacityChanged: _save()
    on_BloomChanged: _save()
    on_BloomRadiusChanged: _save()
    on_StarCountChanged: _save()
    on_StarSpeedChanged: _save()
    on_StarLengthChanged: _save()
    on_StarOpacityChanged: _save()
    on_BeamCountChanged: _save()
    on_BeamSpeedChanged: _save()
    on_BeamLengthChanged: _save()
    on_BeamOpacityChanged: _save()
    on_DotCountChanged: _save()
    on_DotSpeedChanged: _save()
    on_DotOpacityChanged: _save()
    on_FpsCapChanged: _save()
    on_FpsLimitChanged: _save()
    on_DimCapChanged: _save()
    on_DimLevelChanged: _save()

    // Restore all settings to their schema defaults
    function reset() {
        cfg_EffectTrippyTunnelSettings = EffectSettings.save(_defaults)
    }

    // --- External config sync (e.g. "Set Current Theme" context menu) ---
    Connections {
        target: effectConfig.hubConfiguration
        enabled: effectConfig.hubConfiguration !== null
        function onValueChanged(key, value) {
            if (key === "EffectTrippyTunnelSettings") {
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
        { moduleId: "layers", text: qsTr("Layers"), icon: "view-visible", page: "TrippyTunnelLayersPage.qml" },
        { moduleId: "theme", text: qsTr("Theme"), icon: "color-management", page: "TrippyTunnelThemePage.qml" },
        { moduleId: "animation", text: qsTr("Animation"), icon: "media-playback-start", page: "TrippyTunnelAnimationPage.qml" }
    ]
}
