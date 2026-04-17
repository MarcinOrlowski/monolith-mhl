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
