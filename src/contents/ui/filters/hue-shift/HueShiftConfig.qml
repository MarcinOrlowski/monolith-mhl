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

    readonly property string filterId: "hue-shift"
    readonly property string filterName: qsTr("Hue Shift")
    readonly property url settingsUrl: Qt.resolvedUrl("HueShiftSettings.qml")
    readonly property int shaderIndex: 4
    readonly property bool isPassBreaker: false

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({ show: false, angle: 180 })

    readonly property var uniforms: ({
        showHueShift: _show ? 1.0 : 0.0,
        hueShiftAngle: _angle
    })

    property bool _show: false
    property int _angle: 180
    property bool _loading: false

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _angle = s.angle
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({ show: _show, angle: _angle })
    }
    on_ShowChanged: _save()
    on_AngleChanged: _save()

    function toggle() { _show = !_show }
    function reset() { _angle = defaults.angle }
}
