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

    readonly property string filterId: "rgb-offset"
    readonly property string filterName: qsTr("RGB Offset")
    readonly property url settingsUrl: Qt.resolvedUrl("RgbOffsetSettings.qml")
    readonly property int shaderIndex: 5
    readonly property bool isPassBreaker: true

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({ show: false, amount: 5, angle: 0 })

    readonly property var uniforms: ({
        showRgbOffset: _show ? 1.0 : 0.0,
        rgbOffsetAmount: _amount,
        rgbOffsetAngle: _angle
    })

    property bool _show: false
    property int _amount: 5
    property int _angle: 0
    property bool _loading: false

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _amount = s.amount; _angle = s.angle
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({ show: _show, amount: _amount, angle: _angle })
    }
    on_ShowChanged: _save()
    on_AmountChanged: _save()
    on_AngleChanged: _save()

    function toggle() { _show = !_show }
    function reset() { _amount = defaults.amount; _angle = defaults.angle }
}
