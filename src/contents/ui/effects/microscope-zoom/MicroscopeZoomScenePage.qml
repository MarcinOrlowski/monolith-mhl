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
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Density:")
            from: 0; to: 100; stepSize: 5
            value: page.effectConfig._density
            onValueModified: page.effectConfig._density = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Depth fog:")
            text: i18n("Haze the distant shapes into the background light")
            checked: page.effectConfig._showFog
            onToggled: page.effectConfig._showFog = checked
        }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Light rays:")
            text: i18n("Beams fanning out from the focal point")
            checked: page.effectConfig._showRays
            onToggled: page.effectConfig._showRays = checked
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Floating dust:")
            text: i18n("Motes drifting past the lens")
            checked: page.effectConfig._showParticles
            onToggled: page.effectConfig._showParticles = checked
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Dust amount:")
            enabled: page.effectConfig._showParticles
            from: 0; to: 100; stepSize: 5
            value: page.effectConfig._dustAmount
            onValueModified: page.effectConfig._dustAmount = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Dust size:")
            enabled: page.effectConfig._showParticles
            from: 1; to: 100; stepSize: 1
            value: page.effectConfig._dustSize
            onValueModified: page.effectConfig._dustSize = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || page.effectConfig._dustSize }
        }

        Kirigami.Separator { Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Vignette:")
            text: i18n("Darken the frame edges")
            checked: page.effectConfig._showVignette
            onToggled: page.effectConfig._showVignette = checked
        }
    }
}
