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
    property string themeId: "tfm-jungle"
    property string name: "Jungle"
    property bool enabled: true

    // Tone group for the light/dark/mixed cycle filter.
    property string mode: "dark"

    property string foliage: "#0a2a14"
    property string glow: "#8fc04f"
    property string mist: "#26543a"
    property string stars: "#d8ffa0"

    // 6-stop palette wrapped around the tunnel (drives the trippy colour flow)
    property var palette: ["#2f6b28", "#4f8a2a", "#6fae3a", "#3c7d4e", "#255f3a", "#8fc04f"]
}
