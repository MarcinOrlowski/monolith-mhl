← [Back to documentation index](../../README.md)

# Mask

Tiles a square stencil across the wallpaper and replaces pixels either inside
or outside each tile with a solid color. Useful for perforated overlays, grid
patterns, pixel-art-style windows, or simple color-block frames.

## Parameters

| Parameter  | Description                                                                                                                               | Default   | Range                |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------- | --------- | -------------------- |
| Tile size  | Side length of each repeating tile, in pixels.                                                                                            | `64 px`   | `4–500 px`           |
| Padding    | Empty gap inside each tile. Pixels within `padding` of the tile edge are considered "outside" the square. Must be smaller than tile size. | `8 px`    | `0 to (tile − 1) px` |
| Invert     | Which side of the square gets recolored. Off = inside is filled with the mask color; On = outside (the padding area) is filled.           | `off`     | on / off             |
| Mask color | Solid color used for the replaced pixels.                                                                                                 | `#000000` | any hex color        |

## Notes

- "Outside" does not mean transparent — the masked-out region is filled with a
  solid color, so the mask color becomes the visible background.
- For a clean grid effect, set padding small relative to tile size; for a
  "looking through a window" look, invert the mask so only the padding area
  shows through.

## Images (TODO)

Prompt to feed to a drawing agent to produce `img/mask-anatomy.svg`:

```text
Two side-by-side diagrams on neutral mid-gray background, each showing a 3×3 grid of square tiles. Left diagram labeled "Invert: off": each tile has a solid dark fill inside (the square) with a lighter padding gap around it — the dark center is labeled "mask color" and an annotation arrow labels "Tile size" across the edge of one tile, another labels "Padding" across the gap. Right diagram labeled "Invert: on": inverted — the padding gap region is filled with the mask color, tile centers are the underlying (mid-gray) wallpaper, same annotations. No photography, flat vector schematic, 16:9 overall, transparent background, labels in dark-gray sans-serif. Output SVG preferred, PNG 1200×600 fallback.
```
