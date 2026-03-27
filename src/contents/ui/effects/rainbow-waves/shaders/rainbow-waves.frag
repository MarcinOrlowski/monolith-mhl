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
    float showBackground;
    float showStars;
    float showGhosts;
    float showWaves;
    float showGlow;
    float showHalo;
    float showShine;
    float showSpotlights;
    vec4 bg0; vec4 bg1; vec4 bg2; vec4 bg3; vec4 bg4;
    vec4 effectColor;
    vec4 ghost0; vec4 ghost1; vec4 ghost2; vec4 ghost3;
    vec4 wMain0; vec4 wMain1; vec4 wMain2; vec4 wMain3; vec4 wMain4;
    vec4 wMain5; vec4 wMain6; vec4 wMain7; vec4 wMain8; vec4 wMain9;
    vec4 wHl0; vec4 wHl1; vec4 wHl2; vec4 wHl3; vec4 wHl4;
    vec4 wHl5; vec4 wHl6; vec4 wHl7; vec4 wHl8; vec4 wHl9;
    vec4 glowCore;
    vec4 spotColor;
    vec4 starColor;
    float dimLevel;
};

#define NUM_WAVES 10
#define NUM_GHOSTS 4
#define PI 3.14159265

// ── Wave parameters ───────────────────────────────────────────────

// Main waves
const float wBaseY[10] = float[10](0.08, 0.15, 0.25, 0.33, 0.42, 0.52, 0.60, 0.68, 0.78, 0.88);
const float wAmp[10]   = float[10](55.0, 70.0, 65.0, 75.0, 85.0, 90.0, 80.0, 70.0, 65.0, 50.0);
const float wFreq[10]  = float[10](0.0025, 0.003, 0.0035, 0.0028, 0.0025, 0.003, 0.0028, 0.0032, 0.004, 0.0035);
const float wSpd[10]   = float[10](0.0052, 0.0078, 0.0063, 0.0071, 0.0095, 0.0067, 0.0084, 0.0058, 0.0046, 0.0089);
const float wPhase[10] = float[10](0.8, 0.0, 1.2, 5.5, 2.5, 4.0, 3.0, 1.8, 5.0, 2.8);
const float wDir[10]   = float[10](-1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
const float wOpa[10]   = float[10](0.72, 0.78, 0.74, 0.80, 0.71, 0.76, 0.73, 0.79, 0.75, 0.70);
const float wW3d[10]   = float[10](1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0, 1.0, -1.0);

// Ghost waves
const float gBaseY[4] = float[4](0.10, 0.30, 0.50, 0.70);
const float gAmp[4]   = float[4](50.0, 60.0, 70.0, 55.0);
const float gFreq[4]  = float[4](0.002, 0.0022, 0.0032, 0.003);
const float gSpd[4]   = float[4](0.005, 0.006, 0.008, 0.006);
const float gPhase[4] = float[4](0.5, 3.5, 1.0, 2.5);
const float gDir[4]   = float[4](1.0, -1.0, 1.0, -1.0);
const float gOpa[4]   = float[4](0.15, 0.15, 0.18, 0.12);

// ── Wave math: 3-harmonic sine ───────────────────────────────────
float waveY(float x, float baseY, float amp, float freq, float spd,
            float ph, float dir, float w3dir, float t) {
    float p1 = x * freq + t * spd * dir + ph;
    float p2 = x * freq * 2.0 + t * spd * 0.7 * dir + ph;
    float p3 = x * freq * 3.0 + t * spd * 0.5 * w3dir + ph * 1.5;
    return baseY + sin(p1) * amp + sin(p2) * amp * 0.3 + sin(p3) * amp * 0.25;
}

float mainWaveY(int i, float px, float t) {
    return waveY(px, wBaseY[i] * iHeight, wAmp[i], wFreq[i], wSpd[i],
                 wPhase[i], wDir[i], wW3d[i], t);
}

float ghostWaveY(int i, float px, float t) {
    return waveY(px, gBaseY[i] * iHeight, gAmp[i], gFreq[i], gSpd[i],
                 gPhase[i], gDir[i], 1.0, t);
}

// ── Hash for stars ───────────────────────────────────────────────
float hash(vec2 p) {
    p = fract(p * vec2(443.897, 441.423));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

// ── Background gradient ───────────────────────────────────────────
vec3 background(vec2 uv, vec3 bg[5]) {
    float t = (uv.x + uv.y) * 0.5;
    if (t < 0.25) { return mix(bg[0], bg[1], t / 0.25); }
    if (t < 0.50) { return mix(bg[1], bg[2], (t - 0.25) / 0.25); }
    if (t < 0.75) { return mix(bg[2], bg[3], (t - 0.50) / 0.25); }
    return mix(bg[3], bg[4], (t - 0.75) / 0.25);
}

// ── Stars (grid-based) ──────────────────────────────────────────
vec3 addStars(vec3 col, float px, float py, vec2 uv, float t) {
    if (uv.y > 0.35) {
        return col;
    }

    float cellSize = 25.0;
    vec2 cell = floor(vec2(px, py) / cellSize);

    for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
            vec2 c = cell + vec2(float(dx), float(dy));
            float h = hash(c);
            if (h > 0.07) {
                continue;
            }

            vec2 starPx = (c + vec2(hash(c + 0.1), hash(c + 0.2))) * cellSize;
            if (starPx.y / iHeight > 0.35) {
                continue;
            }

            float baseSize = 0.5 + hash(c + 0.3) * 1.5;
            float starSize = baseSize;

            float baseAlpha = 0.3 + hash(c + 0.4) * 0.7;
            float alpha = baseAlpha;

            // Blink: burst to full brightness, then slow fade
            if (hash(c + 0.5) > 0.5) {
                float interval = 60.0 + hash(c + 0.6) * 180.0;
                float fadeSpd = 0.005 + hash(c + 0.7) * 0.015;
                float startOffset = hash(c + 0.8) * 60.0;
                float phase = mod(t + startOffset, interval);
                float brightness = max(0.0, 1.0 - phase * fadeSpd);
                if (brightness > 0.0) {
                    alpha = baseAlpha + (1.0 - baseAlpha) * brightness;
                    starSize = baseSize * (1.0 + brightness * 0.5);
                }
            }

            if (abs(px - starPx.x) > starSize || abs(py - starPx.y) > starSize) {
                continue;
            }

            // Fade with depth
            float fadeY = starPx.y / (iHeight * 0.35);
            alpha *= 1.0 - fadeY * fadeY;
            col = mix(col, starColor.rgb, alpha);
        }
    }
    return col;
}

