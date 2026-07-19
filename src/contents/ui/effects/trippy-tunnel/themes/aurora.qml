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
    property string themeId: "ttm-aurora"
    property string name: "Aurora"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "mixed"

    property string canopy: "#08201a"
    property string glow: "#4fd0a0"
    property string mist: "#245a4a"
    property string stars: "#d8fff0"
    property string bloom: "#eafff0"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#1fd77a", "#2ee6c8", "#33b0ff", "#a45cff", "#ff6ad5", "#5affb0"]
}
