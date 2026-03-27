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
                text: i18n("Stars")
                checked: page.effectConfig._showStars
                onToggled: page.effectConfig._showStars = checked
            }
            QtControls2.CheckBox {
                text: i18n("Waves")
                checked: page.effectConfig._showWaves
                onToggled: page.effectConfig._showWaves = checked
            }
            QtControls2.CheckBox {
                text: i18n("Ghosts")
                checked: page.effectConfig._showGhosts
                onToggled: page.effectConfig._showGhosts = checked
            }
            QtControls2.CheckBox {
                text: i18n("Halo")
                checked: page.effectConfig._showHalo
                onToggled: page.effectConfig._showHalo = checked
            }
            QtControls2.CheckBox {
                text: i18n("Shine")
                checked: page.effectConfig._showShine
                onToggled: page.effectConfig._showShine = checked
            }
            QtControls2.CheckBox {
                text: i18n("Spots")
                checked: page.effectConfig._showSpotlights
                onToggled: page.effectConfig._showSpotlights = checked
            }
            QtControls2.CheckBox {
                text: i18n("Glow")
                checked: page.effectConfig._showGlow
                onToggled: page.effectConfig._showGlow = checked
            }
            QtControls2.CheckBox {
                text: i18n("Background")
                checked: page.effectConfig._showBackground
                onToggled: page.effectConfig._showBackground = checked
            }
        }
    }
}
