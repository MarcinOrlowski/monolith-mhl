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

    readonly property string filterId: "scanlines"
    readonly property string filterName: qsTr("Scanlines")
    readonly property url settingsUrl: Qt.resolvedUrl("ScanlinesSettings.qml")
    readonly property int shaderIndex: 1
    readonly property bool isPassBreaker: false

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({
        show: false, intensity: 50, frequency: 10, thickness: 10,
        speed: 0, color: "#000000", opacity: 0
    })

    readonly property var uniforms: ({
        showScanlines: _show ? 1.0 : 0.0,
        scanlineIntensity: _intensity / 100.0,
        scanlineFrequency: _frequency / 10.0,
        scanlineThickness: _thickness / 10.0,
        scanlineSpeed: _speed / 10.0,
        scanlineColorR: _parsedColor[0],
        scanlineColorG: _parsedColor[1],
        scanlineColorB: _parsedColor[2],
        scanlineOpacity: _opacity / 100.0
    })

    property bool _show: false
    property int _intensity: 50
    property int _frequency: 10
    property int _thickness: 10
    property int _speed: 0
    property string _color: "#000000"
    property int _opacity: 0
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
        _show = s.show; _intensity = s.intensity; _frequency = s.frequency
        _thickness = s.thickness; _speed = s.speed; _color = s.color; _opacity = s.opacity
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({
            show: _show, intensity: _intensity, frequency: _frequency,
            thickness: _thickness, speed: _speed, color: _color, opacity: _opacity
        })
    }
    on_ShowChanged: _save()
    on_IntensityChanged: _save()
    on_FrequencyChanged: _save()
    on_ThicknessChanged: _save()
    on_SpeedChanged: _save()
    on_ColorChanged: _save()
    on_OpacityChanged: _save()

    function toggle() { _show = !_show }
    function reset() {
        _intensity = defaults.intensity; _frequency = defaults.frequency
        _thickness = defaults.thickness; _speed = defaults.speed
        _color = defaults.color; _opacity = defaults.opacity
    }
}
