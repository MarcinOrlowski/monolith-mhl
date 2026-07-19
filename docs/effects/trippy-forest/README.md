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

### Appearance

- **Canopy density** — how full the leafy canopies are (fewer gaps at higher
  values).
- **Swirl** — how tightly the tunnel and central vortex spiral (loose, nearly
  radial arms at low values; a tight whirlpool at high values).
- **Glow spots** — brightness/quantity of the emissive mushroom-like spots.
- **Centre glow** — brightness of the misty light at the end of the tunnel.
- **Depth haze** — how strongly distant rings dissolve into the central glow.

**Stars (points)**, **Beams (hyperspace)** and **Dots (twinkling stars)** each
have their own controls, active when the matching layer is on:

- **count** — how many are in flight (an absolute number; for beams it is the
  number of radial lines).
- **speed** — how fast they fly outward toward the edges. Changing speed only
  affects the flow from that moment on — it never jumps or restarts.
- **length** (stars & beams) — length of the motion streaks, from short dashes
  to long hyperspace lines. Dots are plain round points and twinkle instead.
- **opacity** — blend each layer in or out independently.

All three fade out around the centre so nothing converges to a single point,
and their **colour** comes from the active theme.

### Theme

- **Initial theme** — the theme loaded at start, or *Random*.
- **Auto-cycle themes** — cross-fade to another theme every N secs/mins.
- **Cycle in random order** — shuffle instead of going in list order.
- **Cycle set** — restrict cycling/random selection to *All*, *Light*, *Dark*,
  *Mixed* or *Psychedelic* themes.
- **Transition duration** — how long each cross-fade takes.
- **Brightness** — globally darken the effect.

### Layers

On/off toggles for **Canopy**, **Glow spots**, **Centre glow (vortex)**,
**Stars (points)**, **Beams (hyperspace)** and **Dots (twinkling stars)**. Glow
spots require the Canopy layer, so their toggle is disabled when the canopy is
off.

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
`foliage`, `glow` and `mist` colours, an optional `stars` colour and `mode`
tone (`light`/`dark`/`mixed`/`psychedelic`), plus a 6-colour `palette` that is
wrapped around the tunnel to drive the colour flow.

## Gallery

Trippy Forest effect on the default *Spectrum* theme, with no additional filters
applied.

![Preview](img/preview-01.webp)
