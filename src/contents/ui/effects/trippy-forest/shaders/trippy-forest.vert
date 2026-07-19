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
    float rotTime;
    float whirlTime;
    float showFoliage;
    float showGlow;
    float showVortex;
    float showStars;
    float showBeams;
    float spiral;
    float density;
    float glowAmount;
    float mistAmount;
    float fog;
    float starCount;
    float starSpeed;
    float starLength;
    float starOpacity;
    float beamCount;
    float beamSpeed;
    float beamLength;
    float beamOpacity;
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

layout(location = 0) out vec2 coord;

void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
