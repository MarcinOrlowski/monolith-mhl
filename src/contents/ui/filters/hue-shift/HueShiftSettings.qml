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
        Kirigami.FormData.label: i18n("Angle:")
        QtControls2.SpinBox {
            from: 0; to: 360; stepSize: 5
            value: filterConfig._angle
            onValueModified: filterConfig._angle = value
            textFromValue: function(value) { return value + "\u00B0" }
            valueFromText: function(text) { return parseInt(text) || 180 }
        }
    }
}
