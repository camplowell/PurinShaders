#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in  vec2 texcoord;

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform vec3 skyColor;
uniform vec3 fogColor;
uniform vec3 upPosition;

uniform int isEyeInWater;

uniform float eyeAltitude;
uniform int worldTime;
uniform ivec2 eyeBrightnessSmooth;

uniform vec3 sunPosition;
uniform float rainStrength;
uniform float wetness;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/panini.glsl"
#include "/util/lightmap.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

vec3 waterFog(vec3 col, vec3 skyLight, float opticalDepth);
vec3 skyFog(vec3 col, vec3 skyLight, vec3 viewDir, float enter, float exit);

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 0 */ 

void main() {
    vec3 col = texelFetch(colortex0, ivec2(gl_FragCoord.xy), 0).rgb;
    float depth = texelFetch(colortex1, ivec2(gl_FragCoord.xy), 0).x;
    float waterDepth = texelFetch(colortex2, ivec2(gl_FragCoord.xy), 0).x;
    vec3 viewDir = normalize(paniniInverse(vec3(texcoord * 2 - 1, 1.0), upPosition));
    viewDir = view2eye(viewDir);

    vec3 skyLight = getSkyLight(skyColor, 1.0);
    int transition = 32;
    if (eyeAltitude + depth * viewDir.y < 63 + transition && depth > far) {
        col = mix(vec3(0.18) * skyLight, col, smoothstep(63 - transition, 63 + transition, eyeAltitude + depth * viewDir.y));
    }
    
    if (isEyeInWater == 0) {
        // Air -> water
        if (waterDepth < depth) {
            float opticalDepth = WATER_DENSITY * (depth - waterDepth + 4);
            col = waterFog(col, skyLight, opticalDepth);
        }
        col = skyFog(col, skyLight, viewDir, 0, min(waterDepth, depth));
    } else if (isEyeInWater == 1) {
        // water -> Air
        if (waterDepth < depth) {
            col = skyFog(col, skyLight, viewDir, waterDepth, depth);
        }
        float opticalDepth = WATER_DENSITY * min(depth, waterDepth);
        col = waterFog(col, skyLight, opticalDepth);
    } else {
        vec3 eyeLight = lm2rgb(eyeBrightnessSmooth / 240.0, 1.0, skyColor, 0.0);
        // In a dense medium (fixed fog color, opaque block borders)
        col = mix(fogColor * eyeLight, col, exp(-4 * depth));
    }
    
    gl_FragData[0] = vec4(col, 1.0);
}

// Helper implementations ------------------------------------------------------------------------

vec3 waterFog(vec3 col, vec3 skyLight, float opticalDepth) {
    vec3 absorption = pow(vec3(0.4, 0.8, 0.9), vec3(opticalDepth));
    vec3 scattering = vec3(0.05, 0.1, 0.2) * (1.0 - exp(-opticalDepth));
    return col * absorption + scattering * skyLight;
}

float getAvgDensity(float yStart, float yEnd, float falloff) {
    float yMin = min(yStart, yEnd) / falloff;
    float yMax = max(yStart, yEnd) / falloff;
    if (yMax <= 0) {
        return 1.0;
    }
    float weight = 0.0;
    if (yMin < 0.0) {
        weight = -yMin / (yMax - yMin);
        yMin = 0.0;
    }
    if (yMin == yMax) {
        return exp(-yMin);
    }
    return mix((exp(-yMin) - exp(-yMax)) / (yMax - yMin), 1.0, weight);
}
/*
vec3 skyTonemap(vec3 col) {
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    return col * lum / (1 + lum * lum);
}
*/
vec3 screen(vec3 albedo, vec3 lighting, vec3 fac) {
    lighting *= 1.0 - fac;
    float lum = dot(lighting, vec3(0.299, 0.587, 0.114));
    return (lighting * lum + albedo) / (1 + lum * lum);
    //return 1 - ((1 - albedo * fac) / (1.0 + lighting * (1.0 - fac)));
}

vec3 skyFog(vec3 col, vec3 skyLight, vec3 viewDir, float enter, float exit) {
    // Trim depth
    if (eyeAltitude > 63 && exit >= far && viewDir.y < 0) {
        exit = min(exit, (63 - eyeAltitude) / viewDir.y);
    }
    float depth = (exit - enter);
    // Calculate the elevations of ray endpoints
    float yStart = (eyeAltitude + enter * viewDir.y) - 63;
    float yEnd = (eyeAltitude + exit * viewDir.y) - 63;

    //Calculate fog color
    vec3 sunDir = 0.01 * view2eye(sunPosition);
    vec3 sunCol = mix(mixByTime(SUN_COL, worldTime), vec3(0.5), rainStrength);
    vec3 moonCol = mix(MOON_COL, vec3(1.0), rainStrength);

    float skyVisibility = eyeBrightnessSmooth.y / 240.0;
    sunCol *= smoothstep(-0.08, 0.02, sunDir.y) * skyVisibility;
    moonCol *= smoothstep(-0.08, 0.02, -sunDir.y) * skyVisibility;
    vec3 horizonCol = moonCol * 0.33 + sunCol + skyLight;

    
    sunCol *= pow(dot(viewDir, sunDir) * 0.5 + 0.5, 3) * 3;
    moonCol *= pow(max(dot(viewDir, -sunDir), 0), 2) * 0.25;
    vec3 fogCol = (sunCol + moonCol) * mix(1.0, 0.25, rainStrength) 
        + horizonCol;

    // Calculate fog strength
    float groundFogDensity = 0.05 * mix(
        mixByTime(GROUND_FOG, worldTime), 
        GROUND_FOG_RAIN, 
        rainStrength
    );
    float fogDensity = 0.05 * mix(
        mixByTime(FOG, worldTime),
        FOG_RAIN,
        rainStrength
    );
    float mistDepth = getAvgDensity(yStart, yEnd, 8.0) * groundFogDensity * depth;
    float mieDepth = getAvgDensity(yStart, yEnd, 128.0) * fogDensity * depth;
    // mist becomes foggy when it rains
    mistDepth += max(rainStrength, wetness) * mieDepth;
    mieDepth *= (1.0 - max(rainStrength, wetness));

    vec3 atmFac = exp(-(mistDepth + mieDepth * vec3(0.25, 0.5, 1.0)));
    return screen(col, fogCol, atmFac); //skyTonemap((1 - atmFac) * fogCol) + col * atmFac;
}
