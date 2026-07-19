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
    property string themeId: "ttm-oil-slick"
    property string name: "Oil Slick"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string canopy: "#06121a"
    property string glow: "#23e0b0"
    property string mist: "#1e2a4a"
    property string stars: "#eafffb"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#00d2c6", "#6a4bff", "#ff3ea5", "#2f8fff", "#a24bff", "#23e0b0"]
}
