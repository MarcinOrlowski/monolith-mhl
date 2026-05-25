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
    float spacing;
    float dotRadius;
    float maxAlpha;
    float density;
    float contrast;
    float dimLevel;
    float dotColorR;
    float dotColorG;
    float dotColorB;
    float bgColorR;
    float bgColorG;
    float bgColorB;
};

// Two slow sin/cos waves -> organic moving brightness field, indexed by grid
// cell (not pixel). density sets a cutoff: only the brightest `density` fraction
// of the wave shows; the rest stays dark. contrast softens the lit/unlit edge.
float field(float x, float y, float t) {
    float w1 = sin(x * 0.16 + t * 0.6) * cos(y * 0.13 - t * 0.4);
    float w2 = sin((x + y) * 0.09 + t * 0.8);
    float v = ((w1 + w2) * 0.5 + 1.0) * 0.5;   // 0..1
    float thr = 1.0 - density;                  // cutoff
    if (v <= thr) return 0.0;
    return pow((v - thr) / (1.0 - thr), contrast);
}

void main() {
    vec2 fragPx = coord * vec2(iWidth, iHeight);

    // Match the canvas grid: centered, ceil(size/spacing)+1 dots per axis.
    float cols = ceil(iWidth / spacing) + 1.0;
    float rows = ceil(iHeight / spacing) + 1.0;
    float offX = (iWidth - (cols - 1.0) * spacing) * 0.5;
    float offY = (iHeight - (rows - 1.0) * spacing) * 0.5;

    // Nearest grid cell to this pixel (dot spacing >> dot radius, so one dot wins).
    float ix = clamp(floor((fragPx.x - offX) / spacing + 0.5), 0.0, cols - 1.0);
    float iy = clamp(floor((fragPx.y - offY) / spacing + 0.5), 0.0, rows - 1.0);

    float v = field(ix, iy, iTime);

    vec2 center = vec2(offX + ix * spacing, offY + iy * spacing);
    float dist = distance(fragPx, center);
    float radius = dotRadius * (0.7 + v * 0.6);

    float aa = 0.75;
    float coverage = 1.0 - smoothstep(radius - aa, radius + aa, dist);
    float alpha = maxAlpha * v * coverage;

    vec3 bg = vec3(bgColorR, bgColorG, bgColorB);
    vec3 dot = vec3(dotColorR, dotColorG, dotColorB);
    vec3 col = mix(bg, dot, alpha) * dimLevel;

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
