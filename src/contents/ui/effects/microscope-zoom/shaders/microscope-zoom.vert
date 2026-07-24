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
    float density;
    float dimLevel;
    float cellColorR;
    float cellColorG;
    float cellColorB;
    float mediumColorR;
    float mediumColorG;
    float mediumColorB;
    float illumColorR;
    float illumColorG;
    float illumColorB;
    float showFog;
    float showRays;
    float showParticles;
    float showVignette;
    float particleCount;
    float particleSize;
    float rotationAngle;
    float microbeMotion;
};

layout(location = 0) out vec2 coord;

void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
