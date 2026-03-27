#version 440

/***********************************************************************
 *
 * Monolith MHL: Beautiful animated wallpapers for Plasma 6
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright ©2026 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/monolith-mhl
 *
 **********************************************************************/

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    vec2 resolution;
    float threshold;

    // Metaball gradient colors
    vec3 baseColor;
    vec3 gradientColor1;
    vec3 gradientColor2;
    vec3 gradientColor3;
    vec3 gradientColor4;

    // Background gradient colors
    vec3 backgroundGradientColor1;
    vec3 backgroundGradientColor2;
    vec3 backgroundGradientColor3;
    vec3 backgroundGradientColor4;

    // Glow parameters
    float glowIntensity;
    float glowInnerThreshold;
    float glowMidThreshold;
    float glowOuterThreshold;
    float glowMinFieldStrength;

    int gradientMode;
    int backgroundGradientEnabled;
    int glowEffectEnabled;
    int metaballCount;

    // CPU-computed metaball positions packed into mat4s (4 metaballs per mat4)
    mat4 metaballData0;
    mat4 metaballData1;
    mat4 metaballData2;
    mat4 metaballData3;
    mat4 metaballData4;
    mat4 metaballData5;
    mat4 metaballData6;
    mat4 metaballData7;
    mat4 metaballData8;
    mat4 metaballData9;
    mat4 metaballData10;
    mat4 metaballData11;
    mat4 metaballData12;
    mat4 metaballData13;
    mat4 metaballData14;
    mat4 metaballData15;
    mat4 metaballData16;
    mat4 metaballData17;
};

// Calculate gradient color based on position and gradient mode
// gradientMode: 0=vertical, 1=four_corner, 2=rainbow
vec3 calculateGradientColor(float x, float y) {
    float u = x / resolution.x;
    float v = y / resolution.y;

    if (gradientMode == 0) {
        return mix(gradientColor1, gradientColor2, v);
    }
    else if (gradientMode == 1) {
        vec3 topColor = mix(gradientColor1, gradientColor2, u);
        vec3 bottomColor = mix(gradientColor3, gradientColor4, u);
        return mix(topColor, bottomColor, v);
    }
    else {
        return vec3(u, v, 1.0) * baseColor;
    }
}

// Calculate background gradient color at given position
vec3 calculateBackgroundGradientColor(float x, float y) {
    float u = x / resolution.x;
    float v = y / resolution.y;

    if (gradientMode == 0) {
        return mix(backgroundGradientColor1, backgroundGradientColor2, v);
    }
    else if (gradientMode == 1) {
        vec3 topColor = mix(backgroundGradientColor1, backgroundGradientColor2, u);
        vec3 bottomColor = mix(backgroundGradientColor3, backgroundGradientColor4, u);
        return mix(topColor, bottomColor, v);
    }
    else {
        return vec3(u, v, 1.0) * baseColor;
    }
}

vec3 getMetaball(int index) {
    int matIdx = index / 4;
    int colIdx = index - matIdx * 4;
    vec4 col = vec4(0.0);
    if (matIdx == 0) col = metaballData0[colIdx];
    else if (matIdx == 1) col = metaballData1[colIdx];
    else if (matIdx == 2) col = metaballData2[colIdx];
    else if (matIdx == 3) col = metaballData3[colIdx];
    else if (matIdx == 4) col = metaballData4[colIdx];
    else if (matIdx == 5) col = metaballData5[colIdx];
    else if (matIdx == 6) col = metaballData6[colIdx];
    else if (matIdx == 7) col = metaballData7[colIdx];
    else if (matIdx == 8) col = metaballData8[colIdx];
    else if (matIdx == 9) col = metaballData9[colIdx];
    else if (matIdx == 10) col = metaballData10[colIdx];
    else if (matIdx == 11) col = metaballData11[colIdx];
    else if (matIdx == 12) col = metaballData12[colIdx];
    else if (matIdx == 13) col = metaballData13[colIdx];
    else if (matIdx == 14) col = metaballData14[colIdx];
    else if (matIdx == 15) col = metaballData15[colIdx];
    else if (matIdx == 16) col = metaballData16[colIdx];
    else if (matIdx == 17) col = metaballData17[colIdx];
    return col.xyz;
}

void main() {
    float x = qt_TexCoord0.x * resolution.x;
    float y = (1.0 - qt_TexCoord0.y) * resolution.y;

    float sum = 0.0;

    for (int i = 0; i < metaballCount; i++) {
        vec3 metaball = getMetaball(i);
        float dx = metaball.x - x;
        float dy = metaball.y - y;
        float radius = metaball.z;
        float rSq = radius * radius;

        float distSq = dx * dx + dy * dy;

        // Skip metaballs too far to contribute meaningfully (contribution < 0.001)
        if (distSq > rSq * 1000.0) continue;

        if (distSq > 0.0) {
            sum += rSq / distSq;
        }
    }

    // Gradient colors computed once, reused in all paths
    vec3 bgColor = backgroundGradientEnabled != 0 ?
        calculateBackgroundGradientColor(x, y) :
        vec3(0.0, 0.0, 0.0);
    vec3 colorBase = calculateGradientColor(x, y);

    if (glowEffectEnabled != 0) {
        float fieldStrength = min(1.0, sum * glowIntensity / 10.0);

        if (sum >= threshold) {
            fragColor = vec4(colorBase, 1.0) * qt_Opacity;
        }
        else if (fieldStrength > glowMinFieldStrength) {
            vec3 glowColor = vec3(0.0);
            float alpha = 1.0;

            if (fieldStrength >= glowInnerThreshold) {
                glowColor = colorBase * 0.8;
                alpha = 0.8;
            }
            else if (fieldStrength >= glowMidThreshold) {
                float fade = (fieldStrength - glowMidThreshold) / (glowInnerThreshold - glowMidThreshold);
                glowColor = mix(colorBase * 0.4, colorBase * 0.8, fade);
                alpha = mix(0.4, 0.8, fade);
            }
            else if (fieldStrength >= glowOuterThreshold) {
                float fade = (fieldStrength - glowOuterThreshold) / (glowMidThreshold - glowOuterThreshold);
                glowColor = mix(colorBase * 0.1, colorBase * 0.4, fade);
                alpha = mix(0.2, 0.4, fade);
            }
            else {
                float fade = fieldStrength / glowOuterThreshold;
                glowColor = colorBase * 0.1 * fade;
                alpha = 0.2 * fade;
            }

            // Blend glow over background gradient
            vec3 blended = mix(bgColor, glowColor, alpha);
            fragColor = vec4(blended, 1.0) * qt_Opacity;
        } else {
            fragColor = vec4(bgColor, 1.0) * qt_Opacity;
        }
    } else {
        if (sum >= threshold) {
            float fade = max(0.0, 1.0 - (sum - threshold) * 100.0);
            vec3 finalColor = mix(colorBase, bgColor, fade);
            fragColor = vec4(finalColor, 1.0) * qt_Opacity;
        } else {
            fragColor = vec4(bgColor, 1.0) * qt_Opacity;
        }
    }
}
