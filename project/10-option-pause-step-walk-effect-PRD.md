# PRD: Add option to "pause" and "step walk" the effect and filters

Ticket: [#10: Add option to "pause" and "step walk" the effect
and filters](https://github.com/MarcinOrlowski/monolith-mhl/issues/10)

## Problem

There is currently no way for a user to pause the wallpaper animation. This
limits the ability to inspect or simply enjoy a specific moment of the animation.

## Goals

- Allow users to pause and resume the wallpaper animation (both the active effect
  and post-processing filters)
- Expose the toggle via desktop right-click context menu
- Keep the implementation minimal — effects gate their existing timers on a
  `paused` flag

## Non-goals

- Step-forward / frame-stepping (deferred to future ticket)
- Refactoring timer ownership to a master clock in the hub (deferred)
- Persisting pause state — it is runtime-only, resets on effect switch or
  plasmashell restart

## Design

### Hub (`main.qml`)

- Reads `paused` from the active effect (`effectLoader.item.paused`)
- Gates the filter pipeline timer (`filterTime`) on `!paused`
- Owns a context menu action: **Pause / Resume** (icon toggles between
  `media-playback-pause` and `media-playback-start`, label reflects current
  state)

### Effects

- Expose a runtime-only `property bool paused: false`
- Add `&& !effectRoot.paused` to the `running` condition of every existing timer
  (`FrameAnimation` and `Timer`)
- Provide a `togglePause()` function for the hub context menu to call
- Pause resets automatically on effect switch (fresh load starts unpaused)

## Scope

Changes touch the hub (`main.qml`) and both effect files. No shader, config,
settings UI, or filter pipeline changes are needed.
