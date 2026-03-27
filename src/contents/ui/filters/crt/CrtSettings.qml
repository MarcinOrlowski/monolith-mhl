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
        Kirigami.FormData.label: i18n("Curvature:")
        QtControls2.SpinBox {
            from: 1; to: 50; stepSize: 1
            value: filterConfig._curvature
            onValueModified: filterConfig._curvature = value
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Vignette:")
        QtControls2.SpinBox {
            from: 0; to: 100; stepSize: 5
            value: filterConfig._vignette
            onValueModified: filterConfig._vignette = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 30 }
        }
    }
}
