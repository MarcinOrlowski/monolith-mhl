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

Kirigami.FormLayout {
    property var filterConfig

    RowLayout {
        Kirigami.FormData.label: i18n("Side:")
        QtControls2.SpinBox {
            from: 2; to: 500; stepSize: 1
            value: filterConfig._side
            onValueModified: filterConfig._side = value
            textFromValue: function(value) { return value + " px" }
            valueFromText: function(text) { return parseInt(text) || 32 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Gap:")
        QtControls2.SpinBox {
            from: 0; to: 500; stepSize: 1
            value: filterConfig._gap
            onValueModified: filterConfig._gap = value
            textFromValue: function(value) { return value + " px" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Invert:")
        QtControls2.CheckBox {
            text: i18n("Cut outside the square")
            checked: filterConfig._invert
            onToggled: filterConfig._invert = checked
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Mask color:")
        Rectangle {
            width: 24; height: 24; radius: 4
            color: filterConfig._color
            border.color: "#888"; border.width: 1
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: colorDialog.open()
            }
        }
        QtControls2.TextField {
            text: filterConfig._color
            implicitWidth: 100
            onEditingFinished: {
                if (/^#[0-9A-Fa-f]{6}$/.test(text)) {
                    filterConfig._color = text
                }
            }
        }
    }

    ColorDialog {
        id: colorDialog
        title: i18n("Mask Color")
        selectedColor: filterConfig._color
        onAccepted: filterConfig._color = selectedColor
    }
}
