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

    readonly property string filterId: "pixelate"
    readonly property string filterName: qsTr("Pixelate")
    readonly property url settingsUrl: Qt.resolvedUrl("PixelateSettings.qml")
    readonly property int shaderIndex: 0
    readonly property bool isPassBreaker: false

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({ show: false, size: 8 })

    readonly property var uniforms: ({
        showPixelate: _show ? 1.0 : 0.0,
        pixelateSize: _size
    })

    property bool _show: false
    property int _size: 8
    property bool _loading: false

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _size = s.size
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({ show: _show, size: _size })
    }
    on_ShowChanged: _save()
    on_SizeChanged: _save()

    function toggle() { _show = !_show }
    function reset() { _size = defaults.size }
}
