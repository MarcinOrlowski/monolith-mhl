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
    float iTime;
    float iWidth;
    float iHeight;
    float density;
    float dimLevel;
    float leafColorR;
    float leafColorG;
    float leafColorB;
    float bgColorR;
    float bgColorG;
    float bgColorB;
    float lightColorR;
    float lightColorG;
    float lightColorB;
    float showFog;
    float showRays;
    float showParticles;
    float showVignette;
    float particleCount;
    float particleSize;
};

// ---------------------------------------------------------------------------
// Endless, constant-speed forward zoom into a microscopic world.
//
// The "camera" pushes straight in at a fixed rate (no drift or shake). Depth is
// faked with a stack of organic sheets: each sheet looms out of the central
// focal point, grows from a speck into a blob that sweeps past the edges, then
// recycles. Overlapping sheets at staggered depths keep the frame continuously
// full so the zoom never visibly resets. Floating dust motes drift past the
// lens. All positions/tones come from hashes, so the sample is non-repeating
// and endless.
// ---------------------------------------------------------------------------

float hash11(float n) { return fract(sin(n) * 43758.5453123); }

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123);
}

// Coverage of a field of elongated, randomly-rotated organic blobs at `uv`.
// `seed` decorrelates one sheet from the next. `tone` returns a random 0..1
// value for the winning (topmost) blob so callers can vary its shade.
float leafField(vec2 uv, float seed, float lush, out float tone) {
    vec2 id = floor(uv);
    vec2 f = fract(uv);
    float cov = 0.0;
    tone = 0.5;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 cid = id + g;
            vec2 rnd = hash22(cid + seed * 17.0);
            vec2 center = g + 0.15 + 0.7 * rnd;      // blob anchor inside cell
            vec2 d = f - center;
            float ang = (hash21(cid + seed * 3.1) - 0.5) * 3.14159;
            float ca = cos(ang);
            float sa = sin(ang);
            d = vec2(ca * d.x - sa * d.y, sa * d.x + ca * d.y);
            d.x *= 1.9;                               // narrow -> blade-like
            float r = length(d);
            float rad = (0.32 + 0.16 * hash21(cid + seed * 7.3)) * (0.55 + lush);
            float c = smoothstep(rad, rad * 0.55, r); // filled blob, soft edge
            if (c > cov) { cov = c; tone = rnd.x; }
        }
    }
    return cov;
}

void main() {
    float aspect = iWidth / max(iHeight, 1.0);
    vec2 p = (coord - 0.5) * vec2(aspect, 1.0);      // centered, focal point at 0

    vec3 fog   = vec3(bgColorR, bgColorG, bgColorB);
    vec3 leafC = vec3(leafColorR, leafColorG, leafColorB);
    vec3 light = vec3(lightColorR, lightColorG, lightColorB);

    // --- Background: gradient + light punching through at the focal point ---
    vec3 col = mix(fog * 0.65, fog * 1.1, smoothstep(0.0, 1.0, coord.y));
    float glow = exp(-dot(p, p) * 3.0);
    float glowAmt = (showFog > 0.5) ? 0.9 : 0.65;
    col = mix(col, light, glow * glowAmt);

    // --- Light rays fanning out from the focal point ---
    if (showRays > 0.5) {
        float ang = atan(p.y, p.x);
        float rays = 0.5 + 0.5 * sin(ang * 14.0 + sin(ang * 3.0 + iTime * 0.2) * 2.0);
        rays *= smoothstep(1.0, 0.0, length(p));
        col += light * rays * 0.12;
    }

    // --- Organic sheets looming toward the lens ---
    float lush = clamp(density, 0.0, 1.0);
    const int N = 9;
    for (int i = 0; i < N; i++) {
        float fi = float(i);
        float z = fract(iTime * 0.06 + fi / float(N));   // 0 = far, 1 = near
        float dist = mix(6.0, 0.35, z);
        float scale = 1.0 / dist;
        vec2 luv = p / scale * 2.2 + vec2(fi * 13.7, fi * 7.3);

        float tone;
        float cov = leafField(luv, fi * 1.3 + 4.0, lush, tone);
        float fade = smoothstep(0.0, 0.18, z) * (1.0 - smoothstep(0.82, 1.0, z));
        float a = cov * fade;

        tone = floor(tone * 3.0) / 3.0;                  // cel banding
        vec3 lc = mix(leafC * 0.5, leafC, tone);
        lc *= 0.7 + 0.3 * cov;                           // brighter blob centers
        lc = mix(lc, light, 0.15 * glow);                // catch the central light
        lc = mix(lc * 0.35, lc, smoothstep(0.0, 0.6, 1.0 - z)); // near sheets darker
        lc = mix(fog, lc, smoothstep(0.0, 0.35, z));     // far sheets sink into fog
        col = mix(col, lc, a);
    }

    // --- Floating dust motes streaming past the lens ---
    // particleCount is a user-set count (0..PMAX); PMAX is the loop's hard cap.
    if (showParticles > 0.5) {
        const int PMAX = 96;
        int pc = int(particleCount + 0.5);
        for (int i = 0; i < PMAX; i++) {
            if (i >= pc) break;
            float fi = float(i);
            float z = fract(iTime * 0.09 + fi * 0.1737 + hash11(fi) * 0.5);
            float dist = mix(5.0, 0.4, z);
            vec2 base = (hash22(vec2(fi, fi * 2.0 + 1.0)) - 0.5) * 2.0 * vec2(aspect, 1.0);
            vec2 sp = base / (dist * 0.5);               // spreads outward on approach
            float d = length(p - sp);
            float r = particleSize / dist;
            float fade = smoothstep(0.0, 0.2, z) * (1.0 - smoothstep(0.85, 1.0, z));
            col += light * smoothstep(r, r * 0.2, d) * fade * 0.55;
        }
    }

    // --- Vignette for depth/immersion ---
    if (showVignette > 0.5) {
        float vig = smoothstep(1.15, 0.35, length(p * vec2(1.0, 1.15)));
        col *= mix(0.55, 1.0, vig);
    }

    col *= dimLevel;
    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0) * qt_Opacity;
}
