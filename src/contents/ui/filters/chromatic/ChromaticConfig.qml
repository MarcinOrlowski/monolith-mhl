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

    readonly property string filterId: "chromatic"
    readonly property string filterName: qsTr("Chromatic Aberration")
    readonly property url settingsUrl: Qt.resolvedUrl("ChromaticSettings.qml")
    readonly property int shaderIndex: 2
    readonly property bool isPassBreaker: false

    property string settingsBlob: "{}"
    readonly property bool show: _show

    readonly property var defaults: ({ show: false, strength: 10 })

    readonly property var uniforms: ({
        showChromatic: _show ? 1.0 : 0.0,
        chromaticStrength: _strength / 10.0
    })

    property bool _show: false
    property int _strength: 10
    property bool _loading: false

    onSettingsBlobChanged: _load()
    Component.onCompleted: _load()

    function _load() {
        _loading = true
        var s = EffectSettings.load(settingsBlob, defaults)
        _show = s.show; _strength = s.strength
        _loading = false
    }
    function _save() {
        if (_loading) return
        settingsBlob = EffectSettings.save({ show: _show, strength: _strength })
    }
    on_ShowChanged: _save()
    on_StrengthChanged: _save()

    function toggle() { _show = !_show }
    function reset() { _strength = defaults.strength }
}
