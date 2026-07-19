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

    // --- Schema (must match TrippyForestConfig.qml) ---
    readonly property var _defaults: ({
        themeId: "tfm-spectrum",
        randomInitialTheme: false,
        autoCycle: true,
        cycleInterval: 20,
        cycleIntervalUnit: 1,
        transitionDuration: 4,
        cycleInRandomOrder: true,
        cycleMode: "all",
        showFoliage: true,
        showGlow: true,
        showVortex: true,
        speedIndex: 3,
        rotSpeed: 25,
        whirlSpeed: -35,
        spiral: 45,
        density: 60,
        glow: 60,
        mist: 75,
        fog: 50,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // Base angular rates (rad/sec) at 100% of the signed speed sliders.
    readonly property real _rotBase: 0.5
    readonly property real _whirlBase: 0.5

    // --- Parsed settings (reactive properties for bindings) ---
    property real speedMult: 1.0
    property real rotSpeedMult: 0.125
    property real whirlSpeedMult: -0.175
    property real dimLevel: 1.0
    property bool fpsCap: true
    property int fpsLimit: 30
    property bool paused: false

    property real spiral: 0.45
    property real density: 0.60
    property real glowAmount: 0.60
    property real mistAmount: 0.75
    property real fog: 0.50

    function togglePause() { paused = !paused }

    function _readSettings() {
        var json = configuration ? configuration.EffectTrippyForestSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _writeSettings(patch) {
        var s = _readSettings();
        for (var key in patch) {
            s[key] = patch[key];
        }
        configuration.EffectTrippyForestSettings = EffectSettings.save(s);
    }

    function _applySettings() {
        var s = _readSettings();

        // Motion
        speedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.speedIndex] ?? 1.0;
        rotSpeedMult = (s.rotSpeed / 100.0) * _rotBase;
        whirlSpeedMult = (s.whirlSpeed / 100.0) * _whirlBase;

        // Look
        spiral = Math.min(1.0, Math.max(0.0, s.spiral / 100.0));
        density = Math.min(1.0, Math.max(0.0, s.density / 100.0));
        glowAmount = Math.min(1.0, Math.max(0.0, s.glow / 100.0));
        mistAmount = Math.min(1.0, Math.max(0.0, s.mist / 100.0));
        fog = Math.min(1.0, Math.max(0.0, s.fog / 100.0));

        // Theme ID — detect changes
        var newThemeId = s.themeId;
        if (newThemeId !== currentThemeId) {
            currentThemeId = newThemeId;
        }

        // Cycle settings
        autoCycleEnabled = s.autoCycle;
        transitionMs = s.transitionDuration * 1000;
        cycleInRandomOrder = s.cycleInRandomOrder;
        cycleMode = s.cycleMode;
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
    readonly property string effectName: "Trippy Forest"
    readonly property url configUrl: Qt.resolvedUrl("TrippyForestConfig.qml")

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
    property int transitionMs: 4000
    property bool cycleInRandomOrder: false
    onCycleInRandomOrderChanged: resetCycleState()
    property string cycleMode: "all"     // all | light | dark | mixed | psychedelic
    onCycleModeChanged: resetCycleState()
    property int _cycleInterval: 20
    property int _cycleIntervalUnit: 1

    // --- Layer visibility ---
    property var layerKeys: [
        "showFoliage", "showGlow", "showVortex"
    ]

    // React to any config change (JSON blob or hub-level)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectTrippyForestSettings") {
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

    // Theme-list indices eligible for cycling under the current light/dark/mixed
    // filter. Falls back to the full list when the filter would leave nothing.
    function themePool() {
        var pool = [];
        for (var i = 0; i < themeScanner.themeList.count; i++) {
            var m = themeScanner.themeList.get(i).mode || "mixed";
            if (cycleMode === "all" || m === cycleMode) {
                pool.push(i);
            }
        }
        if (pool.length === 0) {
            for (var j = 0; j < themeScanner.themeList.count; j++) {
                pool.push(j);
            }
        }
        return pool;
    }

    function pickRandomThemeId() {
        var pool = themePool();
        if (pool.length === 0) {
            return currentThemeId;
        }
        var idx = pool[Math.floor(Math.random() * pool.length)];
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
            displayedThemeId = theme.themeId;
            theme.destroy();
        }
        initialized = true;
    }

    function loadCurrentTheme() {
        if (!themeScanner.ready) {
            return;
        }
        var theme = themeScanner.loadThemeById(currentThemeId);
        if (theme) {
            ThemeLoader.applyTheme(theme, effect);
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
            displayedThemeId = entry.themeId;
            theme.destroy();
        }
    }

    function cycleToNextTheme() {
        var pool = themePool();
        if (pool.length < 1) {
            return;
        }
        var pos = pool.indexOf(findDisplayedThemeIndex());
        var next = pool[(pos + 1 + pool.length) % pool.length];
        cycleIndex = next;
        cycleToTheme(next);
    }

    function cycleToPreviousTheme() {
        var pool = themePool();
        if (pool.length < 1) {
            return;
        }
        var pos = pool.indexOf(findDisplayedThemeIndex());
        if (pos < 0) {
            pos = 0;
        }
        var prev = pool[(pos - 1 + pool.length) % pool.length];
        cycleIndex = prev;
        cycleToTheme(prev);
    }

    function shuffleThemes() {
        var order = themePool();
        // Fisher-Yates shuffle
        for (var i = order.length - 1; i > 0; i--) {
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
                 && !effectRoot.paused
        repeat: true
        interval: Math.max(1, effectRoot._cycleInterval) * (effectRoot._cycleIntervalUnit === 1 ? 60000 : 1000)
        onTriggered: effectRoot.cycleInRandomOrder ? effectRoot.cycleToRandomTheme() : effectRoot.cycleToNextTheme()
    }

    Component.onCompleted: _applySettings()

    // --- Shader effect ---
    // CRITICAL: Property order must match the std140 uniform block in trippy-forest.frag
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0
        property real iWidth: width
        property real iHeight: height
        property real rotTime: 0
        property real whirlTime: 0
        property real showFoliage: 1.0
        property real showGlow: 1.0
        property real showVortex: 1.0
        property real spiral: effectRoot.spiral
        property real density: effectRoot.density
        property real glowAmount: effectRoot.glowAmount
        property real mistAmount: effectRoot.mistAmount
        property real fog: effectRoot.fog
        property real dimLevel: effectRoot.dimLevel
        Behavior on dimLevel { NumberAnimation { duration: effectRoot.transitionMs } }

        // Theme colors — order must match shader uniform block layout. Behaviors
        // cross-fade the whole scene when the theme changes.
        property color foliageCol: "#0e3d1e"
        Behavior on foliageCol { ColorAnimation { duration: effectRoot.transitionMs } }
        property color glowCol: "#2fd0b0"
        Behavior on glowCol { ColorAnimation { duration: effectRoot.transitionMs } }
        property color mistCol: "#3a6a80"
        Behavior on mistCol { ColorAnimation { duration: effectRoot.transitionMs } }
        property color pal0: "#ff2d55"
        Behavior on pal0 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color pal1: "#ff9500"
        Behavior on pal1 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color pal2: "#ffee33"
        Behavior on pal2 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color pal3: "#34e56b"
        Behavior on pal3 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color pal4: "#22c3ff"
        Behavior on pal4 { ColorAnimation { duration: effectRoot.transitionMs } }
        property color pal5: "#a45cff"
        Behavior on pal5 { ColorAnimation { duration: effectRoot.transitionMs } }

        // iTime drives the zoom, rotTime the tunnel rotation, whirlTime the
        // counter-rotating vortex; all accumulated in seconds.
        FrameAnimation {
            running: effect.visible && !effectRoot.fpsCap && !effectRoot.paused
            onTriggered: {
                effect.iTime += frameTime * effectRoot.speedMult
                effect.rotTime += frameTime * effectRoot.rotSpeedMult
                effect.whirlTime += frameTime * effectRoot.whirlSpeedMult
            }
        }

        Timer {
            running: effect.visible && effectRoot.fpsCap && !effectRoot.paused
            repeat: true
            interval: Math.ceil(1000 / Math.min(240, Math.max(1, effectRoot.fpsLimit)))
            onTriggered: {
                var dt = interval / 1000.0
                effect.iTime += dt * effectRoot.speedMult
                effect.rotTime += dt * effectRoot.rotSpeedMult
                effect.whirlTime += dt * effectRoot.whirlSpeedMult
            }
        }

        vertexShader: "shaders/trippy-forest.vert.qsb"
        fragmentShader: "shaders/trippy-forest.frag.qsb"
    }
}
