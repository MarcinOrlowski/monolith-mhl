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
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page
    title: i18n("Scene")

    required property var effectConfig

    Kirigami.FormLayout {
        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Depth fog:")
            text: i18n("Haze the far foliage into the canopy light")
            checked: page.effectConfig._showFog
            onToggled: page.effectConfig._showFog = checked
        }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Light rays:")
            text: i18n("Sun beams fanning out from the vanishing point")
            checked: page.effectConfig._showRays
            onToggled: page.effectConfig._showRays = checked
        }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Floating spores:")
            text: i18n("Motes drifting past the camera")
            checked: page.effectConfig._showParticles
            onToggled: page.effectConfig._showParticles = checked
        }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Vignette:")
            text: i18n("Darken the frame edges")
            checked: page.effectConfig._showVignette
            onToggled: page.effectConfig._showVignette = checked
        }
    }
}
