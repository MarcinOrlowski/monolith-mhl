# Rainbow Waves user themes

Rainbow Waves supports user-created color themes. Themes are plain QML files
that define the colors used by each visual layer of the wallpaper.

## Theme file location

| Source | Path                                              | Notes                          |
| ------ | ------------------------------------------------- | ------------------------------ |
| User   | `~/.config/monolith/rainbow-waves/themes.d/*.qml` | Create this directory manually |

User themes appear alongside built-in themes in the wallpaper settings.
A user theme whose `themeId` matches a built-in theme is rejected to prevent
accidental overrides.

## Theme file format

A fully commented example theme file with detailed descriptions of every
field is shipped with the plugin as
[src/contents/ui/effects/rainbow-waves/themes/example.qml](/src/contents/ui/effects/rainbow-waves/themes/example.qml).

To create your own theme:

1. Copy `example.qml` to `~/.config/monolith/rainbow-waves/themes.d/`
   (create the directory if it does not exist).

1. Rename the copy to something like `my-theme.qml`.

1. Set `enabled` to `true`, edit `themeId`, `name`, and all colors.

1. Restart plasmashell:

   ```bash
   systemctl --user restart plasma-plasmashell.service
   ```

1. Open wallpaper settings — your theme should appear in the list.

## Loading behavior

- Themes are discovered at wallpaper startup from both the built-in and
  user directories. Only files with the `.qml` extension are considered —
  all other files (e.g. `.qml.bak`, `.txt`) are ignored. Themes with
  `enabled: false` are silently skipped.

- Each theme file is loaded as a QML component and validated. Files with
  missing properties, wrong array lengths, or invalid color values are
  skipped with a warning in the system journal.

- If two user theme files define the same `themeId`, only the first one
  loaded is used.

- Changing themes takes effect immediately in the wallpaper settings.

- Under certain circumstances manual restart of plasmashell may be needed.

## Layer visibility

Themes can optionally control which visual layers are shown by default.
Add any of the following boolean properties to your theme file:

```qml
property bool showBackground: true
property bool showStars: true
property bool showGhosts: true
property bool showWaves: true
property bool showGlow: true
property bool showHalo: true
property bool showShine: true
property bool showSpotlights: true
```

- If a property is omitted in a theme file, it behaves as if it were set
  to `true` (visible).
- When a theme is loaded, its effective layer visibility values (including
  any omitted ones that default to `true`) override the current toggle state
  in the wallpaper settings UI.
- The user can still change individual toggles via the settings checkboxes
  after the theme is applied.

## Built-in theme IDs

Built in themes are using ID prefixed with `rwm-` so as long as yours
are not using the same prefix we shall never cross paths here.

The only reason to use `rwm-` prefix is to override built-in theme, but
in such case I rather recommend using custom theme and ignore built-in
one.
