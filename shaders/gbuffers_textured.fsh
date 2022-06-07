#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in  vec2 texcoord;
in  vec4 glcolor;

in  vec2 lmcoord;
in  vec3 normal;

in  vec3 viewPos;
in  vec3 viewPos_prev;
in  vec4 clipPos_prev;

in  vec3 alphaOffset;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 skyColor;

uniform sampler2D tex;
uniform sampler2D noisetex;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/lightmap.glsl"
#include "/util/taa.glsl"
#include "/util/distanceFade.glsl"
#include "/util/stochastic_transparency.glsl"
#include "/surface/diffuse.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 0,1,3 */ 

void main() {
    float dist = length(viewPos);
    distanceFade(dist);
    vec4 albedo = texture(tex, texcoord) * glcolor;
    vec3 lightmap = lm2rgb(lmcoord, 1.0, skyColor, dist);
    
    vec3 col = shadeDiffuse(albedo.rgb, lightmap, normal);

    float threshold = getThreshold(noisetex, alphaOffset, frameCounter);
    if (albedo.a < 1.0) {
        albedo.a *= 15 / 16.0;
    }
    float alpha = albedo.a > threshold ? 1.0 : 0.0;

    gl_FragData[0] = vec4(col, alpha);
    gl_FragData[1] = vec4(vec3(dist), alpha);

    vec3 offset = getOffset(clipPos_prev, dist, length(viewPos_prev));
    gl_FragData[2] = vec4(offset, alpha);
}

// Helper implementations ------------------------------------------------------------------------