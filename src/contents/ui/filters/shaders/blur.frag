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
    float iWidth;
    float iHeight;
    float blurRadius;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 px = vec2(1.0 / iWidth, 1.0 / iHeight) * blurRadius;
    float sigma = 2.0;

    vec3 col = vec3(0.0);
    float total = 0.0;

    // 5x5 Gaussian kernel (25 taps)
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            float d = float(x * x + y * y);
            float w = exp(-d / (2.0 * sigma * sigma));
            col += texture(source, coord + vec2(float(x), float(y)) * px).rgb * w;
            total += w;
        }
    }

    fragColor = vec4(col / total, 1.0) * qt_Opacity;
}
