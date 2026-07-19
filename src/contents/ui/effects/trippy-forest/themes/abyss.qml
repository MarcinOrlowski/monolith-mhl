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
    property string themeId: "tfm-abyss"
    property string name: "Abyss"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "dark"

    property string foliage: "#04121f"
    property string glow: "#2fb0a8"
    property string mist: "#123a4a"
    property string stars: "#bfffff"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#003b6f", "#0a6b8f", "#12a3a3", "#1ec8b0", "#0e5aa0", "#26e0d0"]
}