// ─────────────────────────────────────────────────────────────────

void main() {
    float px = coord.x * iWidth;
    float py = coord.y * iHeight;
    float t = iTime;

    // Build local color arrays from uniforms
    vec3 bg[5] = vec3[5](bg0.rgb, bg1.rgb, bg2.rgb, bg3.rgb, bg4.rgb);
    vec3 ecol = effectColor.rgb;
    vec3 gc[4] = vec3[4](ghost0.rgb, ghost1.rgb, ghost2.rgb, ghost3.rgb);
    vec3 wm[10] = vec3[10](wMain0.rgb, wMain1.rgb, wMain2.rgb, wMain3.rgb, wMain4.rgb,
                           wMain5.rgb, wMain6.rgb, wMain7.rgb, wMain8.rgb, wMain9.rgb);
    vec3 wh[10] = vec3[10](wHl0.rgb, wHl1.rgb, wHl2.rgb, wHl3.rgb, wHl4.rgb,
                           wHl5.rgb, wHl6.rgb, wHl7.rgb, wHl8.rgb, wHl9.rgb);

    // Background (#0a0a1a body color when bg disabled)
    vec3 col = vec3(0.039, 0.039, 0.102);
    if (showBackground > 0.5) {
        col = background(coord, bg);
    }

    // Stars
    if (showStars > 0.5) {
        col = addStars(col, px, py, coord, t);
    }

    // Ghost waves
    for (int i = 0; i < NUM_GHOSTS; i++) {
        if (showGhosts < 0.5) {
            break;
        }
        float wy = ghostWaveY(i, px, t);
        if (py > wy) {
            // JS: vertical gradient from minY to screen bottom
            float approxMinY = gBaseY[i] * iHeight - gAmp[i] * 1.55;
            float range = iHeight - approxMinY;
            float d = (py - approxMinY) / range;
            float ga;
            if (d < 0.4) ga = mix(1.0, 0.3, d / 0.4);
            else         ga = max(0.0, mix(0.3, 0.0, (d - 0.4) / 0.6));
            col = mix(col, gc[i], gOpa[i] * ga);
        }
    }

    // Main waves (sorted back-to-front by baseY)
    for (int i = 0; i < NUM_WAVES; i++) {
        float wy = mainWaveY(i, px, t);
        float opa = wOpa[i];
        vec3 mainC = wm[i];
        vec3 hlC   = wh[i];

        // ── Wave fill ──
        // Approximate minY using fundamental amplitude only, so gradient
        // stays visible at peaks while troughs remain transparent
        float approxMinY = wBaseY[i] * iHeight - wAmp[i];
        if (showWaves > 0.5 && py > wy) {
            float d = (py - approxMinY) / (iHeight * 0.6);
            d = clamp(d, 0.0, 1.0);
            // Canvas gradient smoothly interpolates both color and alpha
            // Stops: 0→(hlC,1.0) 0.05→(mainC,0.95) 0.2→(mainC,0.7) 0.5→(mainC,0.3) 1.0→(mainC,0)
            vec3 wc;
            float ga;
            if (d < 0.05) {
                float t2 = d / 0.05;
                wc = mix(hlC, mainC, t2);
                ga = mix(1.0, 0.95, t2);
            } else if (d < 0.2) {
                wc = mainC;
                ga = mix(0.95, 0.7, (d - 0.05) / 0.15);
            } else if (d < 0.5) {
                wc = mainC;
                ga = mix(0.7, 0.3, (d - 0.2) / 0.3);
            } else {
                wc = mainC;
                ga = mix(0.3, 0.0, (d - 0.5) / 0.5);
            }
            col = mix(col, wc, opa * ga);
        }

        // ── Glow (additive, along crest) ──
        if (showGlow > 0.5) {
            float gd = abs(py - wy);
            float gFreqL = wFreq[i] * 2.0;
            float gSpdL  = wSpd[i] * 0.5 * -wDir[i];
            float sv = sin(px * gFreqL + t * gSpdL + wPhase[i]);
            float gi = sv > 0.5 ? (sv - 0.5) * 2.0 : 0.0;
            float gw = 8.0 + gi * 8.0;
            if (gd < gw) {
                float fo = 1.0 - gd / gw;
                col += ecol * fo * (0.15 + gi * 0.25) * opa;
                float iw = 1.0 + gi * 3.0;
                if (gd < iw) {
                    col += glowCore.rgb * (1.0 - gd / iw) * (0.2 + gi * 0.4) * opa;
                }
            }
        }

        // ── Halo (additive, above crest) ──
        // JS: vertical gradient from (minY - maxHaloHeight) to (minY + 15)
        if (showHalo > 0.5) {
            float distAbove = wy - py;
            float hFreq = wFreq[i] * 1.5;
            float hSpdF = 0.7 + abs(sin(wPhase[i] * 10.0)) * 0.15;
            float hSpd  = wSpd[i] * hSpdF * -wDir[i];
            float hh = 10.0 + (sin(px * hFreq + t * hSpd + wPhase[i] * 2.0) * 0.5 + 0.5) * 40.0;
            // Halo visible both above crest and up to 15px below
            if (distAbove > -15.0 && distAbove < hh) {
                float maxHH = 50.0;
                float gradTop = approxMinY - maxHH;
                float gradBot = approxMinY + 15.0;
                float gradRange = gradBot - gradTop;
                float d = (py - gradTop) / gradRange;
                d = clamp(d, 0.0, 1.0);
                // stops: 0->0, 0.5->0.15, 0.8->0.25, 1.0->0.4
                float ha;
                if (d < 0.5) {
                    ha = mix(0.0, 0.15, d / 0.5);
                } else if (d < 0.8) {
                    ha = mix(0.15, 0.25, (d - 0.5) / 0.3);
                } else {
                    ha = mix(0.25, 0.4, (d - 0.8) / 0.2);
                }
                col += ecol * ha * opa;
            }
        }

        // ── Shine (narrow bright band near crest) ──
        // Vertical gradient from (minY - 15) to (minY + 5)
        // stops: 0->transparent, 0.5->effectColor(0.2), 1.0->white(0.15)
        if (showShine > 0.5) {
            float distAbove = wy - py;
            float sFreq = wFreq[i] * 2.5;
            float sSpd  = wSpd[i] * 0.4;
            float sh = 3.0 + (sin(px * sFreq + t * sSpd + wPhase[i] * 3.0) * 0.5 + 0.5) * 12.0;
            // Shine extends from sh pixels above crest to 5px below
            if (distAbove > -5.0 && distAbove < sh) {
                float gradTop = approxMinY - 15.0;
                float gradBot = approxMinY + 5.0;
                float d = clamp((py - gradTop) / (gradBot - gradTop), 0.0, 1.0);
                // stops: 0->0, 0.5->0.2(effectCol), 1.0->0.15(white)
                float sa;
                vec3 sc;
                if (d < 0.5) {
                    sa = mix(0.0, 0.2, d / 0.5);
                    sc = ecol;
                } else {
                    sa = mix(0.2, 0.15, (d - 0.5) / 0.5);
                    sc = mix(ecol, glowCore.rgb, (d - 0.5) / 0.5);
                }
                col += sc * sa * opa;
            }
        }

        // ── Spotlights (blinking bright patches along crest) ──
        // Bell-shaped patch above crest, filled with vertical gradient
        // gradient: (minY-maxH)→transparent, 60%→intensity*0.3, (minY+5)→intensity*0.5
        if (showSpotlights > 0.5) {
            float distAbove = wy - py; // positive = above crest
            if (distAbove > -5.0 && distAbove < 16.0) {
                int spotCount = int(iWidth / 200.0);
                for (int s = 0; s < 10; s++) {
                    if (s >= spotCount) {
                        break;
                    }
                    float seed = wPhase[i] * 100.0 + float(s) * 7.3;
                    float cx = (sin(seed) * 0.5 + 0.5) * iWidth;
                    float sw = 200.0 + (sin(seed * 1.3) * 0.5 + 0.5) * 100.0;
                    float dfc = abs(px - cx);
                    if (dfc > sw * 0.5) {
                        continue;
                    }

                    float bSpd = 0.012 + (sin(seed * 2.1) * 0.5 + 0.5) * 0.02;
                    float bVal = sin(t * bSpd + seed * 3.7);
                    if (bVal <= 0.2) {
                        continue;
                    }

                    float intensity = (bVal - 0.2) / 0.8;
                    float maxH = 6.0 + intensity * 9.0;

                    // localT: 0 at left edge, 0.5 at center, 1 at right edge
                    float localT = (px - cx + sw * 0.5) / sw;
                    float bell = sin(localT * PI) * maxH;

                    // Smooth bell mask instead of hard inside/outside test
                    float hFade = sin(localT * PI);
                    float mask = 0.0;
                    if (distAbove >= 0.0) {
                        // Above crest: smooth falloff at bell boundary
                        float softWidth = max(3.0, bell * 0.4);
                        mask = smoothstep(bell, bell - softWidth, distAbove);
                    } else {
                        // Below crest (up to 5px): smooth fade
                        mask = smoothstep(-5.0, 0.0, distAbove) * hFade;
                    }
                    if (mask <= 0.0) {
                        continue;
                    }

                    // Vertical gradient: 0 at top (maxH above), bright at crest+5
                    float gradRange = maxH + 5.0;
                    float gradD = clamp((maxH - distAbove) / gradRange, 0.0, 1.0);
                    float spotAlpha;
                    if (gradD < 0.6) {
                        spotAlpha = mix(0.0, intensity * 0.3, gradD / 0.6);
                    } else {
                        spotAlpha = mix(intensity * 0.3, intensity * 0.5, (gradD - 0.6) / 0.4);
                    }
                    col += spotColor.rgb * spotAlpha * mask * opa;
                }
            }
        }
    }

    // Clamp to avoid oversaturation from additive blending
    col = clamp(col, 0.0, 1.0);

    // Apply brightness dimming
    col *= dimLevel;

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
