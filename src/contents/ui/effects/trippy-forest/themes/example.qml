/***********************************************************************
 *
 * Monolith MHL — Example Trippy Forest theme template
 *
 * How to use:
 *   1. Copy this file to ~/.config/monolith/trippy-forest/themes.d/
 *      (create the directory if it does not exist)
 *   2. Rename the copy to something like "my-theme.qml"
 *   3. Set enabled to true
 *   4. Edit themeId, name, and all colors to your liking
 *   5. Restart plasmashell:
 *        systemctl --user restart plasma-plasmashell.service
 *   6. Open wallpaper settings — your theme should appear in the list
 *
 * Rules:
 *   - The file extension MUST be .qml — other extensions are ignored
 *   - themeId must be unique and must NOT match any built-in theme ID
 *   - All colors must use #RRGGBB hex format (e.g. "#FF8800")
 *   - palette must contain exactly 6 colors
 *
 * Reserved built-in theme IDs (do NOT reuse these):
 *   tfm-spectrum, tfm-jungle, tfm-neon, tfm-ember, tfm-abyss, tfm-aurora,
 *   tfm-gruvbox-dark, tfm-gruvbox-light, tfm-charcoal, tfm-acid,
 *   tfm-vaporwave, tfm-blotter, tfm-plasma, tfm-kaleidoscope,
 *   tfm-ultraviolet, tfm-toxic, tfm-fever, tfm-oil-slick, tfm-candy
 *
 **********************************************************************/

import QtQuick

QtObject {
    // ── Identity ──────────────────────────────────────────────────────
    //
    // themeId: unique id, lowercase a-z / digits / hyphens only, must not
    //   clash with a built-in id (see list above).
    property string themeId: "my-custom-forest"

    // name: human-readable name shown in the settings UI.
    property string name: "My Custom Forest"

    // enabled: set to true to activate. The example ships disabled so it
    //   does not clutter the theme list.
    property bool enabled: false

    // mode: tone group for the cycle filter. Optional — defaults to "mixed"
    //   when omitted. One of: "light", "dark", "mixed", "psychedelic".
    property string mode: "mixed"

    // ── Canopy ───────────────────────────────────────────────────────
    //
    // Base colour of the dark leaf silhouettes closest to the camera.
    // Keep it dark — near canopy reads as a backlit silhouette.
    property string canopy: "#0e3d1e"

    // ── Glow ──────────────────────────────────────────────────────────
    //
    // Colour of the small emissive "mushroom / flower" spots dotted across
    // the canopy.
    property string glow: "#46f0c0"

    // ── Mist ──────────────────────────────────────────────────────────
    //
    // Colour of the misty light at the far end of the tunnel (the vortex
    // glow and the depth haze that distant rings dissolve into). Keep it
    // fairly dark — a near-white mist washes the scene out.
    property string mist: "#3a6a80"

    // ── Stars ─────────────────────────────────────────────────────────
    //
    // Colour of the 3D starfield points. Optional — defaults to white when
    // omitted. Bright / near-white values read best as stars.
    property string stars: "#ffffff"

    // ── Palette ───────────────────────────────────────────────────────
    //
    // Exactly 6 colours forming a smooth loop that is wrapped around the
    // tunnel and scrolled over time — this is what makes the scene "trippy".
    // A full spectrum gives a rainbow; a tight family of hues gives a
    // subtler, moodier look.
    property var palette: [
        "#ff2d55",
        "#ff9500",
        "#ffee33",
        "#34e56b",
        "#22c3ff",
        "#a45cff"
    ]
}
