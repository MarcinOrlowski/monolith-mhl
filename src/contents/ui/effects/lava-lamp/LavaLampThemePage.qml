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
    title: i18n("Theme")

    required property var effectConfig

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n("Initial theme:")

            QtControls2.Button {
                icon.name: "go-previous"
                enabled: themeCombo.currentIndex > 0
                onClicked: {
                    var next = themeCombo.currentIndex - 1
                    if (next === themeCombo.separatorIndex) {
                        next--
                    }
                    themeCombo.currentIndex = next
                }
            }

            QtControls2.ComboBox {
                id: themeCombo
                Layout.fillWidth: true
                focus: true

                readonly property int randomThemeIndex: 0
                readonly property int separatorIndex: 1
                readonly property int themesOffset: 2

                model: {
                    var items = [i18n("Random"), "───────"];
                    for (var i = 0; i < page.effectConfig.themeScanner.themeList.count; i++) {
                        items.push(page.effectConfig.themeScanner.themeList.get(i).displayName)
                    }
                    return items
                }
                currentIndex: -1
                Component.onCompleted: currentIndex = Qt.binding(function() {
                    if (!page.effectConfig.themeScanner.ready || page.effectConfig.themeScanner.themeList.count === 0) {
                        return -1
                    }
                    if (page.effectConfig._randomInitialTheme) {
                        return randomThemeIndex
                    }
                    return page.effectConfig.findThemeIndex(page.effectConfig._themeId) + themesOffset;
                })
                onCurrentIndexChanged: {
                    if (currentIndex < 0 || currentIndex === separatorIndex || !page.effectConfig.themeScanner.ready) {
                        return
                    }
                    if (currentIndex === randomThemeIndex) {
                        page.effectConfig._randomInitialTheme = true
                    } else if (currentIndex >= themesOffset) {
                        page.effectConfig._randomInitialTheme = false
                        var themeIdx = currentIndex - themesOffset;
                        if (themeIdx >= 0 && themeIdx < page.effectConfig.themeScanner.themeList.count) {
                            page.effectConfig._themeId = page.effectConfig.themeScanner.themeList.get(themeIdx).themeId
                        }
                    }
                }

                delegate: QtControls2.ItemDelegate {
                    required property int index
                    required property var modelData
                    width: themeCombo.width
                    text: modelData
                    enabled: index !== themeCombo.separatorIndex
                    highlighted: themeCombo.highlightedIndex === index

                    background: Rectangle {
                        visible: index === themeCombo.separatorIndex
                        color: "transparent"
                    }
                }
            }

            QtControls2.Button {
                icon.name: "go-next"
                enabled: themeCombo.currentIndex < themeCombo.count - 1
                onClicked: {
                    var next = themeCombo.currentIndex + 1;
                    if (next === themeCombo.separatorIndex) {
                        next++
                    }
                    themeCombo.currentIndex = next;
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Auto-cycle themes:")
            QtControls2.CheckBox {
                checked: page.effectConfig._autoCycle
                onToggled: page.effectConfig._autoCycle = checked
            }
            QtControls2.SpinBox {
                id: cycleIntervalSpin
                enabled: page.effectConfig._autoCycle
                from: 1
                to: page.effectConfig._cycleIntervalUnit === 1 ? 60 : 300
                stepSize: page.effectConfig._cycleIntervalUnit === 1 ? 1 : 5
                value: page.effectConfig._cycleInterval
                onValueModified: page.effectConfig._cycleInterval = value
            }
            QtControls2.ComboBox {
                enabled: page.effectConfig._autoCycle
                model: [i18n("secs"), i18n("mins")]
                currentIndex: page.effectConfig._cycleIntervalUnit
                onActivated: function(index) {
                    page.effectConfig._cycleIntervalUnit = index;
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Cycle in random order:")
            QtControls2.CheckBox {
                enabled: page.effectConfig._autoCycle
                checked: page.effectConfig._cycleInRandomOrder
                onToggled: page.effectConfig._cycleInRandomOrder = checked
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Transition duration:")
            QtControls2.SpinBox {
                enabled: page.effectConfig._autoCycle
                from: 1
                to: 30
                stepSize: 1
                value: page.effectConfig._transitionDuration
                onValueModified: page.effectConfig._transitionDuration = value
                textFromValue: function(value) { return value + " " + i18n("secs") }
                valueFromText: function(text) { return parseInt(text) || page.effectConfig._transitionDuration }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Brightness:")
            QtControls2.CheckBox {
                checked: page.effectConfig._dimCap
                onToggled: page.effectConfig._dimCap = checked
            }
            QtControls2.SpinBox {
                enabled: page.effectConfig._dimCap
                from: 5
                to: 100
                stepSize: 5
                value: page.effectConfig._dimLevel
                onValueModified: page.effectConfig._dimLevel = value
                textFromValue: function(value) { return value + "%" }
                valueFromText: function(text) { return parseInt(text) || 100 }
            }
        }

    }
}
