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
    float showScanlines;
    float scanlineIntensity;
    float scanlineFrequency;
    float scanlineThickness;
    float scanlineSpeed;
    float scanlineColorR;
    float scanlineColorG;
    float scanlineColorB;
    float scanlineOpacity;
    float showChromatic;
    float chromaticStrength;
    float showColorGrading;
    float cgGamma;
    float cgContrast;
    float cgTemperature;
    float cgTint;
    float showHueShift;
    float hueShiftAngle;
    float showPixelate;
    float pixelateSize;
    float showRgbOffset;
    float rgbOffsetAmount;
    float rgbOffsetAngle;
    float showCrt;
    float crtCurvature;
    float crtVignette;
    float showMask;
    float maskSide;
    float maskPadding;
    float maskInvert;
    float maskColorR;
    float maskColorG;
    float maskColorB;
    float showMaskSpark;
    float maskSparkRadius;
    float maskSparkThreshold;
    float maskSparkStrength;
    float filterSlot0;
    float filterSlot1;
    float filterSlot2;
    float filterSlot3;
    float filterSlot4;
    float filterSlot5;
    float filterSlot6;
};

layout(location = 0) out vec2 coord;

void main() {
    coord = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex;
}
