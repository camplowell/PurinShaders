#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in  vec2 texcoord;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 skyColor;
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

/* RENDERTARGETS: 0,3 */ 

void main() {
    vec3 ndc = vec3(texcoord, 1.0) * 2 - 1;
    vec3 viewPos = paniniInverse(ndc, upPosition);
    vec3 view_prev = feet2view(view2feet(viewPos), gbufferPreviousModelView);

    vec4 clipPos_prev = panini(view_prev, upPosition);
    vec2 screenPos_prev = (clipPos_prev.xy / clipPos_prev.w);
    vec2 offset = getOffset(clipPos_prev, viewWidth, viewHeight);
    
    gl_FragData[0] = vec4(skyColor, 1.0);
    gl_FragData[1] = vec4(offset, 0, 1.0);
}

// Helper implementations ------------------------------------------------------------------------