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
out vec3 viewPos_prev;
out vec4 clipPos_prev;

out float blockId;
out vec3 alphaOff;

in vec3 mc_Entity;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 upPosition;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/panini.glsl"
#include "/util/taa.glsl"
#include "/util/stochastic_transparency.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

void main() {
    viewPos = model2view();
    viewPos_prev = view2prev(viewPos);
    gl_Position = panini(viewPos, upPosition);
    gl_Position = jitter(gl_Position);
    
    vec3 up_prev = 100 * eye2view(vec3(0, 1, 0), gbufferPreviousModelView);
    clipPos_prev = panini(viewPos_prev, up_prev);

    texcoord = modelTexcoord();
    glcolor = vec4(gl_Color.rgb, 1.0);
    ao = gl_Color.a;

    lmcoord = modelLmcoord();
    vec3 viewNormal = modelNormal();
    normal = view2eye(viewNormal);

    blockId = mc_Entity.x;
    alphaOff = getAlphaOffset(viewNormal, viewPos);
}

// Helper implementations ------------------------------------------------------------------------