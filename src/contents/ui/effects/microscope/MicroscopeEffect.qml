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

    // --- Schema (must match MicroscopeConfig.qml) ---
    readonly property var _defaults: ({
        themeId: "mzm-chlorophyll",
        randomInitialTheme: true,
        autoCycle: true,
        cycleInterval: 15,
        cycleIntervalUnit: 1,
        transitionDuration: 3,
        cycleInRandomOrder: true,
        density: 60,
        showFog: true,
        showParticles: true,
        showVignette: true,
        dustAmount: 55,
        dustSize: 22,
        speedIndex: 3,
        rotation: 20,
        microbeMotion: 50,
        fpsCap: true,
        fpsLimit: 30,
        dimCap: false,
        dimLevel: 100
    })

    // Hard cap on dust motes; mirrors PMAX in microscope.frag.
    readonly property int _dustMax: 96

    // --- Parsed settings (reactive properties for bindings) ---
    property real speedMult: 1.0
    // Radians of scene spin per second of iTime; sign sets direction, 0 = off.
    property real rotationSpeed: 0.06
    // Strength of the microbes' idle wander/squirm/breathe (0 = frozen, 1 = full).
    property real microbeMotion: 1.0
    property bool fpsCap: true
    property int fpsLimit: 30
    property bool paused: false
    // Starts dark and fades up to the target on launch (Behavior eases 0 -> target).
    property real dimLevel: 0.0

    property real density: 0.6
    property bool showFog: true
    property bool showParticles: true
    property bool showVignette: true
    property real dustCount: 53      // number of motes passed to the shader
    property real dustRadius: 0.015  // base mote radius passed to the shader

    function togglePause() { paused = !paused }

    function _readSettings() {
        var json = configuration ? configuration.EffectMicroscopeSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _writeSettings(patch) {
        var s = _readSettings();
        for (var key in patch) {
            s[key] = patch[key];
        }
        configuration.EffectMicroscopeSettings = EffectSettings.save(s);
    }

    function _applySettings() {
        var s = _readSettings();
        speedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.speedIndex] ?? 1.0;
        rotationSpeed = (s.rotation / 100.0) * 0.15;   // -100..100 -> ∓0.15 rad/s
        microbeMotion = Math.min(100, Math.max(0, s.microbeMotion)) / 100.0;
        fpsCap = s.fpsCap;
        fpsLimit = s.fpsLimit;
        dimLevel = s.dimCap ? s.dimLevel / 100.0 : 1.0;

        density = Math.min(1.0, Math.max(0.0, s.density / 100.0));
        showFog = s.showFog;
        showParticles = s.showParticles;
        showVignette = s.showVignette;

        // Dust amount -> mote count; dust size -> mote radius (smaller = finer dust).
        dustCount = Math.round(Math.min(100, Math.max(0, s.dustAmount)) / 100.0 * _dustMax);
        dustRadius = 0.006 + Math.min(100, Math.max(1, s.dustSize)) / 100.0 * 0.039;

        // Theme / cycling
        var newThemeId = s.themeId;
        if (newThemeId !== currentThemeId) {
            currentThemeId = newThemeId;
        }
        autoCycleEnabled = s.autoCycle;
        transitionMs = s.transitionDuration * 1000;
        cycleInRandomOrder = s.cycleInRandomOrder;
        _cycleInterval = s.cycleInterval;
        _cycleIntervalUnit = s.cycleIntervalUnit;
    }

    // --- Outputs for hub ---
    readonly property bool hasError: effect.status === ShaderEffect.Error
    readonly property string errorLog: effect.log || ""
    readonly property string effectName: "Microscope"
    readonly property url configUrl: Qt.resolvedUrl("MicroscopeConfig.qml")

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

    // React to config changes (JSON blob)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectMicroscopeSettings") {
                effectRoot._applySettings();
            }
        }
    }

    Component.onCompleted: _applySettings()

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
        for (var f = count - 1; f > 0; f--) {
            var j = Math.floor(Math.random() * (f + 1));
            var tmp = order[f];
            order[f] = order[j];
            order[j] = tmp;
        }
        // Avoid back-to-back duplicate with last theme in history
        var lastIdx = shuffledOrder.length > 0
            ? shuffledOrder[shuffledOrder.length - 1] : -1;
        if (lastIdx >= 0 && order.length > 1 && order[0] === lastIdx) {
            var swap = 1 + Math.floor(Math.random() * (order.length - 1));
            var tmp2 = order[0];
            order[0] = order[swap];
            order[swap] = tmp2;
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

    // --- Shader effect ---
    // CRITICAL: Property order must match the std140 uniform block in microscope.frag
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0
        property real iWidth: width
        property real iHeight: height
        property real density: effectRoot.density
        property real dimLevel: effectRoot.dimLevel
        Behavior on dimLevel { NumberAnimation { duration: effectRoot.transitionMs } }

        // Colors are set imperatively by ThemeLoader.applyTheme(); Behaviors make
        // theme switches cross-fade. Defaults match the Chlorophyll theme so the
        // first frame (before the scanner is ready) looks right.
        property real cellColorR: 0.227
        Behavior on cellColorR { NumberAnimation { duration: effectRoot.transitionMs } }
        property real cellColorG: 0.541
        Behavior on cellColorG { NumberAnimation { duration: effectRoot.transitionMs } }
        property real cellColorB: 0.180
        Behavior on cellColorB { NumberAnimation { duration: effectRoot.transitionMs } }
        property real mediumColorR: 0.043
        Behavior on mediumColorR { NumberAnimation { duration: effectRoot.transitionMs } }
        property real mediumColorG: 0.141
        Behavior on mediumColorG { NumberAnimation { duration: effectRoot.transitionMs } }
        property real mediumColorB: 0.102
        Behavior on mediumColorB { NumberAnimation { duration: effectRoot.transitionMs } }
        property real illumColorR: 0.824
        Behavior on illumColorR { NumberAnimation { duration: effectRoot.transitionMs } }
        property real illumColorG: 0.925
        Behavior on illumColorG { NumberAnimation { duration: effectRoot.transitionMs } }
        property real illumColorB: 0.627
        Behavior on illumColorB { NumberAnimation { duration: effectRoot.transitionMs } }

        property real showFog: effectRoot.showFog ? 1.0 : 0.0
        property real showParticles: effectRoot.showParticles ? 1.0 : 0.0
        property real showVignette: effectRoot.showVignette ? 1.0 : 0.0
        property real particleCount: effectRoot.dustCount
        property real particleSize: effectRoot.dustRadius
        // Accumulated scene-spin angle (radians). Advanced with iTime so a speed
        // change never makes the angle jump — only its future rate changes.
        property real rotationAngle: 0
        property real microbeMotion: effectRoot.microbeMotion

        // iTime is accumulated in seconds; the forward-motion constants in the
        // shader are tuned for it. speedMult scales the zoom pace.
        FrameAnimation {
            running: effect.visible && !effectRoot.fpsCap && !effectRoot.paused
            onTriggered: {
                var dt = frameTime * effectRoot.speedMult;
                effect.iTime += dt;
                effect.rotationAngle += dt * effectRoot.rotationSpeed;
            }
        }

        Timer {
            running: effect.visible && effectRoot.fpsCap && !effectRoot.paused
            repeat: true
            interval: Math.ceil(1000 / Math.min(240, Math.max(1, effectRoot.fpsLimit)))
            onTriggered: {
                var dt = (interval / 1000.0) * effectRoot.speedMult;
                effect.iTime += dt;
                effect.rotationAngle += dt * effectRoot.rotationSpeed;
            }
        }

        vertexShader: "shaders/microscope.vert.qsb"
        fragmentShader: "shaders/microscope.frag.qsb"
    }
}
