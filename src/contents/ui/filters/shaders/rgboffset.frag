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
    float rgbOffsetAmount;
    float rgbOffsetAngle;
};

layout(binding = 1) uniform sampler2D source;

void main() {
    float rad = radians(rgbOffsetAngle);
    vec2 dir = vec2(cos(rad), sin(rad));
    vec2 off = dir * rgbOffsetAmount / vec2(iWidth, iHeight);

    vec3 col;
    col.r = texture(source, coord + off).r;
    col.g = texture(source, coord).g;
    col.b = texture(source, coord - off).b;

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
