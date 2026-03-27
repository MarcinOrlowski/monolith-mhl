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

    readonly property string filterId: "color-grading"
    readonly property string filterName: qsTr("Color Grading")
    readonly property url settingsUrl: Qt.resolvedUrl("ColorGradingSettings.qml")
    readonly property int shaderIndex: 3
    readonly property bool isPassBreaker: false

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({ show: false, gamma: 100, contrast: 100, temperature: 0, tint: 0 })

    readonly property var uniforms: ({
        showColorGrading: _show ? 1.0 : 0.0,
        cgGamma: _gamma / 100.0,
        cgContrast: _contrast / 100.0,
        cgTemperature: _temperature,
        cgTint: _tint
    })

    property bool _show: false
    property int _gamma: 100
    property int _contrast: 100
    property int _temperature: 0
    property int _tint: 0
    property bool _loading: false

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _gamma = s.gamma; _contrast = s.contrast
        _temperature = s.temperature; _tint = s.tint
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({
            show: _show, gamma: _gamma, contrast: _contrast,
            temperature: _temperature, tint: _tint
        })
    }
    on_ShowChanged: _save()
    on_GammaChanged: _save()
    on_ContrastChanged: _save()
    on_TemperatureChanged: _save()
    on_TintChanged: _save()

    function toggle() { _show = !_show }
    function reset() {
        _gamma = defaults.gamma; _contrast = defaults.contrast
        _temperature = defaults.temperature; _tint = defaults.tint
    }
}
