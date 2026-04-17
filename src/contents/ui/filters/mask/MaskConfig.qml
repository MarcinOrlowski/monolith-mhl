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
    id: filterConfig

    readonly property string filterId: "mask"
    readonly property string filterName: qsTr("Mask")
    readonly property url settingsUrl: Qt.resolvedUrl("MaskSettings.qml")
    readonly property int shaderIndex: 7
    readonly property bool isPassBreaker: false

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({
        show: false, side: 64, padding: 8, invert: false, color: "#000000",
        sparkShow: false, sparkRadius: 8, sparkThreshold: 30, sparkStrength: 100
    })

    readonly property var uniforms: ({
        showMask: _show ? 1.0 : 0.0,
        maskSide: _side,
        maskPadding: _padding,
        maskInvert: _invert ? 1.0 : 0.0,
        maskColorR: _parsedColor[0],
        maskColorG: _parsedColor[1],
        maskColorB: _parsedColor[2],
        showMaskSpark: _sparkShow ? 1.0 : 0.0,
        maskSparkRadius: _sparkRadius,
        maskSparkThreshold: _sparkThreshold / 100.0,
        maskSparkStrength: _sparkStrength / 100.0
    })

    property bool _show: false
    property int _side: 64
    property int _padding: 8
    property bool _invert: false
    property string _color: "#000000"
    property bool _sparkShow: false
    property int _sparkRadius: 8
    property int _sparkThreshold: 30
    property int _sparkStrength: 100
    property bool _loading: false

    readonly property var _parsedColor: {
        var c = Qt.color(_color)
        return [c.r, c.g, c.b]
    }

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _side = s.side; _padding = s.padding
        _invert = s.invert; _color = s.color
        _sparkShow = s.sparkShow; _sparkRadius = s.sparkRadius
        _sparkThreshold = s.sparkThreshold; _sparkStrength = s.sparkStrength
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({
            show: _show, side: _side, padding: _padding,
            invert: _invert, color: _color,
            sparkShow: _sparkShow, sparkRadius: _sparkRadius,
            sparkThreshold: _sparkThreshold, sparkStrength: _sparkStrength
        })
    }
    on_ShowChanged: _save()
    on_SideChanged: {
        // Padding must always be strictly less than side
        if (_padding > _side - 1) _padding = Math.max(0, _side - 1)
        _save()
    }
    on_PaddingChanged: {
        if (_padding > _side - 1) { _padding = Math.max(0, _side - 1); return }
        _save()
    }
    on_InvertChanged: _save()
    on_ColorChanged: _save()
    on_SparkShowChanged: _save()
    on_SparkRadiusChanged: _save()
    on_SparkThresholdChanged: _save()
    on_SparkStrengthChanged: _save()

    function toggle() { _show = !_show }
    function reset() {
        _side = defaults.side; _padding = defaults.padding
        _invert = defaults.invert; _color = defaults.color
        _sparkShow = defaults.sparkShow; _sparkRadius = defaults.sparkRadius
        _sparkThreshold = defaults.sparkThreshold; _sparkStrength = defaults.sparkStrength
    }
}
