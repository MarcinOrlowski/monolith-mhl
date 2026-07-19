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
    property string themeId: "tfm-candy"
    property string name: "Candy"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string foliage: "#201430"
    property string glow: "#ff5db1"
    property string mist: "#4a3a6a"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#ff5db1", "#ff9ec7", "#7afcff", "#b5ff7a", "#ffec5c", "#c08bff"]
}
