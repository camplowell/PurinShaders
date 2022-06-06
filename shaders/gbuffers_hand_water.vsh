#version 410 compatibility
#define VERTEX

// ===============================================================================================
// Variables
// ===============================================================================================

out vec2 texcoord;
out vec4 glcolor;

out vec2 lmcoord;
out vec3 normal;
out float ao;

out vec3 viewPos;
out vec4 clipPos_prev;

out vec3 alphaOff;

in  vec3 at_velocity;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 upPosition;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/taa.glsl"
#include "/util/stochastic_transparency.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

void main() {
    viewPos = model2view();
    vec3 viewPos_prev = viewPos - at_velocity;
    gl_Position = view2clip(viewPos, gl_ProjectionMatrix);
    clipPos_prev = view2clip(viewPos_prev, gl_ProjectionMatrix);
    gl_Position = jitter(gl_Position);

    texcoord = modelTexcoord();
    glcolor = vec4(gl_Color.rgb, 1.0);
    ao = gl_Color.a;

    lmcoord = modelLmcoord();
    vec3 viewNormal = modelNormal();
    normal = view2eye(viewNormal);

    alphaOff = getAlphaOffset(viewNormal, viewPos);
}

// Helper implementations ------------------------------------------------------------------------