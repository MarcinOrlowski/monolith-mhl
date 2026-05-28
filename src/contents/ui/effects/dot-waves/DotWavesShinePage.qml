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
    title: i18n("Shine")

    required property var effectConfig

    Kirigami.FormLayout {
        QtControls2.CheckBox {
            Kirigami.FormData.label: i18n("Enabled:")
            checked: page.effectConfig._shineEnabled
            onToggled: page.effectConfig._shineEnabled = checked
        }

        QtControls2.ComboBox {
            Kirigami.FormData.label: i18n("Spatial form:")
            enabled: page.effectConfig._shineEnabled
            model: [i18n("Wave field"), i18n("Moving spotlight")]
            currentIndex: page.effectConfig._shineMode
            onActivated: page.effectConfig._shineMode = currentIndex
        }

        QtControls2.ComboBox {
            Kirigami.FormData.label: i18n("Modulation:")
            enabled: page.effectConfig._shineEnabled
            model: [i18n("Color push"), i18n("Alpha boost"), i18n("Both")]
            currentIndex: page.effectConfig._shineChannel
            onActivated: page.effectConfig._shineChannel = currentIndex
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Intensity:")
            enabled: page.effectConfig._shineEnabled
            from: 0; to: 100; stepSize: 5
            value: page.effectConfig._shineIntensity
            onValueModified: page.effectConfig._shineIntensity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        QtControls2.SpinBox {
            Kirigami.FormData.label: i18n("Width:")
            enabled: page.effectConfig._shineEnabled
            from: 5; to: 100; stepSize: 5
            value: page.effectConfig._shineWidth
            onValueModified: page.effectConfig._shineWidth = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 5 }
        }

        QtControls2.ComboBox {
            Kirigami.FormData.label: i18n("Speed:")
            enabled: page.effectConfig._shineEnabled
            model: ["0.25", "0.5", "0.75", "Normal", "1.25", "1.50", "1.75"]
            currentIndex: page.effectConfig._shineSpeedIndex
            onActivated: page.effectConfig._shineSpeedIndex = currentIndex
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Shine color:")
            enabled: page.effectConfig._shineEnabled
            Rectangle {
                width: 24; height: 24; radius: 4
                color: page.effectConfig._shineColor
                border.color: "#888"; border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shineColorDialog.open()
                }
            }
            QtControls2.TextField {
                text: page.effectConfig._shineColor
                implicitWidth: 100
                onEditingFinished: {
                    if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
                        page.effectConfig._shineColor = text
                    }
                }
            }
        }
    }

    ColorDialog {
        id: shineColorDialog
        title: i18n("Shine Color")
        selectedColor: page.effectConfig._shineColor
        onAccepted: page.effectConfig._shineColor = selectedColor
    }
}
