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
import QtQuick.Window
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates as Delegates
import "EffectSettings.js" as EffectSettings
import "filters/FilterRegistry.js" as FilterRegistry

ColumnLayout {
    id: root

    // --- Hub-level config ---
    property string cfg_ActiveEffect

    // --- Per-effect settings (JSON blobs, one cfg_ property per effect) ---
    property string cfg_EffectRainbowWavesSettings
    property string cfg_EffectLavaLampSettings

    // --- Per-filter settings (JSON blobs, one cfg_ property per filter) ---
    property string cfg_FilterPixelateSettings
    property string cfg_FilterScanlinesSettings
    property string cfg_FilterChromaticSettings
    property string cfg_FilterColorGradingSettings
    property string cfg_FilterHueShiftSettings
    property string cfg_FilterRgbOffsetSettings
    property string cfg_FilterCrtSettings
    property string cfg_FilterBlurSettings
    property string cfg_FilterMaskSettings
    property string cfg_FilterOrder

    // --- Filter config components (self-contained, loaded from FilterRegistry) ---
    property var filterConfigs: ({})

    // Build cfgKey → filterId mapping for blob change propagation
    readonly property var _cfgKeyToFilterId: {
        var m = {}
        for (var i = 0; i < FilterRegistry.filters.length; i++) {
            var f = FilterRegistry.filters[i]
            m["cfg_" + f.cfgKey] = f.id
        }
        return m
    }

    Repeater {
        model: FilterRegistry.filters.length
        Item {
            visible: false
            property var entry: FilterRegistry.filters[index]
            Loader {
                id: fcLoader
                asynchronous: false
                source: Qt.resolvedUrl("filters/" + entry.configUrl)
                onLoaded: {
                    // Bind blob: hub → filter config
                    item.settingsBlob = Qt.binding(function() { return root["cfg_" + entry.cfgKey] || "{}" })
                    // Register in map
                    var m = root.filterConfigs
                    m[entry.id] = item
                    root.filterConfigs = m
                }
            }
            // Propagate blob changes: filter config → hub cfg_ property
            Connections {
                target: fcLoader.item
                enabled: fcLoader.item !== null
                function onSettingsBlobChanged() { root["cfg_" + entry.cfgKey] = fcLoader.item.settingsBlob }
            }
        }
    }

    function filterConfig(fid) { return filterConfigs[fid] || null }
    function filterName(fid) { var fc = filterConfig(fid); return fc ? fc.filterName : "?" }
    function isFilterEnabled(fid) { var fc = filterConfig(fid); return fc ? fc.show : false }
    function toggleFilter(fid) { var fc = filterConfig(fid); if (fc) fc.toggle() }
    function resetFilter(fid) { var fc = filterConfig(fid); if (fc) fc.reset() }

    // Effect registry: id, name, configUrl
    readonly property var effectRegistry: [
        { effectId: "rainbow-waves", name: "Rainbow Waves", configUrl: Qt.resolvedUrl("effects/rainbow-waves/RainbowWavesConfig.qml") },
        { effectId: "lava-lamp", name: "Lava Lamp", configUrl: Qt.resolvedUrl("effects/lava-lamp/LavaLampConfig.qml") }
    ]

    function findEffectIndex(effectId) {
        for (var i = 0; i < effectRegistry.length; i++) {
            if (effectRegistry[i].effectId === effectId) { return i }
        }
        return 0
    }

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 15
        Layout.topMargin: 10
        Layout.rightMargin: 15

        Image {
            source: "logo.webp"
            sourceSize.width: 48
            sourceSize.height: 48
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.rightMargin: 6
        }

        ColumnLayout {
            Layout.fillWidth: true
            QtControls2.Label {
                text: i18n("Monolith MHL v1.1.0")
                font.bold: true
            }
            QtControls2.Label {
                text: i18n("©2026 Marcin Orlowski")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                opacity: 0.7
            }
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.bottomMargin: 10

            QtControls2.Button {
                icon.name: "globe"
                onClicked: Qt.openUrlExternally("https://github.com/MarcinOrlowski/monolith-mhl")
            }
            QtControls2.Button {
                icon.name: "tools-report-bug"
                onClicked: Qt.openUrlExternally("https://github.com/MarcinOrlowski/monolith-mhl/issues")
            }
            QtControls2.Button {
                text: i18n("More…")
                onClicked: Qt.openUrlExternally("https://store.kde.org/u/marcinorlowski")
            }
        }
    } // RowLayout

    Kirigami.Separator {
        Layout.fillWidth: true
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 15
        Layout.rightMargin: 15
        Layout.topMargin: 10

        QtControls2.Label {
            text: i18n("Effect:")
        }

        QtControls2.Button {
            icon.name: "go-previous"
            enabled: effectCombo.currentIndex > 0
            onClicked: effectCombo.currentIndex = effectCombo.currentIndex - 1
        }

        QtControls2.ComboBox {
            id: effectCombo
            Layout.fillWidth: true
            model: {
                var items = [];
                for (var i = 0; i < root.effectRegistry.length; i++) {
                    items.push(root.effectRegistry[i].name)
                }
                return items
            }
            currentIndex: root.findEffectIndex(cfg_ActiveEffect)
            onCurrentIndexChanged: {
                if (currentIndex >= 0 && currentIndex < root.effectRegistry.length) {
                    cfg_ActiveEffect = root.effectRegistry[currentIndex].effectId
                }
            }
        }

        QtControls2.Button {
            icon.name: "go-next"
            enabled: effectCombo.currentIndex < effectCombo.count - 1
            onClicked: effectCombo.currentIndex = effectCombo.currentIndex + 1
        }

        QtControls2.Button {
            icon.name: "configure"
            onClicked: effectSettingsWindow.showSettings()
            QtControls2.ToolTip.text: i18n("Effect Settings")
            QtControls2.ToolTip.visible: hovered
        }
    }  // RowLayout

    // --- Effect settings window ---
    Kirigami.ApplicationWindow {
        id: effectSettingsWindow
        visible: false
        property var _snapshot: ({})
        property bool _accepted: false

        title: root.effectRegistry[root.findEffectIndex(cfg_ActiveEffect)].name + " " + i18n("Settings")
        flags: Qt.Dialog
        modality: Qt.WindowModal
        transientParent: root.Window.window
        width: Kirigami.Units.gridUnit * 50
        height: Kirigami.Units.gridUnit * 30
        minimumWidth: Kirigami.Units.gridUnit * 40
        minimumHeight: Kirigami.Units.gridUnit * 20

        property var pageCache: Object.create(null)

        function showSettings() {
            _snapshot = {
                "cfg_EffectRainbowWavesSettings": root.cfg_EffectRainbowWavesSettings,
                "cfg_EffectLavaLampSettings": root.cfg_EffectLavaLampSettings
            }
            _accepted = false
            visible = true
        }

        function accept() {
            _accepted = true
            visible = false
        }

        function _restoreSnapshot() {
            var keys = Object.keys(_snapshot)
            for (var i = 0; i < keys.length; i++) {
                root[keys[i]] = _snapshot[keys[i]]
            }
        }

        function cancel() {
            _restoreSnapshot()
            visible = false
        }

        onClosing: function(close) {
            if (!_accepted) {
                _restoreSnapshot()
            }
        }

        // Data model (non-visual) loaded from the effect's config component
        Loader {
            id: effectConfigLoader
            visible: false
            source: root.effectRegistry[root.findEffectIndex(cfg_ActiveEffect)].configUrl

            onLoaded: {
                if ("cfg_EffectRainbowWavesSettings" in item) {
                    item.cfg_EffectRainbowWavesSettings = Qt.binding(function() { return root.cfg_EffectRainbowWavesSettings })
                }
                if ("cfg_EffectLavaLampSettings" in item) {
                    item.cfg_EffectLavaLampSettings = Qt.binding(function() { return root.cfg_EffectLavaLampSettings })
                }
                try { item.hubConfiguration = wallpaper.configuration } catch(e) {}
                effectSettingsWindow.pageCache = Object.create(null)
                if (effectSettingsWindow.visible) {
                    effectSettingsWindow.loadInitialPage()
                }
            }
        }

        function loadInitialPage() {
            if (!effectConfigLoader.item) return
            var pages = effectConfigLoader.item.pages
            if (pages && pages.length > 0) {
                navigateToPage(0)
                sidebarList.currentIndex = 0
            }
        }

        function navigateToPage(index) {
            if (!effectConfigLoader.item) return
            var pages = effectConfigLoader.item.pages
            if (index < 0 || index >= pages.length) return
            var moduleDef = pages[index]
            var page = pageForModule(moduleDef)
            if (page) {
                if (pageStack.depth > 0) {
                    pageStack.replace(page)
                } else {
                    pageStack.push(page)
                }
            }
        }

        function pageForModule(moduleDef) {
            if (pageCache[moduleDef.moduleId]) {
                return pageCache[moduleDef.moduleId]
            }
            var configDir = root.effectRegistry[root.findEffectIndex(cfg_ActiveEffect)].configUrl
            var baseDir = configDir.toString().replace(/\/[^/]*$/, "/")
            var component = Qt.createComponent(baseDir + moduleDef.page)
            if (component.status === Component.Error) {
                console.error("Failed to create page:", component.errorString())
                return null
            }
            var page = component.createObject(effectSettingsWindow, {
                effectConfig: effectConfigLoader.item
            })
            pageCache[moduleDef.moduleId] = page
            return page
        }

        onVisibleChanged: {
            if (visible && pageStack.depth === 0) {
                loadInitialPage()
            }
        }

        pageStack {
            columnView.columnWidth: Kirigami.Units.gridUnit * 13
            globalToolBar {
                style: Kirigami.ApplicationHeaderStyle.ToolBar
                showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
            }
        }

        globalDrawer: Kirigami.OverlayDrawer {
            id: drawer
            edge: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge
            modal: false
            Kirigami.OverlayZStacking.layer: Kirigami.OverlayZStacking.Drawer
            z: Kirigami.OverlayZStacking.z
            drawerOpen: true
            width: Kirigami.Units.gridUnit * 13
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false

            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0

            contentItem: ColumnLayout {
                spacing: 0

                QtControls2.ToolBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: effectSettingsWindow.pageStack.globalToolBar.preferredHeight

                    leftPadding: 3
                    rightPadding: 3
                    topPadding: 3
                    bottomPadding: 3

                    contentItem: Item {}
                }

                QtControls2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: sidebarList
                        currentIndex: 0

                        model: effectConfigLoader.item ? effectConfigLoader.item.pages : []

                        delegate: Delegates.RoundedItemDelegate {
                            id: sidebarDelegate
                            required property int index
                            required property var modelData
                            width: sidebarList.width
                            text: modelData.text
                            icon.name: modelData.icon
                            checked: ListView.view.currentIndex === index
                            onClicked: {
                                if (ListView.view.currentIndex === index) {
                                    return
                                }
                                ListView.view.currentIndex = index
                                effectSettingsWindow.navigateToPage(index)
                            }
                        }
                    }
                }
            }
        }

        footer: QtControls2.ToolBar {
            contentItem: RowLayout {
                Item { Layout.fillWidth: true }
                QtControls2.Button {
                    text: i18n("Ok")
                    highlighted: true
                    onClicked: effectSettingsWindow.accept()
                }
                QtControls2.Button {
                    text: i18n("Cancel")
                    onClicked: effectSettingsWindow.cancel()
                }
            }
        }

        contentItem.Keys.onEscapePressed: effectSettingsWindow.cancel()
    } // ApplicationWindow

    // --- Filter processing order ---
    Kirigami.FormLayout {
        twinFormLayouts: parentLayout
        Layout.fillWidth: true

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Post Processin Filters")
         }

        QtControls2.Label {
            Layout.fillWidth: true
            Kirigami.FormData.isSection: true
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Enabled filters are executed in top-to-bottom order.")
            wrapMode: Text.WordWrap
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            opacity: 0.7
        }
    }

    ColumnLayout {
        id: filterOrderContainer
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        spacing: 0

            ListModel {
                id: filterOrderModel
            }

            Component.onCompleted: {
                var ids = (root.cfg_FilterOrder || "pixelate,scanlines,chromatic,color-grading,hue-shift,rgb-offset,crt,blur,mask").split(",")
                var seen = {}
                // Load saved order, skipping unknown or duplicate IDs
                for (var i = 0; i < ids.length; i++) {
                    var fid = ids[i].trim()
                    if (root.filterConfig(fid) && !seen[fid]) {
                        filterOrderModel.append({ filterId: fid })
                        seen[fid] = true
                    }
                }
                // Append any new filters not present in saved order
                var allIds = FilterRegistry.filters.map(function(f) { return f.id })
                for (var j = 0; j < allIds.length; j++) {
                    if (!seen[allIds[j]]) {
                        filterOrderModel.append({ filterId: allIds[j] })
                    }
                }
            }

            function syncOrderToConfig() {
                var ids = []
                for (var i = 0; i < filterOrderModel.count; i++) {
                    ids.push(filterOrderModel.get(i).filterId)
                }
                root.cfg_FilterOrder = ids.join(",")
            }

            Repeater {
                model: filterOrderModel

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QtControls2.Button {
                        icon.name: root.isFilterEnabled(filterId) ? "visibility" : "hint"
                        flat: true
                        implicitWidth: Kirigami.Units.gridUnit * 2
                        implicitHeight: Kirigami.Units.gridUnit * 2
                        opacity: root.isFilterEnabled(filterId) ? 1.0 : 0.4
                        onClicked: root.toggleFilter(filterId)
                    }
                    QtControls2.Label {
                        text: root.filterName(filterId)
                        Layout.fillWidth: true
                        opacity: root.isFilterEnabled(filterId) ? 1.0 : 0.5
                    }
                    QtControls2.Button {
                        icon.name: "configure"
                        flat: true
                        implicitWidth: Kirigami.Units.gridUnit * 2
                        implicitHeight: Kirigami.Units.gridUnit * 2
                        onClicked: filterSettingsDialog.showFilter(filterId)
                        QtControls2.ToolTip.text: i18n("Settings")
                        QtControls2.ToolTip.visible: hovered
                    }
                    QtControls2.Button {
                        icon.name: "go-up"
                        enabled: index > 0
                        flat: true
                        implicitWidth: Kirigami.Units.gridUnit * 2
                        implicitHeight: Kirigami.Units.gridUnit * 2
                        onClicked: {
                            filterOrderModel.move(index, index - 1, 1)
                            filterOrderContainer.syncOrderToConfig()
                        }
                    }
                    QtControls2.Button {
                        icon.name: "go-down"
                        enabled: index < filterOrderModel.count - 1
                        flat: true
                        implicitWidth: Kirigami.Units.gridUnit * 2
                        implicitHeight: Kirigami.Units.gridUnit * 2
                        onClicked: {
                            filterOrderModel.move(index, index + 1, 1)
                            filterOrderContainer.syncOrderToConfig()
                        }
                    }
                }
            }
        }

    // --- Filter settings window ---
    QtControls2.ApplicationWindow {
        id: filterSettingsDialog
        property string activeFilterId: ""
        property string _snapshot: ""
        property bool _accepted: false

        title: root.filterName(activeFilterId)
        flags: Qt.Dialog
        modality: Qt.WindowModal
        transientParent: root.Window.window

        width: contentLayout.implicitWidth + Kirigami.Units.largeSpacing * 2
        height: contentLayout.implicitHeight + Kirigami.Units.largeSpacing * 2

        function showFilter(fid) {
            activeFilterId = fid
            var fc = root.filterConfig(fid)
            _snapshot = fc ? fc.settingsBlob : "{}"
            _accepted = false
            visible = true
        }

        function accept() {
            _accepted = true
            visible = false
        }

        function cancel() {
            var fc = root.filterConfig(activeFilterId)
            if (fc) fc.settingsBlob = _snapshot
            visible = false
        }

        onClosing: function(close) {
            if (!_accepted) {
                var fc = root.filterConfig(activeFilterId)
                if (fc) fc.settingsBlob = _snapshot
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            Loader {
                id: filterSettingsLoader
                Layout.fillWidth: true
                source: {
                    var fc = root.filterConfig(filterSettingsDialog.activeFilterId)
                    return fc ? fc.settingsUrl : ""
                }
                onLoaded: {
                    item.filterConfig = root.filterConfig(filterSettingsDialog.activeFilterId)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                QtControls2.Button {
                    text: i18n("Reset to Defaults")
                    icon.name: "edit-reset"
                    onClicked: root.resetFilter(filterSettingsDialog.activeFilterId)
                }
                Item { Layout.fillWidth: true }
                QtControls2.Button {
                    text: i18n("Ok")
                    highlighted: true
                    onClicked: filterSettingsDialog.accept()
                }
                QtControls2.Button {
                    text: i18n("Cancel")
                    onClicked: filterSettingsDialog.cancel()
                }
            }
        }
    }

    // Propagate changes from effect config back to hub cfg_ properties
    Connections {
        target: effectConfigLoader.item
        enabled: effectConfigLoader.item !== null
        function onCfg_EffectRainbowWavesSettingsChanged() { root.cfg_EffectRainbowWavesSettings = effectConfigLoader.item.cfg_EffectRainbowWavesSettings }
        function onCfg_EffectLavaLampSettingsChanged() { root.cfg_EffectLavaLampSettings = effectConfigLoader.item.cfg_EffectLavaLampSettings }
    }

}
