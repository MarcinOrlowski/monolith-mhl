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
    property string themeId: "tfm-toxic"
    property string name: "Toxic"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string canopy: "#0e1a06"
    property string glow: "#aaff00"
    property string mist: "#1e4a2a"
    property string stars: "#eaffb0"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#aaff00", "#66ff33", "#ccff33", "#00ff88", "#eaff00", "#39ff88"]
}
