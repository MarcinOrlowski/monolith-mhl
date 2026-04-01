# TRD: Add option to "pause" and "step walk" the effect and filters

Ticket: [#10: Add option to "pause" and "step walk" the effect
and filters](https://github.com/MarcinOrlowski/monolith-mhl/issues/10)

PRD:
[10-option-pause-step-walk-effect-PRD.md](10-option-pause-step-walk-effect-PRD.md)

## Approach

- Add runtime-only `property bool paused: false` and `togglePause()` to each
  effect
- Append `&& !effectRoot.paused` to every effect timer's `running` binding
- Hub reads `effectLoader.item.paused` to gate the filter pipeline timer
- Hub owns a Pause/Resume context menu action that calls
  `effectLoader.item.togglePause()`
- No persistence, no config changes, no settings UI — runtime-only state that
  resets on effect switch or restart

## Testing

- Context menu pause/resume works for both effects
- Filter pipeline freezes when paused
- Switching effects while paused → new effect starts unpaused
