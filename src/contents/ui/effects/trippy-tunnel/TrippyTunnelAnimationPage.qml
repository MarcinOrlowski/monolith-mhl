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

Kirigami.ScrollablePage {
    id: page
    title: i18n("Animation")

    required property var effectConfig

    Kirigami.FormLayout {
        QtControls2.ComboBox {
            Kirigami.FormData.label: i18n("Zoom speed:")
            model: ["0.25", "0.5", "0.75", "Normal", "1.25", "1.50", "1.75"]
            currentIndex: page.effectConfig._speedIndex
            onActivated: page.effectConfig._speedIndex = currentIndex
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Tunnel rotation:")
            from: -100; to: 100; stepSize: 5
            value: page.effectConfig._rotSpeed
            onValueModified: page.effectConfig._rotSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Vortex rotation:")
            from: -100; to: 100; stepSize: 5
            value: page.effectConfig._whirlSpeed
            onValueModified: page.effectConfig._whirlSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.Label {
            Kirigami.FormData.label: ""
            text: i18n("Negative values reverse the spin direction.")
            font: Kirigami.Theme.smallFont
            opacity: 0.7
        }

        QtControls2.SpinBox {
            // How long a changed value (swirl, hole, width, opacities, …) takes
            // to ease to its new setting.
            Kirigami.FormData.label: i18n("Value transition:")
            from: 1; to: 50; stepSize: 1
            value: page.effectConfig._transitionTime
            onValueModified: page.effectConfig._transitionTime = value
            textFromValue: function(value) { return (value / 10).toFixed(1) + " s" }
            valueFromText: function(text) { return Math.round((parseFloat(text) || 1.0) * 10) }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("FPS cap:")
            QtControls2.CheckBox {
                checked: page.effectConfig._fpsCap
                onToggled: page.effectConfig._fpsCap = checked
            }
            QtControls2.SpinBox {
                enabled: page.effectConfig._fpsCap
                from: 1
                to: 240
                stepSize: 1
                value: page.effectConfig._fpsLimit
                onValueModified: page.effectConfig._fpsLimit = value
                textFromValue: function(value) { return value + " FPS" }
                valueFromText: function(text) { return parseInt(text) || page.effectConfig._fpsLimit }
            }
        }
    }
}
