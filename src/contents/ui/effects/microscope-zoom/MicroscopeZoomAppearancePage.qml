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
            Kirigami.FormData.label: i18n("Density:")
            from: 0; to: 100; stepSize: 5
            value: page.effectConfig._density
            onValueModified: page.effectConfig._density = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Cell color:")
            Rectangle {
                width: 24; height: 24; radius: 4
                color: page.effectConfig._leafColor
                border.color: "#888"; border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: leafColorDialog.open()
                }
            }
            QtControls2.TextField {
                text: page.effectConfig._leafColor
                implicitWidth: 100
                onEditingFinished: {
                    if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
                        page.effectConfig._leafColor = text
                    }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Medium color:")
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

        RowLayout {
            Kirigami.FormData.label: i18n("Illumination color:")
            Rectangle {
                width: 24; height: 24; radius: 4
                color: page.effectConfig._lightColor
                border.color: "#888"; border.width: 1
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: lightColorDialog.open()
                }
            }
            QtControls2.TextField {
                text: page.effectConfig._lightColor
                implicitWidth: 100
                onEditingFinished: {
                    if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
                        page.effectConfig._lightColor = text
                    }
                }
            }
        }
    }

    ColorDialog {
        id: leafColorDialog
        title: i18n("Cell Color")
        selectedColor: page.effectConfig._leafColor
        onAccepted: page.effectConfig._leafColor = selectedColor
    }

    ColorDialog {
        id: bgColorDialog
        title: i18n("Medium Color")
        selectedColor: page.effectConfig._bgColor
        onAccepted: page.effectConfig._bgColor = selectedColor
    }

    ColorDialog {
        id: lightColorDialog
        title: i18n("Illumination Color")
        selectedColor: page.effectConfig._lightColor
        onAccepted: page.effectConfig._lightColor = selectedColor
    }
}
