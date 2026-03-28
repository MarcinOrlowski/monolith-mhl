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
import Qt.labs.folderlistmodel
import Qt.labs.platform as Platform
import "ThemeLoader.js" as ThemeLoader

Item {
    id: scanner
    visible: false
    width: 0
    height: 0

    readonly property url builtinPath: Qt.resolvedUrl("themes")
    readonly property url userPath: Platform.StandardPaths.writableLocation(Platform.StandardPaths.ConfigLocation) + "/monolith/lava-lamp/themes.d"

    property ListModel themeList: ListModel {}
    property bool ready: false

    function modelsFinished() {
        return builtinModel.status !== FolderListModel.Loading
            && userModel.status !== FolderListModel.Loading;
    }

    Timer {
        id: rebuildTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (scanner.modelsFinished()) {
                scanner.rebuild();
            } else {
                rebuildTimer.restart();
            }
        }
    }

    Component.onCompleted: rebuildTimer.restart()

    FolderListModel {
        id: builtinModel
        folder: scanner.builtinPath
        nameFilters: ["*.qml"]
        showDirs: false
        sortField: FolderListModel.Name
        onCountChanged: rebuildTimer.restart()
    }

    FolderListModel {
        id: userModel
        folder: scanner.userPath
        nameFilters: ["*.qml"]
        showDirs: false
        sortField: FolderListModel.Name
        onCountChanged: rebuildTimer.restart()
    }

    // Load a theme QML file, validate it, return theme object or null
    function loadThemeFile(fileUrl) {
        var component = Qt.createComponent(fileUrl);
        if (component.status !== Component.Ready) {
            console.warn("Lava Lamp: failed to load theme " + fileUrl
                + ": " + component.errorString());
            return null;
        }
        var obj = component.createObject(null);
        if (!obj) {
            console.warn("Lava Lamp: failed to instantiate theme " + fileUrl);
            return null;
        }
        var error = ThemeLoader.validateTheme(obj);
        if (error) {
            console.warn("Lava Lamp: invalid theme " + fileUrl + ": " + error);
            obj.destroy();
            return null;
        }
        if (obj.enabled === false) {
            obj.destroy();
            return null;
        }
        return obj;
    }

    function rebuild() {
        ready = false;
        var map = {};
        var builtinIds = {};

        // Built-in themes first
        for (var i = 0; i < builtinModel.count; i++) {
            var bFile = builtinModel.get(i, "fileName");
            var bUrl = builtinModel.get(i, "fileUrl").toString();
            var bObj = loadThemeFile(bUrl);
            if (!bObj) continue;
            builtinIds[bObj.themeId] = true;
            map[bObj.themeId] = { themeId: bObj.themeId, displayName: bObj.name,
                                  fileUrl: bUrl, isUser: false };
            bObj.destroy();
        }

        // User themes — reject if ID clashes with a built-in theme
        for (var j = 0; j < userModel.count; j++) {
            var uFile = userModel.get(j, "fileName");
            var uUrl = userModel.get(j, "fileUrl").toString();
            var uObj = loadThemeFile(uUrl);
            if (!uObj) continue;
            if (builtinIds[uObj.themeId]) {
                console.warn("Lava Lamp: skipping user theme '" + uFile
                    + "' — id '" + uObj.themeId + "' conflicts with a built-in theme");
                uObj.destroy();
                continue;
            }
            if (map[uObj.themeId]) {
                console.warn("Lava Lamp: skipping duplicate user theme '" + uFile
                    + "' — id '" + uObj.themeId + "' already loaded");
                uObj.destroy();
                continue;
            }
            map[uObj.themeId] = { themeId: uObj.themeId, displayName: uObj.name,
                                  fileUrl: uUrl, isUser: true };
            uObj.destroy();
        }

        // Build sorted list
        var entries = [];
        var ids = Object.keys(map).sort();
        for (var k = 0; k < ids.length; k++)
            entries.push(map[ids[k]]);

        themeList.clear();
        for (var m = 0; m < entries.length; m++)
            themeList.append(entries[m]);

        ready = true;
    }

    function loadThemeById(themeId) {
        for (var i = 0; i < themeList.count; i++) {
            var entry = themeList.get(i);
            if (entry.themeId === themeId)
                return loadThemeFile(entry.fileUrl);
        }
        // Fallback: load first available theme
        if (themeList.count > 0)
            return loadThemeFile(themeList.get(0).fileUrl);
        return null;
    }
}
