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

    // --- Schema (must match TrippyTunnelConfig.qml) ---
    readonly property var _defaults: ({
        themeId: "ttm-spectrum",
        randomInitialTheme: false,
        autoCycle: true,
        cycleInterval: 20,
        cycleIntervalUnit: 1,
        transitionDuration: 4,
        cycleInRandomOrder: true,
        cycleMode: "all",
        showCanopy: true,
        showGlow: true,
        showVortex: true,
        showStars: true,
        showBeams: true,
        showDots: true,
        speedIndex: 3,
        rotSpeed: 15,
        whirlSpeed: -35,
        spiral: 45,
        vortexSwirl: 45,
        tunnelWidth: 100,
        widthOsc: false,
        widthOscRange: 20,
        widthOscInterval: 10,
        widthOscChance: 50,
        holeRadius: 25,
        holeOsc: true,
        holeOscRange: 5,
        holeOscInterval: 120,
        holeOscChance: 25,
        swirlVary: true,
        swirlSpeed: 10,
        swirlBurst: true,
        swirlVaryMargin: 40,
        swirlVaryInterval: 120,
        swirlVaryChance: 25,
        transitionTime: 10,
        depth: 55,
        density: 60,
        glow: 60,
        mist: 75,
        fog: 50,
        canopyOpacity: 100,
        vortexOpacity: 100,
        bloom: 70,
        bloomRadius: 40,
        starCount: 40,
        starSpeed: 50,
        starLength: 35,
        starOpacity: 65,
        beamCount: 220,
        beamSpeed: 20,
        beamLength: 45,
        beamOpacity: 50,
        dotCount: 60,
        dotSpeed: 60,
        dotOpacity: 100,
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
    property real paramTransitionMs: 1000   // how long a value change takes to settle
    property bool fpsCap: true
    property int fpsLimit: 30
    property bool paused: false

    property real spiral: 0.45          // spring-smoothed value fed to the shader
    property real spiralTarget: 0.45    // base + drift + burst steer this
    property real spiralVel: 0.0        // spring velocity
    property bool _swirlInit: false
    // Last-applied BASE values. Runtime swirl/width/hole are only re-seeded when
    // their base setting actually changes, so editing an unrelated setting (e.g.
    // Brightness) doesn't interrupt the ongoing drift / oscillation.
    property real _spiralBasePrev: -999
    property real _widthBasePrev: -999
    property real _holeBasePrev: -999
    property real vortexSwirl: 0.45
    property real tunnelWidth: 1.0        // runtime value fed to the shader
    property real tunnelWidthBase: 1.0    // initial value; oscillation ranges around THIS
    property bool widthOsc: false
    property real widthOscRangeMult: 0.20 // ± oscillation range (uv multiplier)
    property int widthOscInterval: 10
    property int widthOscChance: 50
    property real holeRadius: 0.11        // runtime value fed to the shader
    property real holeRadiusBase: 0.11    // initial value; oscillation ranges around THIS
    property bool holeOsc: false
    property real holeOscRangeUv: 0.09    // ± oscillation range in uv units
    property int holeOscInterval: 10
    property int holeOscChance: 50
    property bool swirlVary: false        // continuous drift enable
    property real swirlSpeedMult: 0.012   // continuous swirl drift (0..1 units / sec)
    property int _swirlDir: 1              // drift direction, reflects at the bounds
    property bool swirlBurst: false       // periodic burst enable
    property real swirlVaryMargin: 0.10   // burst size: fraction of the 0..1 swirl range
    property int swirlVaryInterval: 8     // seconds between burst rolls
    property int swirlVaryChance: 100     // percent chance each roll actually bursts
    property real depth: 0.56            // exponential ring recession rate
    property real density: 0.60
    property real glowAmount: 0.60
    property real mistAmount: 0.75
    property real fog: 0.50
    property real canopyOpacity: 1.0
    property real vortexOpacity: 1.0
    property real bloomAmount: 0.70
    property real bloomRadius: 0.24
    property real starCount: 40
    property real starSpeed: 1.0
    property real starLength: 0.35
    property real starOpacity: 1.0
    property real beamCount: 220
    property real beamSpeed: 1.0
    property real beamLength: 0.45
    property real beamOpacity: 1.0
    property real dotCount: 60
    property real dotSpeed: 1.0
    property real dotOpacity: 1.0

    function togglePause() { paused = !paused }

    // Continuous slow swirl: nudge the swirl TARGET by a tiny delta each frame,
    // reflecting at the 0/1 bounds so it drifts back and forth forever.
    function _driftSwirl(dt) {
        if (!swirlVary || swirlSpeedMult <= 0.0) return   // speed 0 -> no drift
        var ns = spiralTarget + dt * swirlSpeedMult * _swirlDir
        if (ns >= 1.0) { ns = 1.0; _swirlDir = -1 }
        else if (ns <= 0.0) { ns = 0.0; _swirlDir = 1 }
        spiralTarget = ns
    }

    // Critically-damped spring: ease `spiral` toward `spiralTarget`. Its velocity
    // ramps smoothly in and out (no sharp onset), so the rotation that ANY swirl
    // change induces — manual edit, continuous drift, or a burst — speeds up /
    // slows down gently instead of snapping. dt is clamped so the explicit
    // integrator stays stable at low frame rates.
    function _springSwirl(dt) {
        var h = Math.min(dt, 0.04)
        var T = Math.max(0.1, paramTransitionMs / 1000.0)   // target settle time (s)
        var k = Math.min(150.0, 25.0 / (T * T))             // (5/T)^2, capped for stability
        var c = 2.0 * Math.sqrt(k)                          // critical damping
        spiralVel += ((spiralTarget - spiral) * k - spiralVel * c) * h
        spiral += spiralVel * h
    }

    function _readSettings() {
        var json = configuration ? configuration.EffectTrippyTunnelSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _writeSettings(patch) {
        var s = _readSettings();
        for (var key in patch) {
            s[key] = patch[key];
        }
        configuration.EffectTrippyTunnelSettings = EffectSettings.save(s);
    }

    function _applySettings() {
        var s = _readSettings();

        // Motion
        speedMult = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75][s.speedIndex] ?? 1.0;
        rotSpeedMult = (s.rotSpeed / 100.0) * _rotBase;
        whirlSpeedMult = (s.whirlSpeed / 100.0) * _whirlBase;

        // Look
        var sBase = Math.min(1.0, Math.max(0.0, s.spiral / 100.0));
        if (sBase !== _spiralBasePrev) {
            _spiralBasePrev = sBase;
            spiralTarget = sBase;
            if (!_swirlInit) { spiral = spiralTarget; spiralVel = 0.0; _swirlInit = true; }
        }
        vortexSwirl = Math.min(1.0, Math.max(0.0, s.vortexSwirl / 100.0));
        tunnelWidthBase = Math.max(0.1, s.tunnelWidth / 100.0);
        if (tunnelWidthBase !== _widthBasePrev) { _widthBasePrev = tunnelWidthBase; tunnelWidth = tunnelWidthBase; }
        widthOsc = s.widthOsc;
        widthOscRangeMult = Math.max(0.0, s.widthOscRange / 100.0);
        widthOscInterval = Math.max(1, s.widthOscInterval);
        widthOscChance = Math.max(0, Math.min(100, s.widthOscChance));
        holeRadiusBase = Math.min(0.45, Math.max(0.0, s.holeRadius / 100.0 * 0.45));
        if (holeRadiusBase !== _holeBasePrev) { _holeBasePrev = holeRadiusBase; holeRadius = holeRadiusBase; }
        holeOsc = s.holeOsc;
        holeOscRangeUv = Math.max(0.0, s.holeOscRange / 100.0 * 0.45);
        holeOscInterval = Math.max(1, s.holeOscInterval);
        holeOscChance = Math.max(0, Math.min(100, s.holeOscChance));
        swirlVary = s.swirlVary;
        swirlSpeedMult = Math.max(0.0, s.swirlSpeed / 100.0) * 0.06;
        swirlBurst = s.swirlBurst;
        swirlVaryMargin = Math.max(0.0, s.swirlVaryMargin / 100.0);
        swirlVaryInterval = Math.max(1, s.swirlVaryInterval);
        swirlVaryChance = Math.max(0, Math.min(100, s.swirlVaryChance));
        density = Math.min(1.0, Math.max(0.0, s.density / 100.0));
        glowAmount = Math.min(1.0, Math.max(0.0, s.glow / 100.0));
        mistAmount = Math.min(1.0, Math.max(0.0, s.mist / 100.0));
        fog = Math.min(1.0, Math.max(0.0, s.fog / 100.0));
        canopyOpacity = Math.min(1.0, Math.max(0.0, s.canopyOpacity / 100.0));
        vortexOpacity = Math.min(1.0, Math.max(0.0, s.vortexOpacity / 100.0));
        // Map 0..100 % across the USABLE recession range: above ~0.85 the far
        // rings collapse into the hole and the tunnel reads emptier, so 100 %
        // stops at the deepest good value instead of the degrading zone.
        depth = 0.20 + Math.min(1.0, Math.max(0.0, s.depth / 100.0)) * 0.65;
        bloomAmount = Math.min(1.0, Math.max(0.0, s.bloom / 100.0));
        bloomRadius = Math.min(1.0, Math.max(0.0, s.bloomRadius / 100.0)) * 0.6;
        starCount = Math.max(0, s.starCount);
        starSpeed = Math.max(0.0, s.starSpeed / 100.0);
        starLength = Math.min(1.0, Math.max(0.0, s.starLength / 100.0));
        starOpacity = Math.min(1.0, Math.max(0.0, s.starOpacity / 100.0));
        beamCount = Math.max(4, s.beamCount);
        beamSpeed = Math.max(0.0, s.beamSpeed / 100.0);
        beamLength = Math.min(1.0, Math.max(0.0, s.beamLength / 100.0));
        beamOpacity = Math.min(1.0, Math.max(0.0, s.beamOpacity / 100.0));
        dotCount = Math.max(0, s.dotCount);
        dotSpeed = Math.max(0.0, s.dotSpeed / 100.0);
        dotOpacity = Math.min(1.0, Math.max(0.0, s.dotOpacity / 100.0));

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
        paramTransitionMs = Math.max(100, s.transitionTime * 100);

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
    readonly property string effectName: "Trippy Tunnel"
    readonly property url configUrl: Qt.resolvedUrl("TrippyTunnelConfig.qml")

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
        "showCanopy", "showGlow", "showVortex", "showStars", "showBeams", "showDots"
    ]

    // React to any config change (JSON blob or hub-level)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectTrippyTunnelSettings") {
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

    // --- Tunnel-swirl auto-vary: random-walk the live swirl value every N secs,
    // stepping up to ±margin from the current value. The ShaderEffect's Behavior
    // the spring eases each jump smoothly. Runtime only — the base setting is
    // untouched.
    Timer {
        id: swirlVaryTimer
        running: effectRoot.swirlBurst && !effectRoot.paused
        repeat: true
        interval: Math.max(1, effectRoot.swirlVaryInterval) * 1000
        onTriggered: {
            if (Math.random() * 100.0 >= effectRoot.swirlVaryChance) return   // probability gate
            var delta = (Math.random() * 2.0 - 1.0) * effectRoot.swirlVaryMargin
            effectRoot.spiralTarget = Math.min(1.0, Math.max(0.0, effectRoot.spiralTarget + delta))
        }
    }

    // Oscillate the tunnel width around its INITIAL value (bounded, like the hole).
    Timer {
        id: widthOscTimer
        running: effectRoot.widthOsc && !effectRoot.paused
        repeat: true
        interval: Math.max(1, effectRoot.widthOscInterval) * 1000
        onTriggered: {
            if (Math.random() * 100.0 >= effectRoot.widthOscChance) return
            var d = (Math.random() * 2.0 - 1.0) * effectRoot.widthOscRangeMult
            effectRoot.tunnelWidth = Math.min(2.5, Math.max(0.5, effectRoot.tunnelWidthBase + d))
        }
    }

    // Oscillate the centre hole around its INITIAL value (not the current one),
    // so the range is bounded and it can never creep down to 0. The ShaderEffect's
    // Behavior on holeRadius eases each jump. Runtime only.
    Timer {
        id: holeOscTimer
        running: effectRoot.holeOsc && !effectRoot.paused
        repeat: true
        interval: Math.max(1, effectRoot.holeOscInterval) * 1000
        onTriggered: {
            if (Math.random() * 100.0 >= effectRoot.holeOscChance) return
            var d = (Math.random() * 2.0 - 1.0) * effectRoot.holeOscRangeUv
            effectRoot.holeRadius = Math.min(0.45, Math.max(0.0, effectRoot.holeRadiusBase + d))
        }
    }

    Component.onCompleted: _applySettings()

    // --- Shader effect ---
    // CRITICAL: Property order must match the std140 uniform block in trippy-tunnel.frag
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0
        property real iWidth: width
        property real iHeight: height
        property real rotTime: 0
        property real whirlTime: 0
        property real starTime: 0
        property real beamTime: 0
        property real dotTime: 0
        property real showCanopy: 1.0
        property real showGlow: 1.0
        property real showVortex: 1.0
        property real showStars: 1.0
        property real showBeams: 1.0
        property real showDots: 1.0
        // Ease look-parameter changes so pressing Apply glides to the new value
        // instead of snapping (which reads as the animation "restarting").
        // `spiral` is spring-smoothed in the effect root (see _springSwirl) so a
        // swirl change ramps its induced rotation gently in and out. vortexSwirl
        // has no continuous drift, so a plain cornerless InOutSine ease suffices.
        property real spiral: effectRoot.spiral
        property real vortexSwirl: effectRoot.vortexSwirl
        Behavior on vortexSwirl { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutSine } }
        property real tunnelWidth: effectRoot.tunnelWidth
        Behavior on tunnelWidth { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real holeRadius: effectRoot.holeRadius
        Behavior on holeRadius { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real depth: effectRoot.depth
        Behavior on depth { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real density: effectRoot.density
        Behavior on density { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real glowAmount: effectRoot.glowAmount
        Behavior on glowAmount { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real mistAmount: effectRoot.mistAmount
        Behavior on mistAmount { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real fog: effectRoot.fog
        Behavior on fog { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real canopyOpacity: effectRoot.canopyOpacity
        Behavior on canopyOpacity { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real vortexOpacity: effectRoot.vortexOpacity
        Behavior on vortexOpacity { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real bloomAmount: effectRoot.bloomAmount
        Behavior on bloomAmount { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real bloomRadius: effectRoot.bloomRadius
        Behavior on bloomRadius { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real starCount: effectRoot.starCount
        property real starLength: effectRoot.starLength
        Behavior on starLength { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real starOpacity: effectRoot.starOpacity
        Behavior on starOpacity { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real beamCount: effectRoot.beamCount
        property real beamLength: effectRoot.beamLength
        Behavior on beamLength { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real beamOpacity: effectRoot.beamOpacity
        Behavior on beamOpacity { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real dotCount: effectRoot.dotCount
        property real dotOpacity: effectRoot.dotOpacity
        Behavior on dotOpacity { NumberAnimation { duration: effectRoot.paramTransitionMs; easing.type: Easing.InOutQuad } }
        property real dimLevel: effectRoot.dimLevel
        Behavior on dimLevel { NumberAnimation { duration: effectRoot.transitionMs } }

        // Theme colors — order must match shader uniform block layout. Behaviors
        // cross-fade the whole scene when the theme changes.
        property color canopyCol: "#0e3d1e"
        Behavior on canopyCol { ColorAnimation { duration: effectRoot.transitionMs } }
        property color glowCol: "#2fd0b0"
        Behavior on glowCol { ColorAnimation { duration: effectRoot.transitionMs } }
        property color mistCol: "#3a6a80"
        Behavior on mistCol { ColorAnimation { duration: effectRoot.transitionMs } }
        property color starsCol: "#ffffff"
        Behavior on starsCol { ColorAnimation { duration: effectRoot.transitionMs } }
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
                effect.starTime += frameTime * effectRoot.starSpeed
                effect.beamTime += frameTime * effectRoot.beamSpeed
                effect.dotTime += frameTime * effectRoot.dotSpeed
                effectRoot._driftSwirl(frameTime)
                effectRoot._springSwirl(frameTime)
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
                effect.starTime += dt * effectRoot.starSpeed
                effect.beamTime += dt * effectRoot.beamSpeed
                effect.dotTime += dt * effectRoot.dotSpeed
                effectRoot._driftSwirl(dt)
                effectRoot._springSwirl(dt)
            }
        }

        vertexShader: "shaders/trippy-tunnel.vert.qsb"
        fragmentShader: "shaders/trippy-tunnel.frag.qsb"
    }
}
