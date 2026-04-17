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
        show: false, side: 32, gap: 4, invert: false, color: "#000000"
    })

    readonly property var uniforms: ({
        showMask: _show ? 1.0 : 0.0,
        maskSide: _side,
        maskGap: _gap,
        maskInvert: _invert ? 1.0 : 0.0,
        maskColorR: _parsedColor[0],
        maskColorG: _parsedColor[1],
        maskColorB: _parsedColor[2]
    })

    property bool _show: false
    property int _side: 32
    property int _gap: 4
    property bool _invert: false
    property string _color: "#000000"
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
        _show = s.show; _side = s.side; _gap = s.gap
        _invert = s.invert; _color = s.color
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({
            show: _show, side: _side, gap: _gap,
            invert: _invert, color: _color
        })
    }
    on_ShowChanged: _save()
    on_SideChanged: _save()
    on_GapChanged: _save()
    on_InvertChanged: _save()
    on_ColorChanged: _save()

    function toggle() { _show = !_show }
    function reset() {
        _side = defaults.side; _gap = defaults.gap
        _invert = defaults.invert; _color = defaults.color
    }
}
