← [Back to documentation index](../../README.md)

# Color Grading

Photo-style tonal adjustments applied after the wallpaper is rendered. Lets you
brighten or darken midtones, push contrast, and warm or cool the overall
palette without touching the underlying effect's colors.

## Parameters

| Parameter   | Description                                                                  | Default | Range          |
| ----------- | ---------------------------------------------------------------------------- | ------- | -------------- |
| Gamma       | Midtone lightness. Below `1.0` darkens midtones, above `1.0` brightens them. | `1.0`   | `0.5–2.0`      |
| Contrast    | Spread between darks and lights around middle gray. `1.0` is unchanged.      | `1.0`   | `0.5–2.0`      |
| Temperature | Warm/cool shift. Positive pushes toward orange, negative toward blue.        | `0`     | `-100 to +100` |
| Tint        | Green/magenta shift. Positive pushes toward magenta, negative toward green.  | `0`     | `-100 to +100` |

## Notes

- Temperature and tint are independent axes — combine them to mimic specific
  lighting conditions (e.g. high temperature + slight negative tint for a golden
  hour look).
