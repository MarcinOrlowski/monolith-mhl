# Trippy Forest

An endless zoom into a psychedelic forest tunnel. Layered canopies of leaves
recede toward a glowing, swirling vortex at the centre while the camera flies
forward at a constant pace — no controls, it just keeps going. The whole tunnel
slowly rotates while the central whirl counter-rotates.

## Features

- Seamless infinite zoom: rings of leafy silhouettes grow and sweep past the
  frame while new ones **fade in** at the centre (no popping), so the flight
  never ends.

- Independent **tunnel rotation** and counter-rotating central **vortex**, each
  with its own signed speed (negative reverses the spin).

- Colour **themes** with the same auto-cycling and cross-fade machinery as the
  other effects: pick an initial theme (or Random), auto-cycle on a timer in
  sequential or random order, and cross-fade smoothly between them. 19 bundled
  themes grouped by tone — light, dark, mixed and psychedelic:

  - **Mixed/dark:** **Spectrum**, natural **Jungle**, **Neon**, **Ember**,
    **Abyss**, **Aurora**, **Gruvbox Dark**, **Gruvbox Light**, **Charcoal**.
  - **Psychedelic:** **Acid Trip**, **Vaporwave**, **Blotter**, **Plasma**,
    **Kaleidoscope**, **Ultraviolet**, **Toxic**, **Fever Dream**,
    **Oil Slick**, **Candy**.

  Restrict cycling to a single tone with the **Cycle set** filter. Drop-in
  custom themes are supported too.

- Cycle themes from the desktop context menu (Next / Previous / Set Current
  Theme).

- Toggle each scene layer on or off: canopy, glow spots, the central vortex
  glow and three independent space layers flying outward toward the viewer — a
  **point starfield** (short streaks), a dense **hyperspace beam** field (many
  thin radial lines) and plain twinkling **dots** — each blended via its own
  per-layer opacity. Layers that depend on another (glow spots sit on the
  canopy) are disabled in the settings when their parent is off.

- Glowing "mushroom / flower" spots scattered across the canopy.

- Adjustable canopy density, swirl, depth haze and centre-glow brightness.

- Zoom-speed control and FPS capping.

- Dimming control.

Everything is generated procedurally in the shader — there are no image assets.

## Settings

### Layers

Every layer is grouped into its own section with a **Visible** toggle plus its
settings. Layers that depend on another (glow spots sit on the canopy) are
disabled when their parent is off.

- **Canopy** — the leafy tunnel: density, **tunnel swirl** (how tightly it
  twists), **tunnel width** (how far the canopy sits from the centre — higher
  opens a wider tunnel mouth), **centre hole** (radius of the clear opening at
  the centre where the canopy stops and the vortex shows through), **depth haze**
  (how far rings dissolve into the central glow) and **opacity** to fade the
  whole canopy.
  - **Auto-swirl** — when enabled, the tunnel swirl drifts continuously at the
    chosen **speed** (small smooth steps; `0` = off, no drift), and every so
    often gets a **burst**: a larger ±margin jump every N seconds. Every swirl
    change — manual, drift or burst — is spring-smoothed so the rotation it
    induces eases gently in and out instead of snapping.
- **Glow spots** — brightness/quantity of the emissive mushroom-like spots on
  the canopy.
- **Centre glow (vortex)** — brightness, **vortex swirl** (how tightly the
  central background whirlpool winds, independent of the tunnel) and **opacity**
  to fade the vortex.
- **Stars (points)**, **Beams (hyperspace)**, **Dots (twinkling stars)** — three
  space layers flying outward, each with **count** (absolute number; for beams
  the number of radial lines), **speed** (never jumps when changed), **length**
  (stars & beams; dots are plain round points), and **opacity** to blend the
  layer independently. All three fade out around the centre.

The space layers are coloured from the **active theme's palette**, so every set
— spectrum, gruvbox, psychedelic … — tints them (a psychedelic set fans the
beams out into a full rainbow).

### Theme

- **Initial theme** — the theme loaded at start, or *Random*.
- **Auto-cycle themes** — cross-fade to another theme every N secs/mins.
- **Cycle in random order** — shuffle instead of going in list order.
- **Cycle set** — restrict cycling/random selection to *All*, *Light*, *Dark*,
  *Mixed* or *Psychedelic* themes.
- **Transition duration** — how long each cross-fade takes.
- **Brightness** — globally darken the effect.

### Animation

- **Zoom speed** — how fast the camera flies into the tunnel.
- **Tunnel rotation** — signed spin speed of the whole tunnel (negative
  reverses direction).
- **Vortex rotation** — signed spin speed of the central whirl; defaults to the
  opposite direction of the tunnel.
- **FPS cap** — limit the animation frame rate to save power.

## Custom themes

Drop a `.qml` theme file into
`~/.config/monolith/trippy-forest/themes.d/` and restart plasmashell. See
`themes/example.qml` in the effect directory for the format — a theme provides
`canopy`, `glow` and `mist` colours, an optional `stars` colour and `mode`
tone (`light`/`dark`/`mixed`/`psychedelic`), plus a 6-colour `palette` that is
wrapped around the tunnel to drive the colour flow.

## Gallery

Trippy Forest effect on the default *Spectrum* theme, with no additional filters
applied.

![Preview](img/preview-01.webp)
