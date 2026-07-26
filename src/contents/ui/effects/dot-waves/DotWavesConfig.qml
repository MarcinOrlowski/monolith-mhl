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
    property string cfg_EffectDotWavesSettings

    property var hubConfiguration: null

    // --- Schema: key → default value (single source of truth) ---
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

    // --- Backing properties ---
    property int _spacing: 22
    property int _dotRadius: 14
    property int _density: 100
    property int _contrast: 18
    property int _maxAlpha: 35
    property string _dotColor: "#c8c8c8"
    property string _bgColor: "#1c1c1c"
    property int _speedIndex: 3
    property bool _fpsCap: true
    property int _fpsLimit: 30
    property bool _dimCap: false
    property int _dimLevel: 100
    property bool _shineEnabled: false
    property int _shineMode: 0
    property int _shineChannel: 2
    property int _shineIntensity: 60
    property int _shineSpeedIndex: 3
    property string _shineColor: "#ffffff"
    property int _shineWidth: 30

    // --- Load / save plumbing ---
    property bool _loading: false

    onCfg_EffectDotWavesSettingsChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(cfg_EffectDotWavesSettings, _defaults)
        _spacing = s.spacing
        _dotRadius = s.dotRadius
        _density = s.density
        _contrast = s.contrast
        _maxAlpha = s.maxAlpha
        _dotColor = s.dotColor
        _bgColor = s.bgColor
        _speedIndex = s.speedIndex
        _fpsCap = s.fpsCap
        _fpsLimit = s.fpsLimit
        _dimCap = s.dimCap
        _dimLevel = s.dimLevel
        _shineEnabled = s.shineEnabled
        _shineMode = s.shineMode
        _shineChannel = s.shineChannel
        _shineIntensity = s.shineIntensity
        _shineSpeedIndex = s.shineSpeedIndex
        _shineColor = s.shineColor
        _shineWidth = s.shineWidth
        _loading = false
    }

    function _save() {
        if (_loading) return
        cfg_EffectDotWavesSettings = EffectSettings.save({
            spacing: _spacing,
            dotRadius: _dotRadius,
            density: _density,
            contrast: _contrast,
            maxAlpha: _maxAlpha,
            dotColor: _dotColor,
            bgColor: _bgColor,
            speedIndex: _speedIndex,
            fpsCap: _fpsCap,
            fpsLimit: _fpsLimit,
            dimCap: _dimCap,
            dimLevel: _dimLevel,
            shineEnabled: _shineEnabled,
            shineMode: _shineMode,
            shineChannel: _shineChannel,
            shineIntensity: _shineIntensity,
            shineSpeedIndex: _shineSpeedIndex,
            shineColor: _shineColor,
            shineWidth: _shineWidth
        })
    }

    on_SpacingChanged: _save()
    on_DotRadiusChanged: _save()
    on_DensityChanged: _save()
    on_ContrastChanged: _save()
    on_MaxAlphaChanged: _save()
    on_DotColorChanged: _save()
    on_BgColorChanged: _save()
    on_SpeedIndexChanged: _save()
    on_FpsCapChanged: _save()
    on_FpsLimitChanged: _save()
    on_DimCapChanged: _save()
    on_DimLevelChanged: _save()
    on_ShineEnabledChanged: _save()
    on_ShineModeChanged: _save()
    on_ShineChannelChanged: _save()
    on_ShineIntensityChanged: _save()
    on_ShineSpeedIndexChanged: _save()
    on_ShineColorChanged: _save()
    on_ShineWidthChanged: _save()

    // Restore all settings to their schema defaults
    function reset() {
        cfg_EffectDotWavesSettings = EffectSettings.save(_defaults)
    }

    // --- Page definitions for sidebar navigation ---
    readonly property var pages: [
        { moduleId: "appearance", text: qsTr("Appearance"), icon: "preferences-desktop-color", page: "DotWavesAppearancePage.qml" },
        { moduleId: "shine", text: qsTr("Shine"), icon: "color-gradient", page: "DotWavesShinePage.qml" },
        { moduleId: "animation", text: qsTr("Animation"), icon: "media-playback-start", page: "DotWavesAnimationPage.qml" }
    ]
}
