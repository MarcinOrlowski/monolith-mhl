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
    property string themeId: "ttm-gruvbox-dark"
    property string name: "Gruvbox Dark"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "dark"

    property string canopy: "#1d2021"
    property string glow: "#d79921"
    property string mist: "#3c3836"
    property string stars: "#ebdbb2"
    property string bloom: "#fbf1c7"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#cc241d", "#d65d0e", "#d79921", "#98971a", "#689d6a", "#b16286"]
}
