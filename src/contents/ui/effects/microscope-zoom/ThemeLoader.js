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
    if (typeof str !== "string" || str.length !== 7 || str.charAt(0) !== '#') {
        return null;
    }
    var hex = str.substring(1);
    var r = parseInt(hex.substring(0, 2), 16);
    var g = parseInt(hex.substring(2, 4), 16);
    var b = parseInt(hex.substring(4, 6), 16);
    if (isNaN(r) || isNaN(g) || isNaN(b)) {
        return null;
    }
    return [r / 255.0, g / 255.0, b / 255.0];
}

// Validate a theme object loaded from a QML component.
// A Microscope Zoom theme defines three colors: the specimen (cell), the
// background medium, and the backlight illumination.
function validateTheme(obj) {
    if (!obj.themeId || typeof obj.themeId !== "string") {
        return "missing or invalid themeId";
    }
    if (!/^[a-z0-9-]+$/.test(obj.themeId)) {
        return "themeId contains invalid characters (only a-z, 0-9, - allowed)";
    }
    if (!obj.name || typeof obj.name !== "string") {
        return "missing or invalid name";
    }
    var colorFields = ["cellColor", "mediumColor", "illumColor"];
    for (var i = 0; i < colorFields.length; i++) {
        var cf = colorFields[i];
        if (typeof obj[cf] !== "string" || !parseHexColor(obj[cf])) {
            return cf + " must be a valid #RRGGBB color";
        }
    }
    return null; // valid
}

// Apply a loaded theme object to a ShaderEffect target. Colors map to the
// shader's cell/medium/illum uniform triples; the ShaderEffect animates each
// component via a Behavior, so writes here cross-fade smoothly.
function applyTheme(obj, target) {
    var cell = parseHexColor(obj.cellColor);
    var medium = parseHexColor(obj.mediumColor);
    var illum = parseHexColor(obj.illumColor);

    target.cellColorR = cell[0];   target.cellColorG = cell[1];   target.cellColorB = cell[2];
    target.mediumColorR = medium[0]; target.mediumColorG = medium[1]; target.mediumColorB = medium[2];
    target.illumColorR = illum[0]; target.illumColorG = illum[1]; target.illumColorB = illum[2];
}
