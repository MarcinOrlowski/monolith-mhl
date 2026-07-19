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
    property string themeId: "tfm-fever"
    property string name: "Fever Dream"
    property bool enabled: true

    // Tone group for the light/dark/mixed/psychedelic cycle filter.
    property string mode: "psychedelic"

    property string foliage: "#240806"
    property string glow: "#ffd000"
    property string mist: "#5a1e2a"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#ff2d00", "#ff5c00", "#ff008c", "#ff9a00", "#ffd000", "#ff3d7f"]
}
