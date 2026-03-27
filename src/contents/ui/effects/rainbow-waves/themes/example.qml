/***********************************************************************
 *
 * Monolith MHL — Example theme template
 *
 * How to use:
 *   1. Copy this file to ~/.config/monolith/rainbow-waves/themes.d/
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
 *   - Array lengths must match exactly (see comments below)
 *
 * Reserved built-in theme IDs (do NOT reuse these):
 *   rwm-sunset, rwm-ocean, rwm-aurora, rwm-fire, rwm-dusk, rwm-abyss,
 *   rwm-ember, rwm-void, rwm-midnight-garden, rwm-coral-reef, rwm-nebula,
 *   rwm-arctic, rwm-forest, rwm-neon, rwm-cherry, rwm-copper, rwm-storm,
 *   rwm-lavender, rwm-moss
 *
 **********************************************************************/

import QtQuick

QtObject {
    // ── Identity ──────────────────────────────────────────────────────
    //
    // themeId: Unique identifier for this theme.
    //   - Only lowercase a-z, digits 0-9, and hyphens (-) are allowed
    //   - Must not match any built-in theme ID (see list above)
    //   - Used internally to store the user's theme selection
    //
    property string themeId: "my-custom-theme"

    // name: Human-readable display name shown in the wallpaper settings UI.
    //   - Can contain any characters (spaces, uppercase, etc.)
    //
    property string name: "My Custom Theme"

    // enabled: Set to true to activate this theme. Disabled themes are
    //   ignored by the scanner and will not appear in the settings UI.
    //   The built-in example.qml ships with enabled: false so it does
    //   not clutter the theme list. Set this to true in your own themes.
    //
    property bool enabled: false

    // ── Layer visibility ─────────────────────────────────────────────
    //
    // Optional booleans that control which visual layers are rendered.
    // When a theme is loaded, these values override the global layer
    // toggles in the wallpaper settings UI. The user can still change
    // them manually via the checkboxes after the theme is applied.
    //
    // All default to true (visible). Set any to false to hide that
    // layer by default when this theme is active. Omitted properties
    // are treated as true, so you only need to list the ones you want
    // to disable.
    //
    // property bool showBackground: true
    // property bool showStars: true
    // property bool showGhosts: true
    // property bool showWaves: true
    // property bool showGlow: true
    // property bool showHalo: true
    // property bool showShine: true
    // property bool showSpotlights: true

    // ── Background ────────────────────────────────────────────────────
    //
    // Exactly 5 colors forming a diagonal gradient across the screen:
    //   [0] top-left       (0%)
    //   [1] upper quarter  (0–25%)
    //   [2] center         (25–50%)
    //   [3] lower quarter  (50–75%)
    //   [4] bottom-right   (75–100%)
    //
    // Tip: use darker, muted colors — the background sits behind all
    // other layers and overly bright colors will wash out the waves.
    //
    property var background: [
        "#1A1A2E",
        "#16213E",
        "#0F3460",
        "#1A1A40",
        "#0E0E23"
    ]

    // ── Effect ────────────────────────────────────────────────────────
    //
    // A single accent color used for the glow, halo, and shine effects
    // that appear along the crests of the main waves.
    //
    // Tip: pick a bright, saturated color that contrasts with both
    // the background and wave colors for the best visual pop.
    //
    property string effect: "#FF6B6B"

    // ── Ghosts ────────────────────────────────────────────────────────
    //
    // Exactly 4 colors, one per translucent "ghost" wave layer that
    // drifts slowly behind the main waves. These are rendered with
    // low opacity so they create a subtle depth effect.
    //
    // Tip: use colors from the same family as your main waves but
    // slightly desaturated or shifted in hue.
    //
    property var ghosts: [
        "#4ECDC4",
        "#FF6B6B",
        "#C44DFF",
        "#45B7D1"
    ]

    // ── Wave main colors ──────────────────────────────────────────────
    //
    // Exactly 10 colors — the primary fill color for each of the 10
    // wave layers, ordered from back (index 0) to front (index 9).
    //
    // Back waves are partially occluded by front waves, so bolder or
    // darker colors work well for the first few entries while brighter
    // colors stand out better in the front positions.
    //
    property var waveMain: [
        "#2C3E50",
        "#3498DB",
        "#1ABC9C",
        "#9B59B6",
        "#E74C3C",
        "#F39C12",
        "#E67E22",
        "#2ECC71",
        "#8E44AD",
        "#2980B9"
    ]

    // ── Wave highlight colors ─────────────────────────────────────────
    //
    // Exactly 10 colors — the bright highlight blended at each wave's
    // crest edge. Each entry corresponds to the same-index wave in
    // waveMain above (i.e. waveHighlight[3] highlights waveMain[3]).
    //
    // Tip: use a lighter or more saturated version of the matching
    // waveMain color. High contrast between main and highlight makes
    // the wave edges more visible and lively.
    //
    property var waveHighlight: [
        "#5DADE2",
        "#85C1E9",
        "#76D7C4",
        "#C39BD3",
        "#F1948A",
        "#F9E79F",
        "#F0B27A",
        "#82E0AA",
        "#BB8FCE",
        "#7FB3D8"
    ]

    // ── Glow core ───────────────────────────────────────────────────
    //
    // The bright inner highlight at the crest of each wave's glow
    // effect, and the peak color of the shine band.
    //
    // Tip: white (#FFFFFF) gives a classic hot-core look. Tinting it
    // to match your effect color creates a more unified feel.
    //
    property string glowCore: "#FFFFFF"

    // ── Spotlight color ─────────────────────────────────────────────
    //
    // The color of the blinking bright patches (spotlights) that
    // appear along the wave crests.
    //
    // Tip: white (#FFFFFF) is the default. Use a warm or cool tint
    // to shift the mood of the spotlight flashes.
    //
    property string spotColor: "#FFFFFF"

    // ── Star color ──────────────────────────────────────────────────
    //
    // The color of the twinkling star particles in the upper portion
    // of the background.
    //
    // Tip: white (#FFFFFF) gives classic bright stars. A slight tint
    // can make stars feel warmer or cooler to match the scene.
    //
    property string starColor: "#FFFFFF"
}
