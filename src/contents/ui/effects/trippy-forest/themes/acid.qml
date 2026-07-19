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
    property string themeId: "tfm-acid"
    property string name: "Acid Trip"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string foliage: "#10240a"
    property string glow: "#ccff00"
    property string mist: "#2a5a3a"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#39ff14", "#ccff00", "#ff00ff", "#00ffff", "#ffea00", "#ff2079"]
}
