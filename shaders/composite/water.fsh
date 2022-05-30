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

uniform int isEyeInWater;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/lightmap.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 0 */ 

void main() {
    vec3 col = texelFetch(colortex0, ivec2(gl_FragCoord.xy), 0).rgb;
    float depth = texelFetch(colortex1, ivec2(gl_FragCoord.xy), 0).x;
    float waterDepth = texelFetch(colortex2, ivec2(gl_FragCoord.xy), 0).x;
    float opticalDepth = 0.0;
    if (isEyeInWater == 0 && waterDepth < depth) {
        opticalDepth = 0.0625 * (depth - waterDepth + 4);
    } else if (isEyeInWater == 1) {
        opticalDepth = 0.0625 * min(depth, waterDepth);
    }
    vec3 absorption = pow(vec3(0.4, 0.8, 0.9), vec3(opticalDepth));
    vec3 scattering = vec3(0.05, 0.1, 0.2) * (1.0 - exp(-opticalDepth));
    col = col * absorption + scattering * getSkyLight(skyColor, 1.0);
    
    gl_FragData[0] = vec4(col, 1.0);
}

// Helper implementations ------------------------------------------------------------------------