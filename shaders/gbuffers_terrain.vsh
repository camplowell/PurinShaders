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
    vec3 viewPos_prev = view2prev(viewPos);
    clipPos_prev = panini(viewPos_prev, upPosition);
    gl_Position = panini(viewPos, upPosition);
    gl_Position = jitter(gl_Position);

    texcoord = modelTexcoord();
    glcolor = vec4(gl_Color.rgb, 1.0);
    ao = gl_Color.a;

    lmcoord = modelLmcoord();
    normal = view2eye(modelNormal());
}

// Helper implementations ------------------------------------------------------------------------