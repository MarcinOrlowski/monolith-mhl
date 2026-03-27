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

// Filter registry: maps filter ID to config component path and KDE config key.
// All other metadata (name, defaults, shader index, etc.) lives inside each config component.
var filters = [
    { id: "pixelate",     configUrl: "pixelate/PixelateConfig.qml",         cfgKey: "FilterPixelateSettings" },
    { id: "scanlines",    configUrl: "scanlines/ScanlinesConfig.qml",       cfgKey: "FilterScanlinesSettings" },
    { id: "chromatic",    configUrl: "chromatic/ChromaticConfig.qml",       cfgKey: "FilterChromaticSettings" },
    { id: "color-grading", configUrl: "color-grading/ColorGradingConfig.qml", cfgKey: "FilterColorGradingSettings" },
    { id: "hue-shift",    configUrl: "hue-shift/HueShiftConfig.qml",       cfgKey: "FilterHueShiftSettings" },
    { id: "rgb-offset",   configUrl: "rgb-offset/RgbOffsetConfig.qml",     cfgKey: "FilterRgbOffsetSettings" },
    { id: "crt",          configUrl: "crt/CrtConfig.qml",                  cfgKey: "FilterCrtSettings" },
    { id: "blur",         configUrl: "blur/BlurConfig.qml",                cfgKey: "FilterBlurSettings" }
]
