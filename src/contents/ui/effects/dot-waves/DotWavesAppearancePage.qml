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
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: page
    title: i18n("Appearance")

    required property var effectConfig

    Kirigami.FormLayout {
        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Dot spacing:")
            from: 8; to: 80; stepSize: 1
            value: page.effectConfig._spacing
            onValueModified: page.effectConfig._spacing = value
            textFromValue: function(value) { return value + " px" }
            valueFromText: function(text) { return parseInt(text) || page.effectConfig._spacing }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Dot size:")
            from: 5; to: 60; stepSize: 1
            value: page.effectConfig._dotRadius
            onValueModified: page.effectConfig._dotRadius = value
            textFromValue: function(value) { return (value / 10.0).toFixed(1) + " px" }
            valueFromText: function(text) { return Math.round((parseFloat(text) || 1.4) * 10) }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Density:")
            from: 0; to: 100; stepSize: 5
            value: page.effectConfig._density
            onValueModified: page.effectConfig._density = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Edge softness:")
            from: 1; to: 50; stepSize: 1
            value: page.effectConfig._contrast
            onValueModified: page.effectConfig._contrast = value
            textFromValue: function(value) { return (value / 10.0).toFixed(1) }
            valueFromText: function(text) { return Math.round((parseFloat(text) || 1.8) * 10) }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Brightness:")
            from: 1; to: 100; stepSize: 5
            value: page.effectConfig._maxAlpha
            onValueModified: page.effectConfig._maxAlpha = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 1 }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Dot color:")
            Rectangle {
                width: 24; height: 24; radius: 4
                color: page.effectConfig._dotColor
                border.color: "#888"; border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dotColorDialog.open()
                }
            }
            QtControls2.TextField {
                text: page.effectConfig._dotColor
                implicitWidth: 100
                onEditingFinished: {
                    if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
                        page.effectConfig._dotColor = text
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Background color:")
            Rectangle {
                width: 24; height: 24; radius: 4
                color: page.effectConfig._bgColor
                border.color: "#888"; border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bgColorDialog.open()
                }
            }
            QtControls2.TextField {
                text: page.effectConfig._bgColor
                implicitWidth: 100
                onEditingFinished: {
                    if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
                        page.effectConfig._bgColor = text
                    }
                }
            }
        }
    }

    ColorDialog {
        id: dotColorDialog
        title: i18n("Dot Color")
        selectedColor: page.effectConfig._dotColor
        onAccepted: page.effectConfig._dotColor = selectedColor
    }

    ColorDialog {
        id: bgColorDialog
        title: i18n("Background Color")
        selectedColor: page.effectConfig._bgColor
        onAccepted: page.effectConfig._bgColor = selectedColor
    }
}
