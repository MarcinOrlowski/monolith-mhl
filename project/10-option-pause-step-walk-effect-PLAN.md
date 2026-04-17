# Plan: Add pause/resume to effects and filters

## Context

Ticket #10 requests pause/resume functionality for wallpaper animations. The
approach: each effect gets a runtime-only `paused` boolean (not persisted);
timers gate on it; hub reads it for filter gating and exposes a context menu
toggle. Pause resets automatically on effect switch or restart.

## Steps

### 1. Rainbow Waves effect

**`src/contents/ui/effects/rainbow-waves/RainbowWavesEffect.qml`**

- Add `property bool paused: false` to effect root
- Add `function togglePause() { paused = !paused }`
- Gate both timers: append `&& !effectRoot.paused` to `running`

### 2. Lava Lamp effect

**`src/contents/ui/effects/lava-lamp/LavaLampEffect.qml`**

- Same pattern: `paused` property, `togglePause()`, gate timers

### 3. Hub

**`src/contents/ui/main.qml`**

- Add `property bool effectPaused: effectLoader.item ? effectLoader.item.paused : false`
- Gate filter `FrameAnimation`: append `&& !root.effectPaused` to `running`
- Add `PlasmaCore.Action` for Pause/Resume with toggling label/icon
- Merge hub action with effect actions in `contextualActions`

## Not needed

- No config/settings changes (runtime-only state)
- No settings UI changes
- No shader changes
