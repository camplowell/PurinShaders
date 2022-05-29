#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in  vec2 texcoord;
in  vec4 glcolor;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 skyColor;
uniform sampler2D tex;

uniform vec3 upPosition;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/panini.glsl"
#include "/util/taa.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 0,1,3 */ 

void main() {
    vec3 screenPos = gl_FragCoord.xyz / vec3(viewWidth, viewHeight, 1.0);
    vec3 ndc = screen2ndc(screenPos);
    vec3 viewPos = paniniInverse(ndc, upPosition);
    /*
    if (viewPos.z > -near) {
        discard;
    }
    */
    vec4 albedo = texture(tex, texcoord) * glcolor;

    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(vec3(length(viewPos)), albedo.a > 0.5);

    vec3 viewPos_prev = view2prev(viewPos);
    vec4 clipPos_prev = panini(viewPos_prev, upPosition);
    vec2 offset = getOffset(clipPos_prev);
    
    gl_FragData[2] = vec4(offset, 0, 1);
}

// Helper implementations ------------------------------------------------------------------------