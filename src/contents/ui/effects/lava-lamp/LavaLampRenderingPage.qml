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
    title: i18n("Rendering")

    required property var effectConfig

    Kirigami.FormLayout {
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Number of orbs:")
            from: 16
            to: 70
            stepSize: 1
            value: page.effectConfig._orbCount
            onValueModified: page.effectConfig._orbCount = value
        }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Glow effect:")
            checked: page.effectConfig._showGlow
            onToggled: page.effectConfig._showGlow = checked
        }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Background gradient:")
            checked: page.effectConfig._showBackgroundGradient
            onToggled: page.effectConfig._showBackgroundGradient = checked
        }
    }
}
