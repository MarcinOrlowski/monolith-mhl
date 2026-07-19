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
    property string themeId: "ttm-charcoal"
    property string name: "Charcoal"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "dark"

    property string canopy: "#0c0f10"
    property string glow: "#5a6466"
    property string mist: "#1a2022"
    property string stars: "#cfd8da"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#243034", "#2f3d40", "#3a4a4c", "#455658", "#22363a", "#30464a"]
}
