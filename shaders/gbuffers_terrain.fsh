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
in  vec3 viewPos_prev;
in  vec4 clipPos_prev;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 skyColor;
uniform sampler2D tex;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/lightmap.glsl"
#include "/util/taa.glsl"
#include "/util/distanceFade.glsl"
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
    
    albedo.a *= distanceFade(dist);

    vec3 col = shadeDiffuse(albedo.rgb, lightmap, normal);

    gl_FragData[0] = vec4(col, albedo.a);
    gl_FragData[1] = vec4(vec3(dist), albedo.a);

    vec3 offset = getOffset(clipPos_prev, dist, length(viewPos_prev));
    gl_FragData[2] = vec4(offset, albedo.a);
}

// Helper implementations ------------------------------------------------------------------------