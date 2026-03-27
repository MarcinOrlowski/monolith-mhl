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
    float filterSlot0;
    float filterSlot1;
    float filterSlot2;
    float filterSlot3;
    float filterSlot4;
    float filterSlot5;
    float filterSlot6;
};

layout(binding = 1) uniform sampler2D source;

// RGB <-> HSV conversion
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Phase 1: UV-warping filters transform sampling coordinates
// Filter IDs: 0=Pixelate, 6=CRT
void applyUvFilter(int id, inout vec2 uv, inout bool oob) {
    if (id == 0 && bool(showPixelate)) {
        // Pixelate: snap UV to grid
        vec2 grid = vec2(iWidth, iHeight) / pixelateSize;
        uv = floor(uv * grid) / grid;
    } else if (id == 6 && bool(showCrt)) {
        // CRT barrel distortion
        vec2 c = uv * 2.0 - 1.0;
        float curv = crtCurvature * 0.01;
        c *= 1.0 + curv * dot(c, c);
        uv = c * 0.5 + 0.5;
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
            oob = true;
        }
    }
}

// Phase 2: Color filters modify pixel color (sampled at final warped UV)
// Filter IDs: 1=Scanlines, 2=Chromatic, 3=ColorGrading, 4=HueShift, 5=RgbOffset, 6=CRT(vignette)
void applyColorFilter(int id, inout vec3 col, vec2 uv) {
    if (id == 1 && bool(showScanlines)) {
        // Scanlines
        float py = uv.y * iHeight;
        float scan = pow(0.5 + 0.5 * sin((py + iTime * scanlineSpeed) * scanlineFrequency), scanlineThickness);
        float band = (1.0 - scan) * scanlineIntensity;
        vec3 lineCol = vec3(scanlineColorR, scanlineColorG, scanlineColorB);
        vec3 darkened = col * (1.0 - band);
        vec3 colored = mix(col, lineCol, band);
        col = mix(darkened, colored, scanlineOpacity);
    } else if (id == 2 && bool(showChromatic)) {
        // Chromatic aberration
        vec2 cv = uv - 0.5;
        float dist2 = dot(cv, cv);
        float ca = dist2 * chromaticStrength;
        col.r *= 1.0 + ca;
        col.b *= 1.0 - ca;
        col = clamp(col, 0.0, 1.0);
    } else if (id == 3 && bool(showColorGrading)) {
        // Color grading
        col = pow(col, vec3(1.0 / cgGamma));
        col = (col - 0.5) * cgContrast + 0.5;
        col.r += cgTemperature * 0.01;
        col.b -= cgTemperature * 0.01;
        col.g += cgTint * 0.01;
        col = clamp(col, 0.0, 1.0);
    } else if (id == 4 && bool(showHueShift)) {
        // Hue shift
        vec3 hsv = rgb2hsv(col);
        hsv.x = fract(hsv.x + hueShiftAngle / 360.0);
        col = hsv2rgb(hsv);
    } else if (id == 5 && bool(showRgbOffset)) {
        // RGB offset (samples at warped UV ± offset)
        float rad = radians(rgbOffsetAngle);
        vec2 dir = vec2(cos(rad), sin(rad));
        vec2 off = dir * rgbOffsetAmount / vec2(iWidth, iHeight);
        col.r = texture(source, uv + off).r;
        col.b = texture(source, uv - off).b;
    } else if (id == 6 && bool(showCrt)) {
        // CRT vignette (barrel distortion already applied in UV phase)
        vec2 vig = uv * (1.0 - uv);
        float v = pow(vig.x * vig.y * 16.0, crtVignette * 0.01);
        col *= v;
    }
}

void main() {
    // Phase 1: accumulate UV warps
    vec2 uv = coord;
    bool oob = false;
    applyUvFilter(int(filterSlot0), uv, oob);
    applyUvFilter(int(filterSlot1), uv, oob);
    applyUvFilter(int(filterSlot2), uv, oob);
    applyUvFilter(int(filterSlot3), uv, oob);
    applyUvFilter(int(filterSlot4), uv, oob);
    applyUvFilter(int(filterSlot5), uv, oob);
    applyUvFilter(int(filterSlot6), uv, oob);

    // Out-of-bounds from CRT curvature → black
    if (oob) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0) * qt_Opacity;
        return;
    }

    // Sample once at final warped UV
    vec3 col = texture(source, uv).rgb;

    // Phase 2: color filters operate on the sampled result
    applyColorFilter(int(filterSlot0), col, uv);
    applyColorFilter(int(filterSlot1), col, uv);
    applyColorFilter(int(filterSlot2), col, uv);
    applyColorFilter(int(filterSlot3), col, uv);
    applyColorFilter(int(filterSlot4), col, uv);
    applyColorFilter(int(filterSlot5), col, uv);
    applyColorFilter(int(filterSlot6), col, uv);

    fragColor = vec4(col, 1.0) * qt_Opacity;
}
