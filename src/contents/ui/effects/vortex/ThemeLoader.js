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
    if (obj.mode !== undefined && ["light", "dark", "mixed", "psychedelic"].indexOf(obj.mode) === -1)
        return "mode must be one of: light, dark, mixed, psychedelic";

    var singles = ["canopy", "glow", "mist"];
    for (var s = 0; s < singles.length; s++) {
        if (typeof obj[singles[s]] !== "string" || !parseHexColor(obj[singles[s]]))
            return singles[s] + " must be a valid #RRGGBB color";
    }
    if (obj.stars !== undefined && !parseHexColor(obj.stars))
        return "stars must be a valid #RRGGBB color";
    if (obj.bloom !== undefined && !parseHexColor(obj.bloom))
        return "bloom must be a valid #RRGGBB color";

    if (!Array.isArray(obj.palette) || obj.palette.length !== 6)
        return "palette must be an array of 6 colors";
    for (var i = 0; i < 6; i++) {
        if (!parseHexColor(obj.palette[i]))
            return "palette[" + i + "] is not a valid #RRGGBB color";
    }
    return null; // valid
}

// Apply a loaded theme object to a ShaderEffect target (colours only — layer
// visibility is controlled by the user settings, not the theme).
function applyTheme(obj, target) {
    target["canopyCol"] = obj.canopy;
    target["glowCol"] = obj.glow;
    target["mistCol"] = obj.mist;
    target["starsCol"] = (obj.stars !== undefined) ? obj.stars : "#ffffff";
    target["bloomColor"] = (obj.bloom !== undefined) ? obj.bloom : "#ffffff";
    for (var i = 0; i < 6; i++)
        target["pal" + i] = obj.palette[i];
}
