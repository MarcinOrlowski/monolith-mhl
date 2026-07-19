// /***********************************************************************
//  *
//  * Monolith MHL: Beautiful animated wallpapers for Plasma 6
//  *
//  * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
//  * @copyright ©2026 Marcin Orlowski
//  * @license   http://www.opensource.org/licenses/mit-license.php MIT
//  * @link      https://github.com/MarcinOrlowski/monolith-mhl
//  *
//  **********************************************************************/

#version 440

layout(location = 0) in vec2 coord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float iTime;            // zoom accumulator
    float iWidth;
    float iHeight;
    float rotTime;          // tunnel rotation accumulator (signed speed folded in)
    float whirlTime;        // vortex rotation accumulator (signed, usually opposite)
    float showFoliage;
    float showGlow;
    float showVortex;
    float spiral;
    float density;
    float glowAmount;
    float mistAmount;
    float fog;
    float dimLevel;
    vec4 foliageCol;
    vec4 glowCol;
    vec4 mistCol;
    vec4 pal0;
    vec4 pal1;
    vec4 pal2;
    vec4 pal3;
    vec4 pal4;
    vec4 pal5;
};

// Endless zoom into a trippy forest. Rings of leafy silhouettes recede toward a
// glowing, swirling vortex at the centre. Each ring is a perspective slice at a
// growing distance; as time advances the rings scale up and sweep past the frame
// edge while new ones fade in at the centre, giving a seamless infinite zoom. The
// whole tunnel rotates (rotTime) while the central whirl counter-rotates
// (whirlTime). Colours come entirely from the active theme's 6-stop palette, so
// theme cycling cross-fades the whole scene. Everything is procedural (no
// textures).

const int LAYERS = 9;         // depth slices composited per pixel
const float ZOOM = 0.22;      // rings advanced per time unit
const float RINGSCALE = 0.55; // projected radius = RINGSCALE / distance
const float ARMS = 5.0;       // vortex spiral-arm count

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float s = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 4; i++) {
        s += amp * vnoise(p);
        p *= 2.02;
        amp *= 0.5;
    }
    return s;
}

// Smooth 6-stop wrapping gradient over the theme palette.
vec3 palette(float t) {
    t = fract(t) * 6.0;
    vec3 c0 = pal0.rgb, c1 = pal1.rgb, c2 = pal2.rgb;
    vec3 c3 = pal3.rgb, c4 = pal4.rgb, c5 = pal5.rgb;
    vec3 a = (t < 1.0) ? c0 : (t < 2.0) ? c1 : (t < 3.0) ? c2 : (t < 4.0) ? c3 : (t < 5.0) ? c4 : c5;
    vec3 b = (t < 1.0) ? c1 : (t < 2.0) ? c2 : (t < 3.0) ? c3 : (t < 4.0) ? c4 : (t < 5.0) ? c5 : c0;
    return mix(a, b, fract(t));
}

vec3 scene(vec2 uv) {
    float r = length(uv) + 1e-4;
    float a = atan(uv.y, uv.x);

    float scroll = iTime * ZOOM;
    float baseZ = fract(scroll);
    float ringBase = floor(scroll);

    // --- central mist / counter-swirling vortex glow (deepest layer) ---
    float cg = smoothstep(1.0, 0.0, r);
    float swirl = 0.5 + 0.5 * sin(ARMS * a + log(r) * 7.0 + whirlTime * 1.5 - spiral * 3.0);
    swirl = pow(swirl, 2.0);
    vec3 vortexTint = palette(fract(a / 6.2831 + whirlTime * 0.05 + 0.5));
    vec3 center = mistCol.rgb * mistAmount * (0.30 + 0.70 * cg);
    center = mix(center, center * 0.4 + vortexTint * mistAmount, (0.35 + 0.45 * swirl) * cg);
    vec3 col = center * showVortex;

    // --- foliage rings, far to near (painter's order) ---
    for (int i = LAYERS - 1; i >= 0; i--) {
        float fi = float(i);
        float zc = fi + 1.0 - baseZ;            // distance from camera (> 0)
        float ringId = ringBase + fi + 1.0;     // stable per-ring seed
        float proj = RINGSCALE / zc;            // on-screen radius of this ring

        // angular twist grows with distance -> nested mouths form a spiral; the
        // whole tunnel also rotates with rotTime.
        float aa = a + spiral * zc * 0.55 + rotTime;
        vec2 pc = vec2(cos(aa), sin(aa));       // periodic (no seam) around the ring
        float rNorm = r / proj;                 // radial position within this ring

        // ragged tunnel mouth + outer extent, both scaled by projection
        float op = 0.50 + 0.14 * fbm(pc * 3.0 + ringId * 1.7)
                        + 0.09 * fbm(pc * 9.0 + ringId * 4.0);
        float opening = proj * op;
        float outer = proj * 1.8;

        // leafy canopy: noise indexed by BOTH angle and radius so clumps read as
        // leaves rather than radial streaks.
        vec2 nco = pc * 5.0 + vec2(rNorm * 4.0, rNorm * 2.0);
        float leaf = fbm(nco + ringId * 3.1);
        float gap = mix(0.60, 0.30, clamp(density, 0.0, 1.0));
        float mask = smoothstep(gap, gap + 0.12, leaf);

        float inner = smoothstep(opening, opening * 1.04, r);
        float edge = 1.0 - smoothstep(outer * 0.9, outer, r);
        // fade newly spawned far rings in via alpha instead of popping into view
        float appear = smoothstep(float(LAYERS), float(LAYERS) - 1.2, zc);
        float cov = clamp(inner * edge * mask, 0.0, 1.0) * appear * showFoliage;

        // Near rings are dark backlit silhouettes; depth brings the palette colour
        // and haze, dissolving distant rings into the glowing central vortex.
        float far = clamp(zc / float(LAYERS), 0.0, 1.0);
        vec3 tint = palette(fract(aa / 6.2831 + far * 0.5 + rotTime * 0.03));
        vec3 fol = foliageCol.rgb * (0.10 + 0.35 * far);
        fol = mix(fol, tint, 0.15 + 0.65 * far);
        fol = mix(fol, mistCol.rgb * mistAmount, far * fog);

        // thin backlit rim right at the mouth edge (leaves lit from behind)
        float rim = inner * (1.0 - smoothstep(opening * 1.02, opening * 1.10, r)) * edge;
        fol += mix(mistCol.rgb * mistAmount, tint, 0.6) * rim * (0.35 + 0.5 * far) * appear;

        // sparse emissive spots (mushrooms / flowers) on the foliage
        float spotN = vnoise(pc * 10.0 + vec2(rNorm * 12.0, ringId * 5.0));
        float spot = smoothstep(0.80, 0.90, spotN) * cov;
        vec3 spotCol = mix(glowCol.rgb, tint, 0.5);

        col = mix(col, fol, cov);
        col += spotCol * spot * glowAmount * showGlow * (0.4 + 0.6 * far);
    }

    return col;
}

void main() {
    vec2 res = vec2(iWidth, iHeight);
    vec2 uv = (coord * res - 0.5 * res) / res.y;   // centred, aspect via height

    vec3 col = scene(uv);

    col *= dimLevel;
    col = clamp(col, 0.0, 1.0);
    fragColor = vec4(col, 1.0) * qt_Opacity;
}
