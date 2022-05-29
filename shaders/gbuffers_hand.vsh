#version 410 compatibility
#define VERTEX

// ===============================================================================================
// Variables
// ===============================================================================================

out vec2 texcoord;
out vec4 glcolor;

out vec2 lmcoord;
out vec3 normal;

out vec3 viewPos;
out vec4 clipPos_prev;

in vec3 at_velocity;

// Uniforms --------------------------------------------------------------------------------------

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

void main() {
    viewPos = model2view();
    vec3 viewPos_prev = viewPos - at_velocity;
    gl_Position = view2clip(viewPos, gl_ProjectionMatrix);
    clipPos_prev = view2clip(viewPos_prev, gl_ProjectionMatrix);
    gl_Position = jitter(gl_Position);

    texcoord = modelTexcoord();
    glcolor = gl_Color;

    lmcoord = modelLmcoord();
    normal = view2eye(modelNormal());
}

// Helper implementations ------------------------------------------------------------------------