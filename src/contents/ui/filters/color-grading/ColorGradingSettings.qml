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
        Kirigami.FormData.label: i18n("Gamma:")
        QtControls2.SpinBox {
            from: 50; to: 200; stepSize: 5
            value: filterConfig._gamma
            onValueModified: filterConfig._gamma = value
            textFromValue: function(value) { return (value / 100).toFixed(2) }
            valueFromText: function(text) { return Math.round(parseFloat(text) * 100) || 100 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Contrast:")
        QtControls2.SpinBox {
            from: 50; to: 200; stepSize: 5
            value: filterConfig._contrast
            onValueModified: filterConfig._contrast = value
            textFromValue: function(value) { return (value / 100).toFixed(2) }
            valueFromText: function(text) { return Math.round(parseFloat(text) * 100) || 100 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Temperature:")
        QtControls2.SpinBox {
            from: -100; to: 100; stepSize: 5
            value: filterConfig._temperature
            onValueModified: filterConfig._temperature = value
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Tint:")
        QtControls2.SpinBox {
            from: -100; to: 100; stepSize: 5
            value: filterConfig._tint
            onValueModified: filterConfig._tint = value
        }
    }
}
