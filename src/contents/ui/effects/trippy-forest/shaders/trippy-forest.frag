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
    float starTime;         // point-star flight accumulator (speed folded in)
    float beamTime;         // hyperspace-beam flight accumulator
    float dotTime;          // dot-star flight accumulator
    float showFoliage;
    float showGlow;
    float showVortex;
    float showStars;
    float showBeams;
    float showDots;
    float spiral;
    float vortexSwirl;
    float tunnelWidth;
    float density;
    float glowAmount;
    float mistAmount;
    float fog;
    float starCount;
    float starLength;
    float starOpacity;
    float beamCount;
    float beamLength;
    float beamOpacity;
    float dotCount;
    float dotOpacity;
    float dimLevel;
    vec4 foliageCol;
    vec4 glowCol;
    vec4 mistCol;
    vec4 starsCol;
    vec4 pal0;
    vec4 pal1;
    vec4 pal2;
    vec4 pal3;
    vec4 pal4;
    vec4 pal5;
};

// Endless zoom into a trippy forest. Rings of leafy silhouettes recede toward a
// glowing, swirling vortex at the centre. Three optional space layers fly
// outward toward the viewer above the vortex and behind the canopy: point stars
// (short motion streaks), hyperspace beams (many thin radial lines) and plain
// twinkling dots. Each has its own flight accumulator so changing speed never
// retroactively rescales time. Colours come from the active theme's palette.
// Everything is procedural (no textures).

const int LAYERS = 9;         // depth slices composited per pixel
const float ZOOM = 0.22;      // rings advanced per time unit
const float RINGSCALE = 0.55; // projected radius = RINGSCALE / distance
const float ARMS = 5.0;       // vortex spiral-arm count
const int STAR_MAX = 128;     // point/dot loop budget (count caps how many run)

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

// Cheap 2D hash for the star layers.
vec2 hash2(float n) {
    return fract(sin(vec2(n, n + 1.7)) * vec2(43758.5453, 22578.145));
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
    // `vortexSwirl` sets how tightly the vortex arms wind (log-radius frequency),
    // independent of the tunnel's `spiral` twist.
    float cg = smoothstep(1.0, 0.0, r);
    float swirl = 0.5 + 0.5 * sin(ARMS * a + log(r) * (2.0 + vortexSwirl * 14.0) + whirlTime * 1.5);
    swirl = pow(swirl, 2.0);
    vec3 vortexTint = palette(fract(a / 6.2831 + whirlTime * 0.05 + 0.5));
    vec3 center = mistCol.rgb * mistAmount * (0.30 + 0.70 * cg);
    center = mix(center, center * 0.4 + vortexTint * mistAmount, (0.35 + 0.45 * swirl) * cg);
    vec3 col = center * showVortex;

    // Fade the space layers around the centre so nothing meets in the middle.
    float centerHole = smoothstep(0.04, 0.18, r);

    // --- point starfield: sparse dots with short motion streaks, flying outward ---
    if (showStars > 0.5) {
        float st = starTime * 0.16;
        float tail = 2.0 + starLength * 22.0;
        float sSum = 0.0;
        for (int s = 0; s < STAR_MAX; s++) {
            if (float(s) >= starCount) break;
            vec2 h = hash2(float(s) * 1.7 + 3.1);
            float sang = h.x * 6.2831 + rotTime * 0.15;
            float z = fract(h.y - st);                       // 1 -> 0: centre -> edge (outward)
            vec2 rdir = vec2(cos(sang), sin(sang));
            vec2 sp = rdir * (0.95 * pow(1.0 - z, 1.6));
            vec2 dv = uv - sp;
            float along = dot(dv, rdir);
            float perp = dot(dv, vec2(-rdir.y, rdir.x));
            float d = length(vec2(along / (1.0 + (1.0 - z) * tail), perp));
            float size = mix(0.004, 0.02, 1.0 - z);
            float spark = smoothstep(size, 0.0, d);
            sSum += spark * (1.0 - z) * smoothstep(0.0, 0.12, z);
        }
        col += starsCol.rgb * clamp(sSum, 0.0, 1.0) * centerHole * starOpacity;
    }

    // --- hyperspace beams: many thin radial streaks flying outward to the edge ---
    // Each angular sector hosts one streak, so beamCount is a real line count and
    // the pass is O(1) per pixel regardless of how many are requested.
    if (showBeams > 0.5) {
        float N = max(4.0, beamCount);
        float sa = (a / 6.2831 + 0.5) * N;        // angle -> line-index space
        float base = floor(sa);
        float beams = 0.0;
        for (int k = -1; k <= 1; k++) {           // include neighbours for border lines
            float id = base + float(k);
            vec2 h = hash2(mod(id, N) * 1.7 + 11.0);
            vec2 h2 = hash2(mod(id, N) * 3.1 + 4.7);
            float bcenter = id + 0.5 + (h.x - 0.5) * 0.7;
            float across = sa - bcenter;
            float thin = exp(-across * across * 40.0);       // thin angular line
            if (thin < 0.003) continue;
            // head grows 0 -> 1 over the cycle, so the streak flies outward
            float t = fract(h2.x + beamTime * 0.16 * (0.5 + h.y));
            float head = pow(t, 0.7);
            float tailLen = (0.04 + beamLength * 0.7) * (0.5 + h2.y);  // per-line length
            float radial = smoothstep(head - tailLen, head, r)
                         * (1.0 - smoothstep(head, head + 0.02, r));
            float edgeFade = 1.0 - smoothstep(0.92, 1.08, head);      // fade out at recycle
            float bright = 0.35 + 0.65 * h.y;                         // per-line brightness
            beams += thin * radial * edgeFade * bright;
        }
        col += starsCol.rgb * clamp(beams, 0.0, 1.4) * centerHole * beamOpacity;
    }

    // --- dot starfield: plain round twinkling stars flying forward ---
    if (showDots > 0.5) {
        float dt2 = dotTime * 0.16;
        float dSum = 0.0;
        for (int s = 0; s < STAR_MAX; s++) {
            if (float(s) >= dotCount) break;
            vec2 h = hash2(float(s) * 4.3 + 1.9);
            float dang = h.x * 6.2831;
            float z = fract(h.y - dt2);                      // 1 -> 0: centre -> edge (outward)
            vec2 pos = vec2(cos(dang), sin(dang)) * (0.98 * pow(1.0 - z, 1.7));
            float d = length(uv - pos);
            float size = mix(0.0015, 0.010, 1.0 - z);        // grows as it approaches
            float dotv = smoothstep(size, 0.0, d);
            float twinkle = 0.6 + 0.4 * sin(dotTime * 3.0 + h.x * 30.0);
            dSum += dotv * (1.0 - z) * smoothstep(0.0, 0.1, z) * twinkle;
        }
        col += starsCol.rgb * clamp(dSum, 0.0, 1.0) * centerHole * dotOpacity;
    }

    // --- foliage rings, far to near (painter's order) ---
    for (int i = LAYERS - 1; i >= 0; i--) {
        float fi = float(i);
        float zc = fi + 1.0 - baseZ;            // distance from camera (> 0)
        float ringId = ringBase + fi + 1.0;     // stable per-ring seed
        // on-screen radius of this ring; tunnelWidth pushes the foliage out
        // (wider tunnel mouth) or pulls it in (narrower).
        float proj = (RINGSCALE * tunnelWidth) / zc;

        // angular twist grows with distance -> nested mouths form a spiral; the
        // whole tunnel also rotates with rotTime. Higher `spiral` = tighter tunnel.
        float aa = a + spiral * zc * 1.1 + rotTime;
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
