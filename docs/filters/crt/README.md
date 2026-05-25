← [Back to documentation index](../../README.md)

# CRT Curvature

Emulates the subtle bulge of an old cathode-ray-tube monitor by warping the
image outward from its center, and optionally darkening the corners with a
circular vignette. Pairs well with Scanlines for a full retro-monitor look.

## Parameters

| Parameter | Description                                                                                                            | Default | Range    |
| --------- | ---------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| Curvature | How pronounced the barrel distortion is. Higher values bulge the image more and push content further into the corners. | `10`    | `1–50`   |
| Vignette  | Strength of the corner darkening. `0%` disables the vignette entirely.                                                 | `30%`   | `0–100%` |

## See also

- [Barrel distortion](<https://en.wikipedia.org/wiki/Distortion_(optics)#Radial_distortion>)
