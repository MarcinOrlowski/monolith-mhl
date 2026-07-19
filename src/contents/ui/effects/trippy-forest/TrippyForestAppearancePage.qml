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
    title: i18n("Appearance")

    required property var effectConfig

    Kirigami.FormLayout {
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Canopy density:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showFoliage
            value: page.effectConfig._density
            onValueModified: page.effectConfig._density = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Swirl:")
            from: 0; to: 100; stepSize: 5
            value: page.effectConfig._spiral
            onValueModified: page.effectConfig._spiral = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Glow spots:")
            from: 0; to: 100; stepSize: 5
            // Glow spots render on the canopy leaves.
            enabled: page.effectConfig._showFoliage && page.effectConfig._showGlow
            value: page.effectConfig._glow
            onValueModified: page.effectConfig._glow = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Centre glow:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showVortex
            value: page.effectConfig._mist
            onValueModified: page.effectConfig._mist = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Depth haze:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showFoliage
            value: page.effectConfig._fog
            onValueModified: page.effectConfig._fog = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        Kirigami.Separator { Kirigami.FormData.label: i18n("Stars (points)"); Kirigami.FormData.isSection: true }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Star count:")
            from: 0; to: 128; stepSize: 4
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starCount
            onValueModified: page.effectConfig._starCount = value
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Star speed:")
            from: 0; to: 300; stepSize: 10
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starSpeed
            onValueModified: page.effectConfig._starSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Star length:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starLength
            onValueModified: page.effectConfig._starLength = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Star opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starOpacity
            onValueModified: page.effectConfig._starOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        Kirigami.Separator { Kirigami.FormData.label: i18n("Beams (hyperspace)"); Kirigami.FormData.isSection: true }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Beam count:")
            from: 4; to: 800; stepSize: 10
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamCount
            onValueModified: page.effectConfig._beamCount = value
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Beam speed:")
            from: 0; to: 300; stepSize: 10
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamSpeed
            onValueModified: page.effectConfig._beamSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Beam length:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamLength
            onValueModified: page.effectConfig._beamLength = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Beam opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamOpacity
            onValueModified: page.effectConfig._beamOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
    }
}
