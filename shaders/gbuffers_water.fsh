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

in  float blockId;
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
#include "/util/distanceFade.glsl"
#include "/util/stochastic_transparency.glsl"
#include "/surface/diffuse.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 0,1,2,3 */ 

void main() {
    vec4 albedo = texture(tex, texcoord) * vec4(1, 1, 1, glcolor.a);
    float dist = length(viewPos);
    if (viewPos.z > -near || albedo.a == 0) {
        discard;
    }
    vec3 lightmap = lm2rgb(lmcoord, ao, skyColor, dist);
    vec3 ambient = getAmbient(dist, ao);

    float threshold = getThreshold(noisetex, alphaOff, frameCounter);
    float alpha = albedo.a >= threshold ? 1.0 : 0.0;
    float isWater = int(blockId + 0.5) == 257 ? 1.0 : 0.0;
    if (int(blockId + 0.5) == 257) {
        float waterFac = clamp((albedo.r - 0.5) / 0.5, 0, 1);
        alpha = waterFac > threshold ? 1.0 : 0.0;
        albedo.rgb = mix(albedo.rgb * glcolor.rgb, vec3(1.0),  waterFac);
    } else {
        albedo.rgb *= glcolor.rgb;
    }

    vec3 col = shadeDiffuse(albedo.rgb, lightmap, normal, ambient);

    float fade = distanceFade(dist);
    alpha *= fade;
    isWater *= fade;

    gl_FragData[0] = vec4(col, alpha);
    gl_FragData[1] = vec4(vec3(dist), alpha);
    gl_FragData[2] = vec4(vec3(dist), isWater);

    vec3 offset = getOffset(clipPos_prev, dist, length(viewPos_prev));
    gl_FragData[3] = vec4(offset, alpha);
}

// Helper implementations ------------------------------------------------------------------------