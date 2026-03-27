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
            Kirigami.FormData.label: i18n("Animation speed:")
            model: ["0.25", "0.5", "0.75", "Normal", "1.25", "1.50", "1.75"]
            currentIndex: page.effectConfig._speedIndex
            onActivated: page.effectConfig._speedIndex = currentIndex
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
