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

    readonly property string filterId: "blur"
    readonly property string filterName: qsTr("Blur")
    readonly property url settingsUrl: Qt.resolvedUrl("BlurSettings.qml")
    readonly property int shaderIndex: -1
    readonly property bool isPassBreaker: true

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({ show: false, radius: 8 })

    readonly property var uniforms: ({
        filterBlur: _show,
        blurRadius: _radius
    })

    property bool _show: false
    property int _radius: 8
    property bool _loading: false

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _radius = s.radius
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({ show: _show, radius: _radius })
    }
    on_ShowChanged: _save()
    on_RadiusChanged: _save()

    function toggle() { _show = !_show }
    function reset() { _radius = defaults.radius }
}
