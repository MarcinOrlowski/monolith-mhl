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

// Parse "#RRGGBB" hex string into [r, g, b] floats in [0.0, 1.0]
function parseHexColor(str) {
    if (typeof str !== "string" || str.length !== 7 || str.charAt(0) !== '#')
        return null;
    var hex = str.substring(1);
    var r = parseInt(hex.substring(0, 2), 16);
    var g = parseInt(hex.substring(2, 4), 16);
    var b = parseInt(hex.substring(4, 6), 16);
    if (isNaN(r) || isNaN(g) || isNaN(b))
        return null;
    return [r / 255.0, g / 255.0, b / 255.0];
}

// Validate a theme object loaded from a QML component
function validateTheme(obj) {
    if (!obj.themeId || typeof obj.themeId !== "string")
        return "missing or invalid themeId";
    if (!/^[a-z0-9-]+$/.test(obj.themeId))
        return "themeId contains invalid characters (only a-z, 0-9, - allowed)";
    if (!obj.name || typeof obj.name !== "string")
        return "missing or invalid name";
    if (!Array.isArray(obj.background) || obj.background.length !== 5)
        return "background must be an array of 5 colors";
    if (typeof obj.effect !== "string" || !parseHexColor(obj.effect))
        return "effect must be a valid #RRGGBB color";
    if (!Array.isArray(obj.ghosts) || obj.ghosts.length !== 4)
        return "ghosts must be an array of 4 colors";
    if (!Array.isArray(obj.waveMain) || obj.waveMain.length !== 10)
        return "waveMain must be an array of 10 colors";
    if (!Array.isArray(obj.waveHighlight) || obj.waveHighlight.length !== 10)
        return "waveHighlight must be an array of 10 colors";
    if (typeof obj.glowCore !== "string" || !parseHexColor(obj.glowCore))
        return "glowCore must be a valid #RRGGBB color";
    if (typeof obj.spotColor !== "string" || !parseHexColor(obj.spotColor))
        return "spotColor must be a valid #RRGGBB color";
    if (typeof obj.starColor !== "string" || !parseHexColor(obj.starColor))
        return "starColor must be a valid #RRGGBB color";

    // Validate all color values
    var arrays = { background: 5, ghosts: 4, waveMain: 10, waveHighlight: 10 };
    var sections = Object.keys(arrays);
    for (var s = 0; s < sections.length; s++) {
        var sec = sections[s];
        for (var i = 0; i < arrays[sec]; i++) {
            if (!parseHexColor(obj[sec][i]))
                return sec + "[" + i + "] is not a valid #RRGGBB color";
        }
    }
    return null; // valid
}

// Apply a loaded theme object to a ShaderEffect target
function applyTheme(obj, target) {
    for (var i = 0; i < 5; i++)
        target["bg" + i] = obj.background[i];

    target["effectColor"] = obj.effect;

    for (var i = 0; i < 4; i++)
        target["ghost" + i] = obj.ghosts[i];

    for (var i = 0; i < 10; i++)
        target["wMain" + i] = obj.waveMain[i];

    for (var i = 0; i < 10; i++)
        target["wHl" + i] = obj.waveHighlight[i];

    target["glowCore"] = obj.glowCore;
    target["spotColor"] = obj.spotColor;
    target["starColor"] = obj.starColor;

    // Layer visibility (optional — default to visible when not specified)
    var layerKeys = ["showBackground", "showStars", "showGhosts", "showWaves",
                     "showGlow", "showHalo", "showShine", "showSpotlights"];
    for (var i = 0; i < layerKeys.length; i++) {
        var rawVal = obj[layerKeys[i]];
        var val = (rawVal === undefined) ? true : Boolean(rawVal);
        target[layerKeys[i]] = val ? 1.0 : 0.0;
    }
}
