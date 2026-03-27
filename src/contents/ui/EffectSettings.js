/***********************************************************************
 *
 * Monolith MHL: Beautiful animated wallpapers for Plasma 6
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright ©2026 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/monolith-mhl
 *
 * Shared helper for effect settings stored as JSON blobs.
 * Each effect stores all its settings as a single JSON string in the
 * wallpaper configuration. This module handles parse/serialize with
 * default value fallback.
 *
 **********************************************************************/

/**
 * Parse a JSON settings string, filling in missing keys from defaults.
 *
 * @param {string} jsonString  Raw JSON from configuration (may be "" or "{}")
 * @param {object} defaults    Schema object: { key: defaultValue, ... }
 * @returns {object}           Settings object with all keys populated
 */
function load(jsonString, defaults) {
    var obj = {};
    try {
        obj = JSON.parse(jsonString || "{}");
    } catch (e) {
        console.warn("EffectSettings: failed to parse:", e);
    }
    var result = {};
    for (var key in defaults) {
        result[key] = (obj[key] !== undefined) ? obj[key] : defaults[key];
    }
    return result;
}

/**
 * Serialize a settings object to a JSON string.
 *
 * @param {object} values  Settings object to serialize
 * @returns {string}       JSON string for storage in configuration
 */
function save(values) {
    return JSON.stringify(values);
}
