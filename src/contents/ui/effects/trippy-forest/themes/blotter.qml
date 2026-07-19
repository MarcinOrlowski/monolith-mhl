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
    property string themeId: "tfm-blotter"
    property string name: "Blotter"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string foliage: "#14061e"
    property string glow: "#ffee00"
    property string mist: "#3a2a55"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#ff0040", "#ff8c00", "#ffee00", "#00e05a", "#00a0ff", "#a000ff"]
}
