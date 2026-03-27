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

    // --- Schema (must match LavaLampConfig.qml) ---
    readonly property var _defaults: ({
        themeId: "llm-heat",
        randomInitialTheme: true,
        autoCycle: true,
        cycleInterval: 15,
        cycleIntervalUnit: 1,
        transitionDuration: 3,
        cycleInRandomOrder: true,
        orbCount: 35,
        showGlow: true,
        showBackgroundGradient: true,
        speedIndex: 3,
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
    property int orbCount: 35
    property bool showGlow: true
    property bool showBackgroundGradient: true

    function _readSettings() {
        var json = configuration ? configuration.EffectLavaLampSettings : "{}";
        return EffectSettings.load(json, _defaults);
    }

    function _writeSettings(patch) {
        var s = _readSettings();
        for (var key in patch) {
            s[key] = patch[key];
        }
        configuration.EffectLavaLampSettings = EffectSettings.save(s);
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

        // Rendering options
        orbCount = Math.min(70, Math.max(16, s.orbCount));
        showGlow = s.showGlow;
        showBackgroundGradient = s.showBackgroundGradient;
    }

    // --- Outputs for hub ---
    readonly property bool hasError: effect.status === ShaderEffect.Error
    readonly property string errorLog: effect.log || ""
    readonly property string effectName: "Lava Lamp"
    readonly property url configUrl: Qt.resolvedUrl("LavaLampConfig.qml")

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

    // React to any config change (JSON blob or hub-level)
    Connections {
        target: effectRoot.configuration
        function onValueChanged(key, value) {
            if (key === "EffectLavaLampSettings") {
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
            applyRenderingOverrides();
            displayedThemeId = theme.themeId;
            theme.destroy();
        }
        initialized = true;
    }

    function loadCurrentTheme() {
        console.warn("Lava Lamp [effect]: loadCurrentTheme() id=" + currentThemeId);
        if (!themeScanner.ready) {
            return;
        }
        var theme = themeScanner.loadThemeById(currentThemeId);
        if (theme) {
            ThemeLoader.applyTheme(theme, effect);
            applyRenderingOverrides();
            displayedThemeId = theme.themeId;
            theme.destroy();
        }
    }

    function applyRenderingOverrides() {
        effect.glowEffectEnabled = effectRoot.showGlow ? 1 : 0;
        effect.backgroundGradientEnabled = effectRoot.showBackgroundGradient ? 1 : 0;
    }

    function cycleToTheme(themeIndex) {
        if (!themeScanner.ready) {
            return;
        }
        var entry = themeScanner.themeList.get(themeIndex);
        var theme = themeScanner.loadThemeFile(entry.fileUrl);
        if (theme) {
            ThemeLoader.applyTheme(theme, effect);
            applyRenderingOverrides();
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

    // --- CPU-side metaball computation ---
    readonly property real metaballRandomSeed: Math.random() * 10000.0
    readonly property int metaballMatCount: Math.ceil(effectRoot.orbCount / 4)
    readonly property real metaballMinSize: 0.02
    readonly property real metaballMaxSize: 0.07
    readonly property real metaballThreshold: 0.99
    readonly property real verticalBias: 2.0
    readonly property real horizontalScale: 0.5
    readonly property var speedBuckets: [
        { maxSize: 0.33, minSpeed: 70, maxSpeed: 100 },
        { maxSize: 0.66, minSpeed: 45, maxSpeed: 75 },
        { maxSize: 1.00, minSpeed: 25, maxSpeed: 50 }
    ]
    readonly property real speedMultiplier: 1.0

    function fract(x) {
        return x - Math.floor(x);
    }

    function computeMetaballPositions(time, randomSeed, count, resW, resH, minSize, maxSize) {
        var positions = [];
        for (var i = 0; i < count; i++) {
            var seed = (i + randomSeed) * 12.9898;
            var randomX = fract(Math.sin(seed) * 43758.5453);
            var randomY = fract(Math.sin(seed * 1.618) * 43758.5453);
            var randomVX = fract(Math.sin(seed * 2.718) * 43758.5453);
            var randomVY = fract(Math.sin(seed * 3.141) * 43758.5453);
            var randomR = fract(Math.sin(seed * 1.414) * 43758.5453);
            var randomSpd = fract(Math.sin(seed * 2.236) * 43758.5453);

            var radius = randomR * (maxSize - minSize) + minSize;

            // Speed buckets: derive speed range from orb size
            var sizeNorm = (maxSize > minSize) ? (radius - minSize) / (maxSize - minSize) : 0.5;
            var bucketMinSpeed = speedBuckets[speedBuckets.length - 1].minSpeed;
            var bucketMaxSpeed = speedBuckets[speedBuckets.length - 1].maxSpeed;
            for (var b = 0; b < speedBuckets.length; b++) {
                if (sizeNorm <= speedBuckets[b].maxSize) {
                    bucketMinSpeed = speedBuckets[b].minSpeed;
                    bucketMaxSpeed = speedBuckets[b].maxSpeed;
                    break;
                }
            }
            var speed = (randomSpd * (bucketMaxSpeed - bucketMinSpeed) + bucketMinSpeed) / 100.0 * speedMultiplier;
            var dirX = (randomVX - 0.5) * 2.0;
            var dirY = (randomVY - 0.5) * 2.0;
            if (Math.abs(dirX) < 0.3) dirX = (dirX >= 0 ? 0.3 : -0.3);
            if (Math.abs(dirY) < 0.3) dirY = (dirY >= 0 ? 0.3 : -0.3);
            var vx = dirX * speed * horizontalScale;
            var vy = dirY * speed * verticalBias;

            var startX = randomX * (resW - 2.0 * radius) + radius;
            var startY = randomY * (resH - 2.0 * radius) + radius;

            var x = startX + vx * time;
            var y = startY + vy * time;

            // Bouncing boundaries
            var leftBound = -radius;
            var rightBound = resW + radius;
            var topBound = -radius;
            var bottomBound = resH + radius;

            var bounceWidth = rightBound - leftBound;
            var bounceHeight = bottomBound - topBound;

            // X axis bounce
            var relativeX = x - leftBound;
            var bounceCount = Math.floor(relativeX / bounceWidth);
            var posInCycle = relativeX - bounceCount * bounceWidth;
            if (bounceCount % 2 === 0) {
                x = leftBound + posInCycle;
            } else {
                x = leftBound + bounceWidth - posInCycle;
            }

            // Y axis bounce
            var relativeY = y - topBound;
            bounceCount = Math.floor(relativeY / bounceHeight);
            posInCycle = relativeY - bounceCount * bounceHeight;
            if (bounceCount % 2 === 0) {
                y = topBound + posInCycle;
            } else {
                y = topBound + bounceHeight - posInCycle;
            }

            positions.push({ x: x, y: y, r: radius });
        }
        return positions;
    }

    function packMetaballsToMatrices(positions, matCount) {
        var matrices = [];
        for (var m = 0; m < matCount; m++) {
            var xs = [0, 0, 0, 0];
            var ys = [0, 0, 0, 0];
            var rs = [0, 0, 0, 0];
            for (var c = 0; c < 4; c++) {
                var idx = m * 4 + c;
                if (idx < positions.length) {
                    xs[c] = positions[idx].x;
                    ys[c] = positions[idx].y;
                    rs[c] = positions[idx].r;
                }
            }
            // Row-major in QML; GLSL mat4[col] accesses columns.
            // Qt transposes, so rows here become columns in GLSL.
            matrices.push(Qt.matrix4x4(
                xs[0], xs[1], xs[2], xs[3],
                ys[0], ys[1], ys[2], ys[3],
                rs[0], rs[1], rs[2], rs[3],
                0, 0, 0, 0
            ));
        }
        return matrices;
    }

    function updateMetaballs() {
        var minSizePx = metaballMinSize * effect.height;
        var maxSizePx = metaballMaxSize * effect.height;
        var positions = computeMetaballPositions(
            effect.iTime, metaballRandomSeed, effectRoot.orbCount,
            effect.width, effect.height,
            minSizePx, maxSizePx
        );
        var matrices = packMetaballsToMatrices(positions, metaballMatCount);
        if (matrices.length > 0)  effect.metaballData0  = matrices[0];
        if (matrices.length > 1)  effect.metaballData1  = matrices[1];
        if (matrices.length > 2)  effect.metaballData2  = matrices[2];
        if (matrices.length > 3)  effect.metaballData3  = matrices[3];
        if (matrices.length > 4)  effect.metaballData4  = matrices[4];
        if (matrices.length > 5)  effect.metaballData5  = matrices[5];
        if (matrices.length > 6)  effect.metaballData6  = matrices[6];
        if (matrices.length > 7)  effect.metaballData7  = matrices[7];
        if (matrices.length > 8)  effect.metaballData8  = matrices[8];
        if (matrices.length > 9)  effect.metaballData9  = matrices[9];
        if (matrices.length > 10) effect.metaballData10 = matrices[10];
        if (matrices.length > 11) effect.metaballData11 = matrices[11];
        if (matrices.length > 12) effect.metaballData12 = matrices[12];
        if (matrices.length > 13) effect.metaballData13 = matrices[13];
        if (matrices.length > 14) effect.metaballData14 = matrices[14];
        if (matrices.length > 15) effect.metaballData15 = matrices[15];
        if (matrices.length > 16) effect.metaballData16 = matrices[16];
        if (matrices.length > 17) effect.metaballData17 = matrices[17];
    }

    // --- Shader effect ---
    // CRITICAL: Property order must exactly match the std140 uniform block in lava-lamp.frag
    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: status !== ShaderEffect.Error

        property real iTime: 0

        // --- Uniforms matching GLSL std140 layout ---
        property size resolution: Qt.size(width, height)
        property real threshold: effectRoot.metaballThreshold
        property vector3d baseColor: Qt.vector3d(1.0, 1.0, 1.0)

        property vector3d gradientColor1: Qt.vector3d(1.0, 0.42, 0.0)
        Behavior on gradientColor1 { Vector3dAnimation { duration: effectRoot.transitionMs } }
        property vector3d gradientColor2: Qt.vector3d(1.0, 0.0, 0.0)
        Behavior on gradientColor2 { Vector3dAnimation { duration: effectRoot.transitionMs } }
        property vector3d gradientColor3: Qt.vector3d(1.0, 0.42, 0.0)
        Behavior on gradientColor3 { Vector3dAnimation { duration: effectRoot.transitionMs } }
        property vector3d gradientColor4: Qt.vector3d(1.0, 0.0, 0.0)
        Behavior on gradientColor4 { Vector3dAnimation { duration: effectRoot.transitionMs } }

        property vector3d backgroundGradientColor1: Qt.vector3d(0.22, 0.11, 0.055)
        Behavior on backgroundGradientColor1 { Vector3dAnimation { duration: effectRoot.transitionMs } }
        property vector3d backgroundGradientColor2: Qt.vector3d(0.11, 0.055, 0.027)
        Behavior on backgroundGradientColor2 { Vector3dAnimation { duration: effectRoot.transitionMs } }
        property vector3d backgroundGradientColor3: Qt.vector3d(0.22, 0.11, 0.055)
        Behavior on backgroundGradientColor3 { Vector3dAnimation { duration: effectRoot.transitionMs } }
        property vector3d backgroundGradientColor4: Qt.vector3d(0.11, 0.055, 0.027)
        Behavior on backgroundGradientColor4 { Vector3dAnimation { duration: effectRoot.transitionMs } }

        property real glowIntensity: 3.0
        Behavior on glowIntensity { NumberAnimation { duration: effectRoot.transitionMs } }
        property real glowInnerThreshold: 0.7
        Behavior on glowInnerThreshold { NumberAnimation { duration: effectRoot.transitionMs } }
        property real glowMidThreshold: 0.3
        Behavior on glowMidThreshold { NumberAnimation { duration: effectRoot.transitionMs } }
        property real glowOuterThreshold: 0.05
        Behavior on glowOuterThreshold { NumberAnimation { duration: effectRoot.transitionMs } }
        property real glowMinFieldStrength: 0.005
        Behavior on glowMinFieldStrength { NumberAnimation { duration: effectRoot.transitionMs } }

        property int gradientMode: 0
        property int backgroundGradientEnabled: 1
        property int glowEffectEnabled: 1
        property int metaballCount: effectRoot.orbCount

        // CPU-computed metaball position matrices (4 metaballs packed per mat4)
        property matrix4x4 metaballData0:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData1:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData2:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData3:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData4:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData5:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData6:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData7:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData8:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData9:  Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData10: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData11: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData12: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData13: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData14: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData15: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData16: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
        property matrix4x4 metaballData17: Qt.matrix4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)

        property real speedMult: effectRoot.speedMult

        FrameAnimation {
            running: effect.visible && !effectRoot.fpsCap
            onTriggered: {
                effect.iTime += frameTime * 60.0 * effect.speedMult;
                effectRoot.updateMetaballs();
            }
        }

        Timer {
            running: effect.visible && effectRoot.fpsCap
            repeat: true
            interval: Math.ceil(1000 / Math.min(240, Math.max(1, effectRoot.fpsLimit)))
            onTriggered: {
                effect.iTime += interval / 1000.0 * 60.0 * effect.speedMult;
                effectRoot.updateMetaballs();
            }
        }

        vertexShader: "shaders/lava-lamp.vert.qsb"
        fragmentShader: "shaders/lava-lamp.frag.qsb"
    }
}
