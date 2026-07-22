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
    property string themeId: "ttm-kaleidoscope"
    property string name: "Kaleidoscope"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string canopy: "#12081c"
    property string glow: "#ffe600"
    property string mist: "#2a4a58"
    property string stars: "#ffffff"
    property string bloom: "#ffffff"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#ff1e56", "#ff9f1c", "#ffe600", "#2ec4b6", "#3d5aff", "#b14aed"]
}
