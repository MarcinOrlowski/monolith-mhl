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
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "filters/FilterRegistry.js" as FilterRegistry

WallpaperItem {
    id: root

    // Forward the active effect's context menu actions
    contextualActions: effectLoader.item ? effectLoader.item.effectActions : []

    // --- Filter config components (self-contained, loaded from FilterRegistry) ---
    property var filterConfigs: ({})

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
                    item.settingsBlob = Qt.binding(function() { return root.configuration[entry.cfgKey] || "{}" })
                    var m = root.filterConfigs; m[entry.id] = item; root.filterConfigs = m
                }
            }
        }
    }

    function filterConfig(fid) { return filterConfigs[fid] || null }

    // --- Shader uniform values (copied from filter configs by syncFilterConfig) ---
    property real showScanlines: 0.0
    property real scanlineIntensity: 0.0
    property real scanlineFrequency: 1.0
    property real scanlineThickness: 1.0
    property real scanlineSpeed: 0.0
    property real scanlineColorR: 0.0
    property real scanlineColorG: 0.0
    property real scanlineColorB: 0.0
    property real scanlineOpacity: 0.0
    property real showChromatic: 0.0
    property real chromaticStrength: 0.0
    property real showColorGrading: 0.0
    property real cgGamma: 1.0
    property real cgContrast: 1.0
    property real cgTemperature: 0.0
    property real cgTint: 0.0
    property real showHueShift: 0.0
    property real hueShiftAngle: 180.0
    property real showPixelate: 0.0
    property real pixelateSize: 8.0
    property real showCrt: 0.0
    property real crtCurvature: 10.0
    property real crtVignette: 30.0
    property real rgbOffsetAmount: 5.0
    property real rgbOffsetAngle: 0.0
    property real blurRadius: 8.0

    property bool anyFilterActive: false

    // --- Pipeline stage configuration (computed by syncFilterConfig) ---
    // Up to 5 stages: combinedA → resample1 → combinedB → resample2 → combinedC
    property bool stageAActive: false
    property real slotA0: 99; property real slotA1: 99; property real slotA2: 99
    property real slotA3: 99; property real slotA4: 99; property real slotA5: 99; property real slotA6: 99

    property bool resample1Active: false
    property bool resample1IsBlur: true

    property bool stageBActive: false
    property real slotB0: 99; property real slotB1: 99; property real slotB2: 99
    property real slotB3: 99; property real slotB4: 99; property real slotB5: 99; property real slotB6: 99

    property bool resample2Active: false
    property bool resample2IsBlur: true

    property bool stageCActive: false
    property real slotC0: 99; property real slotC1: 99; property real slotC2: 99
    property real slotC3: 99; property real slotC4: 99; property real slotC5: 99; property real slotC6: 99

    property string finalStageId: ""

    function syncFilterConfig() {
        // Copy shader-ready uniform values from self-contained filter configs
        var active = false
        for (var i = 0; i < FilterRegistry.filters.length; i++) {
            var fc = filterConfig(FilterRegistry.filters[i].id)
            if (!fc) continue
            if (fc.show) active = true
            var u = fc.uniforms
            for (var key in u) {
                if (root.hasOwnProperty(key)) root[key] = u[key]
            }
        }
        anyFilterActive = active

        // Build pipeline: split filter order at pass-breaking filters
        var order = (root.configuration.FilterOrder || "pixelate,scanlines,chromatic,color-grading,hue-shift,rgb-offset,crt,blur").split(",")
        var segments = []
        var currentGroup = []

        for (var i = 0; i < order.length; i++) {
            var fid = order[i].trim()
            var ffc = filterConfig(fid)
            if (!ffc) continue
            if (ffc.isPassBreaker && ffc.show) {
                if (currentGroup.length > 0) {
                    segments.push({ type: "combined", slots: currentGroup.slice() })
                    currentGroup = []
                }
                segments.push({ type: fid })
            } else if (!ffc.isPassBreaker && ffc.shaderIndex >= 0) {
                currentGroup.push(ffc.shaderIndex)
            }
        }
        if (currentGroup.length > 0) {
            segments.push({ type: "combined", slots: currentGroup.slice() })
        }

        // Reset all stages
        stageAActive = false; stageBActive = false; stageCActive = false
        resample1Active = false; resample2Active = false
        slotA0=99; slotA1=99; slotA2=99; slotA3=99; slotA4=99; slotA5=99; slotA6=99
        slotB0=99; slotB1=99; slotB2=99; slotB3=99; slotB4=99; slotB5=99; slotB6=99
        slotC0=99; slotC1=99; slotC2=99; slotC3=99; slotC4=99; slotC5=99; slotC6=99
        finalStageId = ""

        // Map segments to fixed pipeline stages: A, R1, B, R2, C
        var combinedIdx = 0, resampleIdx = 0

        for (var s = 0; s < segments.length; s++) {
            var seg = segments[s]
            if (seg.type === "combined" && combinedIdx < 3) {
                var prefix = ["A", "B", "C"][combinedIdx]
                root["stage" + prefix + "Active"] = true
                for (var j = 0; j < seg.slots.length && j < 7; j++) {
                    root["slot" + prefix + j] = seg.slots[j]
                }
                finalStageId = prefix
                combinedIdx++
            } else if (seg.type !== "combined" && resampleIdx < 2) {
                var rIdx = resampleIdx + 1
                root["resample" + rIdx + "Active"] = true
                root["resample" + rIdx + "IsBlur"] = (seg.type === "blur")
                finalStageId = "R" + rIdx
                resampleIdx++
            }
        }
    }

    // Effect registry: maps Effect config value to effect QML component
    readonly property var effectRegistry: ({
        "rainbow-waves": Qt.resolvedUrl("effects/rainbow-waves/RainbowWavesEffect.qml")
    })

    Loader {
        id: effectLoader
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: effectSource
        sourceItem: effectLoader
        live: root.anyFilterActive
        hideSource: root.anyFilterActive
        visible: false
    }

    // Shared animation timer for all filter passes
    property real filterTime: 0
    FrameAnimation {
        running: root.anyFilterActive
        onTriggered: root.filterTime += frameTime * 60.0
    }

    // ====== Pipeline stage A: Combined filters (before first resample) ======
    ShaderEffect {
        id: combinedA
        anchors.fill: parent
        visible: root.anyFilterActive && root.stageAActive && root.finalStageId === "A" && effectLoader.status === Loader.Ready

        property var source: effectSource
        property real iTime: root.filterTime
        property real iWidth: width; property real iHeight: height
        property real showScanlines: root.showScanlines
        property real scanlineIntensity: root.scanlineIntensity
        property real scanlineFrequency: root.scanlineFrequency
        property real scanlineThickness: root.scanlineThickness
        property real scanlineSpeed: root.scanlineSpeed
        property real scanlineColorR: root.scanlineColorR
        property real scanlineColorG: root.scanlineColorG
        property real scanlineColorB: root.scanlineColorB
        property real scanlineOpacity: root.scanlineOpacity
        property real showChromatic: root.showChromatic
        property real chromaticStrength: root.chromaticStrength
        property real showColorGrading: root.showColorGrading
        property real cgGamma: root.cgGamma; property real cgContrast: root.cgContrast
        property real cgTemperature: root.cgTemperature; property real cgTint: root.cgTint
        property real showHueShift: root.showHueShift
        property real hueShiftAngle: root.hueShiftAngle
        property real showPixelate: root.showPixelate
        property real pixelateSize: root.pixelateSize
        property real showRgbOffset: 0.0; property real rgbOffsetAmount: 0; property real rgbOffsetAngle: 0
        property real showCrt: root.showCrt
        property real crtCurvature: root.crtCurvature; property real crtVignette: root.crtVignette
        property real filterSlot0: root.slotA0; property real filterSlot1: root.slotA1
        property real filterSlot2: root.slotA2; property real filterSlot3: root.slotA3
        property real filterSlot4: root.slotA4; property real filterSlot5: root.slotA5
        property real filterSlot6: root.slotA6
        vertexShader: "filters/shaders/postfilter.vert.qsb"
        fragmentShader: "filters/shaders/postfilter.frag.qsb"
    }
    ShaderEffectSource {
        id: combinedAOut
        sourceItem: combinedA
        live: root.stageAActive && root.finalStageId !== "A"
        hideSource: live; visible: false
    }

    // ====== Pipeline stage R1: First resample (blur or rgboffset) ======
    ShaderEffect {
        id: blurAt1
        anchors.fill: parent
        visible: root.anyFilterActive && root.resample1Active && root.resample1IsBlur && root.finalStageId === "R1" && effectLoader.status === Loader.Ready
        property var source: root.stageAActive ? combinedAOut : effectSource
        property real iWidth: width; property real iHeight: height
        property real blurRadius: root.blurRadius
        vertexShader: "filters/shaders/blur.vert.qsb"
        fragmentShader: "filters/shaders/blur.frag.qsb"
    }
    ShaderEffect {
        id: rgbAt1
        anchors.fill: parent
        visible: root.anyFilterActive && root.resample1Active && !root.resample1IsBlur && root.finalStageId === "R1" && effectLoader.status === Loader.Ready
        property var source: root.stageAActive ? combinedAOut : effectSource
        property real iWidth: width; property real iHeight: height
        property real rgbOffsetAmount: root.rgbOffsetAmount
        property real rgbOffsetAngle: root.rgbOffsetAngle
        vertexShader: "filters/shaders/rgboffset.vert.qsb"
        fragmentShader: "filters/shaders/rgboffset.frag.qsb"
    }
    ShaderEffectSource {
        id: blur1Out
        sourceItem: blurAt1
        live: root.resample1Active && root.resample1IsBlur && root.finalStageId !== "R1"
        hideSource: live; visible: false
    }
    ShaderEffectSource {
        id: rgb1Out
        sourceItem: rgbAt1
        live: root.resample1Active && !root.resample1IsBlur && root.finalStageId !== "R1"
        hideSource: live; visible: false
    }

    // ====== Pipeline stage B: Combined filters (between resamples) ======
    ShaderEffect {
        id: combinedB
        anchors.fill: parent
        visible: root.anyFilterActive && root.stageBActive && root.finalStageId === "B" && effectLoader.status === Loader.Ready

        property var source: root.resample1IsBlur ? blur1Out : rgb1Out
        property real iTime: root.filterTime
        property real iWidth: width; property real iHeight: height
        property real showScanlines: root.showScanlines
        property real scanlineIntensity: root.scanlineIntensity
        property real scanlineFrequency: root.scanlineFrequency
        property real scanlineThickness: root.scanlineThickness
        property real scanlineSpeed: root.scanlineSpeed
        property real scanlineColorR: root.scanlineColorR
        property real scanlineColorG: root.scanlineColorG
        property real scanlineColorB: root.scanlineColorB
        property real scanlineOpacity: root.scanlineOpacity
        property real showChromatic: root.showChromatic
        property real chromaticStrength: root.chromaticStrength
        property real showColorGrading: root.showColorGrading
        property real cgGamma: root.cgGamma; property real cgContrast: root.cgContrast
        property real cgTemperature: root.cgTemperature; property real cgTint: root.cgTint
        property real showHueShift: root.showHueShift
        property real hueShiftAngle: root.hueShiftAngle
        property real showPixelate: root.showPixelate
        property real pixelateSize: root.pixelateSize
        property real showRgbOffset: 0.0; property real rgbOffsetAmount: 0; property real rgbOffsetAngle: 0
        property real showCrt: root.showCrt
        property real crtCurvature: root.crtCurvature; property real crtVignette: root.crtVignette
        property real filterSlot0: root.slotB0; property real filterSlot1: root.slotB1
        property real filterSlot2: root.slotB2; property real filterSlot3: root.slotB3
        property real filterSlot4: root.slotB4; property real filterSlot5: root.slotB5
        property real filterSlot6: root.slotB6
        vertexShader: "filters/shaders/postfilter.vert.qsb"
        fragmentShader: "filters/shaders/postfilter.frag.qsb"
    }
    ShaderEffectSource {
        id: combinedBOut
        sourceItem: combinedB
        live: root.stageBActive && root.finalStageId !== "B"
        hideSource: live; visible: false
    }

    // ====== Pipeline stage R2: Second resample (blur or rgboffset) ======
    ShaderEffect {
        id: blurAt2
        anchors.fill: parent
        visible: root.anyFilterActive && root.resample2Active && root.resample2IsBlur && root.finalStageId === "R2" && effectLoader.status === Loader.Ready
        property var source: root.stageBActive ? combinedBOut : (root.resample1IsBlur ? blur1Out : rgb1Out)
        property real iWidth: width; property real iHeight: height
        property real blurRadius: root.blurRadius
        vertexShader: "filters/shaders/blur.vert.qsb"
        fragmentShader: "filters/shaders/blur.frag.qsb"
    }
    ShaderEffect {
        id: rgbAt2
        anchors.fill: parent
        visible: root.anyFilterActive && root.resample2Active && !root.resample2IsBlur && root.finalStageId === "R2" && effectLoader.status === Loader.Ready
        property var source: root.stageBActive ? combinedBOut : (root.resample1IsBlur ? blur1Out : rgb1Out)
        property real iWidth: width; property real iHeight: height
        property real rgbOffsetAmount: root.rgbOffsetAmount
        property real rgbOffsetAngle: root.rgbOffsetAngle
        vertexShader: "filters/shaders/rgboffset.vert.qsb"
        fragmentShader: "filters/shaders/rgboffset.frag.qsb"
    }
    ShaderEffectSource {
        id: blur2Out
        sourceItem: blurAt2
        live: root.resample2Active && root.resample2IsBlur && root.finalStageId !== "R2"
        hideSource: live; visible: false
    }
    ShaderEffectSource {
        id: rgb2Out
        sourceItem: rgbAt2
        live: root.resample2Active && !root.resample2IsBlur && root.finalStageId !== "R2"
        hideSource: live; visible: false
    }

    // ====== Pipeline stage C: Combined filters (after last resample) ======
    ShaderEffect {
        id: combinedC
        anchors.fill: parent
        visible: root.anyFilterActive && root.stageCActive && root.finalStageId === "C" && effectLoader.status === Loader.Ready

        property var source: root.resample2IsBlur ? blur2Out : rgb2Out
        property real iTime: root.filterTime
        property real iWidth: width; property real iHeight: height
        property real showScanlines: root.showScanlines
        property real scanlineIntensity: root.scanlineIntensity
        property real scanlineFrequency: root.scanlineFrequency
        property real scanlineThickness: root.scanlineThickness
        property real scanlineSpeed: root.scanlineSpeed
        property real scanlineColorR: root.scanlineColorR
        property real scanlineColorG: root.scanlineColorG
        property real scanlineColorB: root.scanlineColorB
        property real scanlineOpacity: root.scanlineOpacity
        property real showChromatic: root.showChromatic
        property real chromaticStrength: root.chromaticStrength
        property real showColorGrading: root.showColorGrading
        property real cgGamma: root.cgGamma; property real cgContrast: root.cgContrast
        property real cgTemperature: root.cgTemperature; property real cgTint: root.cgTint
        property real showHueShift: root.showHueShift
        property real hueShiftAngle: root.hueShiftAngle
        property real showPixelate: root.showPixelate
        property real pixelateSize: root.pixelateSize
        property real showRgbOffset: 0.0; property real rgbOffsetAmount: 0; property real rgbOffsetAngle: 0
        property real showCrt: root.showCrt
        property real crtCurvature: root.crtCurvature; property real crtVignette: root.crtVignette
        property real filterSlot0: root.slotC0; property real filterSlot1: root.slotC1
        property real filterSlot2: root.slotC2; property real filterSlot3: root.slotC3
        property real filterSlot4: root.slotC4; property real filterSlot5: root.slotC5
        property real filterSlot6: root.slotC6
        vertexShader: "filters/shaders/postfilter.vert.qsb"
        fragmentShader: "filters/shaders/postfilter.frag.qsb"
    }

    function loadEffect() {
        var url = root.effectRegistry[root.configuration.ActiveEffect] || ""
        if (url.toString().length > 0) {
            effectLoader.setSource(url, { "configuration": root.configuration })
        }
    }

    Connections {
        target: root.configuration
        function onActiveEffectChanged() { root.loadEffect() }
        function onValueChanged(key, value) { root.syncFilterConfig() }
    }
    Component.onCompleted: { syncFilterConfig(); loadEffect() }

    Rectangle {
        anchors.fill: parent
        visible: effectLoader.status === Loader.Error
                 || (effectLoader.item && effectLoader.item.hasError)
        color: "#1a1a2e"

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width * 0.8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "⛔ " + (effectLoader.item ? effectLoader.item.effectName : "Wallpaper") + " ⛔"
                font.pixelSize: 42
                font.bold: true
                color: "#e0e0e0"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: "The shader for this wallpaper failed to load or compile.\n"
                      + "This may be due to limited GPU/driver support for Vulkan/OpenGL, or missing/corrupt shader files.\n\n"
                      + "For troubleshooting and requirements, see:\nhttps://github.com/MarcinOrlowski/monolith-mhl"
                font.pixelSize: 28
                color: "#a0a0a0"
                lineHeight: 1.4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: "Shader error log:\n" + (effectLoader.item ? effectLoader.item.errorLog : "")
                font.pixelSize: 20
                color: "#808080"
                visible: effectLoader.item && effectLoader.item.errorLog.length > 0
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: "Loader error:\n" + effectLoader.sourceComponent
                font.pixelSize: 20
                color: "#808080"
                visible: effectLoader.status === Loader.Error
            }
        }
    }

}
