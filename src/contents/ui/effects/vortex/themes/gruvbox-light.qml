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
    property string themeId: "ttm-gruvbox-light"
    property string name: "Gruvbox Light"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "light"

    property string canopy: "#7c6f64"
    property string glow: "#b57614"
    property string mist: "#d5c4a1"
    property string stars: "#fbf1c7"
    property string bloom: "#fbf1c7"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#9d0006", "#af3a03", "#b57614", "#79740e", "#427b58", "#8f3f71"]
}
