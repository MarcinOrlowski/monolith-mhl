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
import QtQuick.Controls as QtControls2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    property var filterConfig

    RowLayout {
        Kirigami.FormData.label: i18n("Strength:")
        spacing: Kirigami.Units.smallSpacing
        QtControls2.SpinBox {
            from: 1; to: 100; stepSize: 1
            value: filterConfig._strength
            onValueModified: filterConfig._strength = value
            textFromValue: function(value) { return (value / 10).toFixed(1) + "x" }
            valueFromText: function(text) { return Math.round(parseFloat(text) * 10) || 10 }
        }
        QtControls2.Button {
            icon.name: "help-about"
            flat: true
            implicitWidth: Kirigami.Units.gridUnit * 2
            implicitHeight: Kirigami.Units.gridUnit * 2
            onClicked: Qt.openUrlExternally("https://en.wikipedia.org/wiki/Chromatic_aberration")
            QtControls2.ToolTip.text: i18n("Learn more about chromatic aberration")
            QtControls2.ToolTip.visible: hovered
        }
    }
}
