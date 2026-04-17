← [Back to documentation index](../../README.md)

# RGB Offset

Separates the red, green, and blue color channels and shifts them in a chosen
direction, producing a directional color-fringe / "glitch" or 3D-anaglyph look.
Similar to Chromatic Aberration but with a single fixed offset rather than a
radial one from the image center.

## Parameters

| Parameter | Description                                                                 | Default | Range      |
| --------- | --------------------------------------------------------------------------- | ------- | ---------- |
| Amount    | How far the channels are shifted apart, in pixels.                          | `5 px`  | `1–200 px` |
| Direction | Angle of the shift, in degrees. `0°` shifts horizontally; `90°` vertically. | `0°`    | `0–360°`   |

## Notes

- For a classic "broken VHS" look try `amount = 10–20 px` with the default
  horizontal direction.
- For a 3D-glasses effect, pair a small horizontal offset (`~5 px`) with a dark
  background.
