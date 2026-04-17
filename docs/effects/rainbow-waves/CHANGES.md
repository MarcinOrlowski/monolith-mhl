# Rainbow Waves Changelog

## v1.2.0 (TBD)

- Added automatic theme cycling with smooth color crossfade transitions.
- Added configurable cycle interval (seconds or minutes) and transition duration.
- Added random and sequential theme cycling modes.
- Added new built-in themes (20 total).
- Added random initial theme option (integrated into theme selector).
- Added support for user-created themes. See `docs/effects.md` for more info.
- Added desktop context menu to switch wallpaper themes to next/preview one.
- Added "Set Current Theme" context menu to save the displayed theme as default.
- Theme now supports `enabled` flag to easilty turn it on or off.
- Prefixed all built-in theme IDs with `rwm-` to avoid conflicts.
- Improved startup flow: wallpaper now fades in smoothly from black instead of appearing after a delay.
- Fixed random initial theme always picking the same theme on fresh install.

## v1.1.0 (2026-03-20)

- Added FPS cap option to reduce resource usages (default limit 30 FPS).
- Added wallpaper brightness control.
- Updated docs with requirements and installation instructions.
- Added visual error message for incompatible hardware.
- Added deb/PPA builders.

## v1.0.0 (2026-03-19)

- Init of Rainbow Waves wallpaper effect.
