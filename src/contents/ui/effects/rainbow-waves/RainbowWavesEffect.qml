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
import org.kde.plasma.core as PlasmaCore
import "ThemeLoader.js" as ThemeLoader
import "../../EffectSettings.js" as EffectSettings

Item {
    id: effectRoot
    anchors.fill: parent

    // --- Input from hub ---
    property var configuration: null

    // --- Schema (must match RainbowWavesConfig.qml) ---
    readonly property var _defaults: ({
        themeId: "rwm-sunset",
        randomInitialTheme: true,
        autoCycle: true,
        cycleInterval: 15,
        cycleIntervalUnit: 1,
        transitionDuration: 3,
        cycleInRandomOrder: true,
        showBackground: true,
        showStars: true,
        showGhosts: true,
        showWaves: true,
        showGlow: true,
        showHalo: true,
        showShine: true,
        showSpotlights: true,
        speedIndex: 2,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // --- Parsed settings (reactive properties for bindings) ---
    property real speedMult: 1.0
    property real dimLevel: 1.0
    property bool fpsCap: true
    property int fpsLimit: 30
    property bool paused: false

    function togglePause() { paused = !paused }

    function _readSettings() {
        var json = configuration ? configuration.EffectRainbowWavesSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _writeSettings(patch) {
        var s = _readSettings();
        for (var key in patch) {
            s[key] = patch[key];
        }
        configuration.EffectRainbowWavesSettings = EffectSettings.save(s);
    }

    function _applySettings() {
        var s = _readSettings();

        // Speed
        speedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.speedIndex] ?? 1.0;

        // Theme ID — detect changes
        var newThemeId = s.themeId;
        if (newThemeId !== currentThemeId) {
            currentThemeId = newThemeId;
        }

        // Cycle settings
        autoCycleEnabled = s.autoCycle;
        transitionMs = s.transitionDuration * 1000;
        cycleInRandomOrder = s.cycleInRandomOrder;
        _cycleInterval = s.cycleInterval;
        _cycleIntervalUnit = s.cycleIntervalUnit;

        // FPS / brightness
        fpsCap = s.fpsCap;
        fpsLimit = s.fpsLimit;
        dimLevel = s.dimCap ? s.dimLevel / 100.0 : 1.0;

        // Layer visibility
        for (var i = 0; i < layerKeys.length; i++) {
            var key = layerKeys[i];
            var val = s[key];
            if (val === undefined) val = true;
            effect[key] = val ? 1.0 : 0.0;
        }
    }

    // --- Outputs for hub ---
    readonly property bool hasError: effect.status === ShaderEffect.Error
    readonly property string errorLog: effect.log || ""
    readonly property string effectName: "Rainbow Waves"
    readonly property url configUrl: Qt.resolvedUrl("RainbowWavesConfig.qml")

    readonly property list<PlasmaCore.Action> effectActions: [
        PlasmaCore.Action {
            text: i18n("Next Wallpaper Theme")
            icon.name: "media-skip-forward"
            enabled: themeScanner.ready && themeScanner.themeList.count > 1
            onTriggered: effectRoot.cycleInRandomOrder ? effectRoot.cycleToRandomTheme() : effectRoot.cycleToNextTheme()
        },
        PlasmaCore.Action {
            text: i18n("Previous Wallpaper Theme")
            icon.name: "media-skip-backward"
            enabled: themeScanner.ready && themeScanner.themeList.count > 1
                     && (!effectRoot.cycleInRandomOrder || (effectRoot.shuffledOrder.length > 0 && effectRoot.shufflePos > 0))
            onTriggered: effectRoot.cycleInRandomOrder ? effectRoot.cycleToPreviousRandomTheme() : effectRoot.cycleToPreviousTheme()
        },
        PlasmaCore.Action {
            text: i18n("Set Current Theme")
            icon.name: "bookmark-new"
            enabled: themeScanner.ready && themeScanner.themeList.count > 1
                     && effectRoot.initialized && effectRoot.displayedThemeId.length > 0
            onTriggered: effectRoot.setCurrentTheme()
        }
    ]

    // --- Theme scanner ---
    ThemeScanner {
        id: themeScanner
        onReadyChanged: {
            effectRoot.resetCycleState();
            if (ready && !effectRoot.initialized) {
                effectRoot.loadInitialTheme();
            }
        }
    }

    // --- Theme state ---
    property bool initialized: false
    property string displayedThemeId: ""
    property string currentThemeId: ""
    onCurrentThemeIdChanged: {
        if (!initialized) {
            return;
        }
        loadCurrentTheme();
        resetCycleState();
    }

    property int cycleIndex: -1
    property int shufflePos: -1
    property var shuffledOrder: []
    property bool autoCycleEnabled: false
    onAutoCycleEnabledChanged: {
        if (!initialized) {
            return;
        }
        if (!autoCycleEnabled) {
            resetCycleState();
            if (displayedThemeId !== currentThemeId) {
                loadCurrentTheme();
            }
        }
    }
    property int transitionMs: 3000
    property bool cycleInRandomOrder: false
    onCycleInRandomOrderChanged: resetCycleState()
    property int _cycleInterval: 15
    property int _cycleIntervalUnit: 1

    // --- Layer visibility ---
    property var layerKeys: [
        "showBackground", "showStars", "showGhosts", "showWaves",
        "showGlow", "showHalo", "showShine", "showSpotlights"
    ]

    function applyLayerVisibility(theme) {
        var patch = {};
        for (var i = 0; i < layerKeys.length; i++) {
            var key = layerKeys[i];
            var rawVal = theme[key];
            var value = (rawVal === undefined) ? true : Boolean(rawVal);
            patch[key] = value;
            effect[key] = value ? 1.0 : 0.0;
        }
        _writeSettings(patch);
    }

    // React to any config change (JSON blob or hub-level)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectRainbowWavesSettings") {
                effectRoot._applySettings();
            }
        }
    }

    // --- Theme functions ---
    function setCurrentTheme() {
        if (!displayedThemeId) {
            return;
        }
        _writeSettings({
            themeId: displayedThemeId,
            randomInitialTheme: false,
            autoCycle: false
        });
        effectRoot.configuration.writeConfig();
    }

    function resetCycleState() {
        cycleIndex = -1;
        shufflePos = -1;
        shuffledOrder = [];
    }

    function pickRandomThemeId() {
        var count = themeScanner.themeList.count;
        if (count === 0) {
            return currentThemeId;
        }
        var idx = Math.floor(Math.random() * count);
        return themeScanner.themeList.get(idx).themeId;
    }

    function getInitialThemeId() {
        var s = _readSettings();
        if (s.randomInitialTheme && themeScanner.themeList.count > 0) {
            return pickRandomThemeId();
        }
        return s.themeId;
    }

    function loadInitialTheme() {
        if (!themeScanner.ready) {
            return;
        }
        _applySettings();
        var themeId = getInitialThemeId();
        var theme = themeScanner.loadThemeById(themeId);
        if (theme) {
            ThemeLoader.applyTheme(theme, effect);
            applyLayerVisibility(theme);
            displayedThemeId = theme.themeId;
            theme.destroy();
        }
        initialized = true;
    }

    function loadCurrentTheme() {
        console.warn("Rainbow Waves [effect]: loadCurrentTheme() id=" + currentThemeId);
        if (!themeScanner.ready) {
            return;
        }
        var theme = themeScanner.loadThemeById(currentThemeId);
        if (theme) {
            ThemeLoader.applyTheme(theme, effect);
            applyLayerVisibility(theme);
            displayedThemeId = theme.themeId;
            theme.destroy();
        }
    }

    function cycleToTheme(themeIndex) {
        if (!themeScanner.ready) {
            return;
        }

        var entry = themeScanner.themeList.get(themeIndex);
        var theme = themeScanner.loadThemeFile(entry.fileUrl);
        if (theme) {
            ThemeLoader.applyTheme(theme, effect);
            applyLayerVisibility(theme);
            displayedThemeId = entry.themeId;
            theme.destroy();
        }
    }

    function cycleToNextTheme() {
        var count = themeScanner.themeList.count;
        if (count >= 2) {
            cycleIndex = (cycleIndex + 1) % count;
            cycleToTheme(cycleIndex);
        }
    }

    function cycleToPreviousTheme() {
        var count = themeScanner.themeList.count;
        if (count >= 2) {
            cycleIndex = (cycleIndex - 1 + count) % count;
            cycleToTheme(cycleIndex);
        }
    }

    function shuffleThemes() {
        var count = themeScanner.themeList.count;
        var order = [];
        for (var i = 0; i < count; i++) {
            order.push(i);
        }
        // Fisher-Yates shuffle
        for (var i = count - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var tmp = order[i];
            order[i] = order[j];
            order[j] = tmp;
        }
        // Avoid back-to-back duplicate with last theme in history
        var lastIdx = shuffledOrder.length > 0
            ? shuffledOrder[shuffledOrder.length - 1] : -1;
        if (lastIdx >= 0 && order.length > 1 && order[0] === lastIdx) {
            var swap = 1 + Math.floor(Math.random() * (order.length - 1));
            var tmp = order[0];
            order[0] = order[swap];
            order[swap] = tmp;
        }
        // Append new cycle to existing history so "prev" still works
        var combined = shuffledOrder.slice();
        for (var k = 0; k < order.length; k++) {
            combined.push(order[k]);
        }
        // Trim oldest entries beyond the history limit
        var maxHistory = 25;
        if (combined.length > maxHistory) {
            var excess = combined.length - maxHistory;
            combined = combined.slice(excess);
            shufflePos = Math.max(0, shufflePos - excess);
        }
        shuffledOrder = combined;
    }

    function cycleToPreviousRandomTheme() {
        var count = themeScanner.themeList.count;
        if (count < 2) {
            return;
        }
        if (shuffledOrder.length === 0 || shufflePos <= 0) {
            return;
        }
        shufflePos = shufflePos - 1;
        var themeIndex = shuffledOrder[shufflePos];
        cycleIndex = themeIndex;
        cycleToTheme(themeIndex);
    }

    function findDisplayedThemeIndex() {
        for (var i = 0; i < themeScanner.themeList.count; i++) {
            if (themeScanner.themeList.get(i).themeId === displayedThemeId) {
                return i;
            }
        }
        return -1;
    }

    function cycleToRandomTheme() {
        var count = themeScanner.themeList.count;
        if (count < 2) {
            return;
        }
        // Seed the history with the current theme so "prev" can return to it
        if (shufflePos < 0) {
            var currentIdx = findDisplayedThemeIndex();
            if (currentIdx >= 0) {
                shuffledOrder = [currentIdx];
                shufflePos = 0;
            }
        }
        shufflePos = (shufflePos + 1);
        if (shufflePos >= shuffledOrder.length) {
            shuffleThemes();
        }
        var themeIndex = shuffledOrder[shufflePos];
        cycleIndex = themeIndex;
        cycleToTheme(themeIndex);
    }

    // --- Auto-cycle timer ---
    Timer {
        id: cycleTimer
        running: effectRoot.autoCycleEnabled
                 && themeScanner.ready && themeScanner.themeList.count > 1
                 && effectRoot._cycleInterval > 0
                 && effectRoot.initialized
        repeat: true
        interval: Math.max(1, effectRoot._cycleInterval) * (effectRoot._cycleIntervalUnit === 1 ? 60000 : 1000)
        onTriggered: effectRoot.cycleInRandomOrder ? effectRoot.cycleToRandomTheme() : effectRoot.cycleToNextTheme()
    }

    // --- Shader effect ---
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0
        property real iWidth: width
        property real iHeight: height

        property real showBackground: 1.0
        property real showStars:      1.0
        property real showGhosts:     1.0
        property real showWaves:      1.0
        property real showGlow:       1.0
        property real showHalo:       1.0
        property real showShine:      1.0
        property real showSpotlights: 1.0

        // Theme colors — order must match shader uniform block layout
        property color bg0: "#000000"
        Behavior on bg0 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color bg1: "#000000"
        Behavior on bg1 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color bg2: "#000000"
        Behavior on bg2 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color bg3: "#000000"
        Behavior on bg3 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color bg4: "#000000"
        Behavior on bg4 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color effectColor: "#000000"
        Behavior on effectColor { ColorAnimation { duration: effectRoot.transitionMs } }
        property color ghost0: "#000000"
        Behavior on ghost0 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color ghost1: "#000000"
        Behavior on ghost1 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color ghost2: "#000000"
        Behavior on ghost2 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color ghost3: "#000000"
        Behavior on ghost3 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain0: "#000000"
        Behavior on wMain0 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain1: "#000000"
        Behavior on wMain1 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain2: "#000000"
        Behavior on wMain2 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain3: "#000000"
        Behavior on wMain3 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain4: "#000000"
        Behavior on wMain4 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain5: "#000000"
        Behavior on wMain5 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain6: "#000000"
        Behavior on wMain6 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain7: "#000000"
        Behavior on wMain7 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain8: "#000000"
        Behavior on wMain8 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wMain9: "#000000"
        Behavior on wMain9 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl0: "#000000"
        Behavior on wHl0 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl1: "#000000"
        Behavior on wHl1 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl2: "#000000"
        Behavior on wHl2 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl3: "#000000"
        Behavior on wHl3 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl4: "#000000"
        Behavior on wHl4 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl5: "#000000"
        Behavior on wHl5 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl6: "#000000"
        Behavior on wHl6 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl7: "#000000"
        Behavior on wHl7 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl8: "#000000"
        Behavior on wHl8 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color wHl9: "#000000"
        Behavior on wHl9 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color glowCore: "#000000"
        Behavior on glowCore { ColorAnimation { duration: effectRoot.transitionMs } }
        property color spotColor: "#000000"
        Behavior on spotColor { ColorAnimation { duration: effectRoot.transitionMs } }
        property color starColor: "#000000"
        Behavior on starColor { ColorAnimation { duration: effectRoot.transitionMs } }

        property real dimLevel: effectRoot.dimLevel
        Behavior on dimLevel { NumberAnimation { duration: effectRoot.transitionMs } }

        property real speedMult: effectRoot.speedMult

        FrameAnimation {
            running: effect.visible && !effectRoot.fpsCap && !effectRoot.paused
            onTriggered: effect.iTime += frameTime * 60.0 * effect.speedMult
        }

        Timer {
            running: effect.visible && effectRoot.fpsCap && !effectRoot.paused
            repeat: true
            interval: Math.ceil(1000 / Math.min(240, Math.max(1, effectRoot.fpsLimit)))
            onTriggered: effect.iTime += interval / 1000.0 * 60.0 * effect.speedMult
        }

        vertexShader: "shaders/rainbow-waves.vert.qsb"
        fragmentShader: "shaders/rainbow-waves.frag.qsb"
    }
}
