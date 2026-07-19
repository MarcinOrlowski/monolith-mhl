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
    title: i18n("Layers")

    required property var effectConfig

    Kirigami.FormLayout {
        GridLayout {
            columns: 1

            QtControls2.CheckBox {
                text: i18n("Canopy")
                checked: page.effectConfig._showFoliage
                onToggled: page.effectConfig._showFoliage = checked
            }
            QtControls2.CheckBox {
                // Glow spots sit on the canopy leaves, so they need it to show.
                text: i18n("Glow spots")
                enabled: page.effectConfig._showFoliage
                checked: page.effectConfig._showGlow
                onToggled: page.effectConfig._showGlow = checked
            }
            QtControls2.CheckBox {
                text: i18n("Centre glow (vortex)")
                checked: page.effectConfig._showVortex
                onToggled: page.effectConfig._showVortex = checked
            }
            QtControls2.CheckBox {
                text: i18n("Stars (points)")
                checked: page.effectConfig._showStars
                onToggled: page.effectConfig._showStars = checked
            }
            QtControls2.CheckBox {
                text: i18n("Beams (hyperspace)")
                checked: page.effectConfig._showBeams
                onToggled: page.effectConfig._showBeams = checked
            }
            QtControls2.CheckBox {
                text: i18n("Dots (twinkling stars)")
                checked: page.effectConfig._showDots
                onToggled: page.effectConfig._showDots = checked
            }
        }
    }
}
