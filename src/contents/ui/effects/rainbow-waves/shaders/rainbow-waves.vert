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

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;

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

layout(location = 0) out vec2 coord;

void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
