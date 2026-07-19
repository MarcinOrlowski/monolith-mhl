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

        // ── Canopy ────────────────────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.label: i18n("Canopy"); Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Visible:")
            checked: page.effectConfig._showCanopy
            onToggled: page.effectConfig._showCanopy = checked
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Density:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showCanopy
            value: page.effectConfig._density
            onValueModified: page.effectConfig._density = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Tunnel swirl:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showCanopy
            value: page.effectConfig._spiral
            onValueModified: page.effectConfig._spiral = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Auto-swirl:")
            QtControls2.CheckBox {
                enabled: page.effectConfig._showCanopy
                checked: page.effectConfig._swirlVary
                onToggled: page.effectConfig._swirlVary = checked
            }
            QtControls2.SpinBox {
                enabled: page.effectConfig._showCanopy && page.effectConfig._swirlVary
                from: 0; to: 100; stepSize: 5
                value: page.effectConfig._swirlSpeed
                onValueModified: page.effectConfig._swirlSpeed = value
                textFromValue: function(value) { return value === 0 ? i18n("off") : i18n("speed %1%", value) }
                valueFromText: function(text) { return parseInt(text) || 0 }
            }
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Swirl burst:")
            QtControls2.CheckBox {
                enabled: page.effectConfig._showCanopy
                checked: page.effectConfig._swirlBurst
                onToggled: page.effectConfig._swirlBurst = checked
            }
            QtControls2.SpinBox {
                enabled: page.effectConfig._showCanopy && page.effectConfig._swirlBurst
                from: 0; to: 50; stepSize: 5
                value: page.effectConfig._swirlVaryMargin
                onValueModified: page.effectConfig._swirlVaryMargin = value
                textFromValue: function(value) { return "±" + value + "%" }
                valueFromText: function(text) { return parseInt(text) || 0 }
            }
            QtControls2.Label { text: i18n("every") }
            QtControls2.SpinBox {
                enabled: page.effectConfig._showCanopy && page.effectConfig._swirlBurst
                from: 1; to: 120; stepSize: 1
                value: page.effectConfig._swirlVaryInterval
                onValueModified: page.effectConfig._swirlVaryInterval = value
                textFromValue: function(value) { return value + " s" }
                valueFromText: function(text) { return parseInt(text) || 1 }
            }
            QtControls2.Label { text: i18n("prob.") }
            QtControls2.SpinBox {
                enabled: page.effectConfig._showCanopy && page.effectConfig._swirlBurst
                from: 0; to: 100; stepSize: 5
                value: page.effectConfig._swirlVaryChance
                onValueModified: page.effectConfig._swirlVaryChance = value
                textFromValue: function(value) { return value + "%" }
                valueFromText: function(text) { return parseInt(text) || 0 }
            }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Tunnel width:")
            from: 50; to: 250; stepSize: 10
            enabled: page.effectConfig._showCanopy
            value: page.effectConfig._tunnelWidth
            onValueModified: page.effectConfig._tunnelWidth = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 100 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Centre hole:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showCanopy
            value: page.effectConfig._holeRadius
            onValueModified: page.effectConfig._holeRadius = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Depth haze:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showCanopy
            value: page.effectConfig._fog
            onValueModified: page.effectConfig._fog = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showCanopy
            value: page.effectConfig._canopyOpacity
            onValueModified: page.effectConfig._canopyOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        // ── Glow spots ────────────────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.label: i18n("Glow spots"); Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            // Glow spots sit on the canopy leaves, so they need it to show.
            Kirigami.FormData.label: i18n("Visible:")
            enabled: page.effectConfig._showCanopy
            checked: page.effectConfig._showGlow
            onToggled: page.effectConfig._showGlow = checked
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Amount:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showCanopy && page.effectConfig._showGlow
            value: page.effectConfig._glow
            onValueModified: page.effectConfig._glow = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        // ── Centre glow (vortex) ──────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.label: i18n("Centre glow (vortex)"); Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Visible:")
            checked: page.effectConfig._showVortex
            onToggled: page.effectConfig._showVortex = checked
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Brightness:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showVortex
            value: page.effectConfig._mist
            onValueModified: page.effectConfig._mist = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Vortex swirl:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showVortex
            value: page.effectConfig._vortexSwirl
            onValueModified: page.effectConfig._vortexSwirl = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showVortex
            value: page.effectConfig._vortexOpacity
            onValueModified: page.effectConfig._vortexOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        // ── Stars (points) ────────────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.label: i18n("Stars (points)"); Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Visible:")
            checked: page.effectConfig._showStars
            onToggled: page.effectConfig._showStars = checked
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Count:")
            from: 0; to: 128; stepSize: 4
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starCount
            onValueModified: page.effectConfig._starCount = value
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Speed:")
            from: 0; to: 300; stepSize: 10
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starSpeed
            onValueModified: page.effectConfig._starSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Length:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starLength
            onValueModified: page.effectConfig._starLength = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showStars
            value: page.effectConfig._starOpacity
            onValueModified: page.effectConfig._starOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        // ── Beams (hyperspace) ────────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.label: i18n("Beams (hyperspace)"); Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Visible:")
            checked: page.effectConfig._showBeams
            onToggled: page.effectConfig._showBeams = checked
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Count:")
            from: 4; to: 800; stepSize: 10
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamCount
            onValueModified: page.effectConfig._beamCount = value
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Speed:")
            from: 0; to: 300; stepSize: 10
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamSpeed
            onValueModified: page.effectConfig._beamSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Length:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamLength
            onValueModified: page.effectConfig._beamLength = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showBeams
            value: page.effectConfig._beamOpacity
            onValueModified: page.effectConfig._beamOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        // ── Dots (twinkling stars) ────────────────────────────────────
        Kirigami.Separator { Kirigami.FormData.label: i18n("Dots (twinkling stars)"); Kirigami.FormData.isSection: true }

        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Visible:")
            checked: page.effectConfig._showDots
            onToggled: page.effectConfig._showDots = checked
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Count:")
            from: 0; to: 128; stepSize: 4
            enabled: page.effectConfig._showDots
            value: page.effectConfig._dotCount
            onValueModified: page.effectConfig._dotCount = value
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Speed:")
            from: 0; to: 300; stepSize: 10
            enabled: page.effectConfig._showDots
            value: page.effectConfig._dotSpeed
            onValueModified: page.effectConfig._dotSpeed = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Opacity:")
            from: 0; to: 100; stepSize: 5
            enabled: page.effectConfig._showDots
            value: page.effectConfig._dotOpacity
            onValueModified: page.effectConfig._dotOpacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
    }
}
