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

QtObject {
    property string themeId: "ttm-ultraviolet"
    property string name: "Ultraviolet"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string canopy: "#0e061f"
    property string glow: "#d264ff"
    property string mist: "#2e1a5a"
    property string stars: "#f0e0ff"
    property string bloom: "#d264ff"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#7b2ff7", "#a24bff", "#d264ff", "#4b2fff", "#ff5edf", "#2fb0ff"]
}
