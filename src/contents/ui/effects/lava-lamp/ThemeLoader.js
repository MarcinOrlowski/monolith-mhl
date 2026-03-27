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

    // Gradient mode
    var validModes = ["vertical", "corners", "rainbow"];
    if (typeof obj.gradientMode !== "string" || validModes.indexOf(obj.gradientMode) === -1)
        return "gradientMode must be one of: vertical, corners, rainbow";

    // Gradient colors (4 hex colors)
    if (!Array.isArray(obj.gradientColors) || obj.gradientColors.length !== 4)
        return "gradientColors must be an array of 4 colors";
    for (var i = 0; i < 4; i++) {
        if (!parseHexColor(obj.gradientColors[i]))
            return "gradientColors[" + i + "] is not a valid #RRGGBB color";
    }

    // Background colors (4 hex colors)
    if (!Array.isArray(obj.backgroundColors) || obj.backgroundColors.length !== 4)
        return "backgroundColors must be an array of 4 colors";
    for (var j = 0; j < 4; j++) {
        if (!parseHexColor(obj.backgroundColors[j]))
            return "backgroundColors[" + j + "] is not a valid #RRGGBB color";
    }

    // Glow parameters (optional — defaults applied in applyTheme)
    if (obj.glowIntensity !== undefined && typeof obj.glowIntensity !== "number")
        return "glowIntensity must be a number";

    return null; // valid
}

// Map gradient mode string to shader int
function gradientModeToInt(mode) {
    switch (mode) {
        case "vertical": return 0;
        case "corners":  return 1;
        case "rainbow":  return 2;
        default:         return 0;
    }
}

// Convert hex color string to Qt.vector3d for shader uniforms
function hexToVector3d(hex) {
    var rgb = parseHexColor(hex);
    if (!rgb) return Qt.vector3d(0, 0, 0);
    return Qt.vector3d(rgb[0], rgb[1], rgb[2]);
}

// Apply a loaded theme object to a ShaderEffect target
function applyTheme(obj, target) {
    // Gradient colors
    target.gradientColor1 = hexToVector3d(obj.gradientColors[0]);
    target.gradientColor2 = hexToVector3d(obj.gradientColors[1]);
    target.gradientColor3 = hexToVector3d(obj.gradientColors[2]);
    target.gradientColor4 = hexToVector3d(obj.gradientColors[3]);

    // Background gradient colors
    target.backgroundGradientColor1 = hexToVector3d(obj.backgroundColors[0]);
    target.backgroundGradientColor2 = hexToVector3d(obj.backgroundColors[1]);
    target.backgroundGradientColor3 = hexToVector3d(obj.backgroundColors[2]);
    target.backgroundGradientColor4 = hexToVector3d(obj.backgroundColors[3]);

    // Gradient mode
    target.gradientMode = gradientModeToInt(obj.gradientMode);

    // Background gradient toggle
    var bgEnabled = (obj.backgroundGradientEnabled !== undefined) ? obj.backgroundGradientEnabled : true;
    target.backgroundGradientEnabled = bgEnabled ? 1 : 0;

    // Glow parameters
    var glowEnabled = (obj.glowEnabled !== undefined) ? obj.glowEnabled : true;
    target.glowEffectEnabled = glowEnabled ? 1 : 0;
    target.glowIntensity = (obj.glowIntensity !== undefined) ? obj.glowIntensity : 3.0;
    target.glowInnerThreshold = (obj.glowInnerThreshold !== undefined) ? obj.glowInnerThreshold : 0.7;
    target.glowMidThreshold = (obj.glowMidThreshold !== undefined) ? obj.glowMidThreshold : 0.3;
    target.glowOuterThreshold = (obj.glowOuterThreshold !== undefined) ? obj.glowOuterThreshold : 0.05;
    target.glowMinFieldStrength = (obj.glowMinFieldStrength !== undefined) ? obj.glowMinFieldStrength : 0.005;
}
