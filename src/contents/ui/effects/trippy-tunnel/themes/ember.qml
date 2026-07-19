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
    property string themeId: "ttm-ember"
    property string name: "Ember"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "dark"

    property string canopy: "#2a0d06"
    property string glow: "#ff9a3a"
    property string mist: "#5a2410"
    property string stars: "#ffe0a0"
    property string bloom: "#fff0d0"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#ff2200", "#ff6a00", "#ffab00", "#ffd54a", "#ff4d1a", "#c81e00"]
}
