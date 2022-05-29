#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in  vec2 texcoord;
in  vec4 glcolor;

in  vec2 lmcoord;
in  vec3 normal;
in  float ao;

in  vec3 viewPos;
in  vec4 clipPos_prev;

in  vec3 alphaOff;

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
#include "/util/stochastic_transparency.glsl"
#include "/surface/diffuse.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 0,1,3 */ 

void main() {
    if (viewPos.z > -near) {
        discard;
    }
    float dist = length(viewPos);
    vec4 albedo = texture(tex, texcoord) * glcolor;
    vec3 lightmap = lm2rgb(lmcoord, ao, skyColor, dist);
    

    vec3 col = shadeDiffuse(albedo.rgb, lightmap, normal);

    float threshold = getThreshold(noisetex, alphaOff, frameCounter);
    float alpha = albedo.a >= threshold ? 1.0 : 0.0;

    gl_FragData[0] = vec4(col, alpha);
    gl_FragData[1] = vec4(vec3(dist), alpha);

    vec2 offset = getOffset(clipPos_prev);
    gl_FragData[2] = vec4(offset, 0, alpha);
}

// Helper implementations ------------------------------------------------------------------------