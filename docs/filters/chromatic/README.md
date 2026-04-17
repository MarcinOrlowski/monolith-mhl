← [Back to documentation index](../../README.md)

# Chromatic Aberration

Simulates a cheap camera lens by shifting the red and blue color channels
outwards from the image center while the green channel stays put. The result is
colored fringes around high-contrast edges — subtle at low strength, overtly
"glitchy" at high values.

## Parameters

| Parameter | Description                                                                                                         | Default | Range       |
| --------- | ------------------------------------------------------------------------------------------------------------------- | ------- | ----------- |
| Strength  | How far the red/blue channels are displaced from center. Higher = more visible fringing at the edges of the screen. | `1.0x`  | `0.1–10.0x` |

## See also

- [Chromatic aberration (Wikipedia)](https://en.wikipedia.org/wiki/Chromatic_aberration)

## Images (TODO)

Prompt to feed to a drawing agent to produce `img/radial-shift.svg`:

```text
Flat schematic on neutral mid-gray background. A rectangle represents the screen/image bounds. Inside, draw a small crosshair at the rectangle's center marked "image center". Around the edges, show four sample "pixel triplets": at each corner and two edges, draw three small overlapping dots — red, green, blue — where the green dot sits on an ideal grid position and the red/blue dots are pushed radially outward from the image center, farther the closer to the corner. Annotate one triplet with "Strength" labeling the red↔blue separation. No photography, flat vector schematic, 16:9, transparent background, labels in dark-gray sans-serif. Output SVG preferred, PNG 1200×600 fallback.
```
