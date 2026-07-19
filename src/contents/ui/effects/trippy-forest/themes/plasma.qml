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
    property string themeId: "tfm-plasma"
    property string name: "Plasma"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string foliage: "#0a0a24"
    property string glow: "#00f5d4"
    property string mist: "#2a2a5a"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#ff006e", "#8338ec", "#3a86ff", "#00f5d4", "#f15bb5", "#fee440"]
}
