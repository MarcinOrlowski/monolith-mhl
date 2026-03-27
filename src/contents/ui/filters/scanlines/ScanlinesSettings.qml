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
        Kirigami.FormData.label: i18n("Intensity:")
        QtControls2.SpinBox {
            from: 0; to: 100; stepSize: 5
            value: filterConfig._intensity
            onValueModified: filterConfig._intensity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 50 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Frequency:")
        QtControls2.SpinBox {
            from: 1; to: 100; stepSize: 1
            value: filterConfig._frequency
            onValueModified: filterConfig._frequency = value
            textFromValue: function(value) { return (value / 10).toFixed(1) + "x" }
            valueFromText: function(text) { return Math.round(parseFloat(text) * 10) || 10 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Thickness:")
        QtControls2.SpinBox {
            from: 1; to: 100; stepSize: 1
            value: filterConfig._thickness
            onValueModified: filterConfig._thickness = value
            textFromValue: function(value) { return (value / 10).toFixed(1) + "x" }
            valueFromText: function(text) { return Math.round(parseFloat(text) * 10) || 10 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Scroll speed:")
        QtControls2.SpinBox {
            from: -100; to: 100; stepSize: 1
            value: filterConfig._speed
            onValueModified: filterConfig._speed = value
            textFromValue: function(value) {
                if (value === 0) { return i18n("static") }
                return (value / 10).toFixed(1) + "x"
            }
            valueFromText: function(text) { return Math.round(parseFloat(text) * 10) || 0 }
        }
    }
    RowLayout {
        Kirigami.FormData.label: i18n("Line color:")
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
    RowLayout {
        Kirigami.FormData.label: i18n("Line opacity:")
        QtControls2.SpinBox {
            from: 0; to: 100; stepSize: 5
            value: filterConfig._opacity
            onValueModified: filterConfig._opacity = value
            textFromValue: function(value) { return value + "%" }
            valueFromText: function(text) { return parseInt(text) || 0 }
        }
    }

    ColorDialog {
        id: colorDialog
        title: i18n("Scanline Color")
        selectedColor: filterConfig._color
        onAccepted: filterConfig._color = selectedColor
    }
}
