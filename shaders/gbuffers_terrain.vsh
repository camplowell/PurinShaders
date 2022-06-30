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

in vec3 mc_Entity;
in vec2 mc_midTexCoord;

// Uniforms --------------------------------------------------------------------------------------

uniform vec3 upPosition;

uniform float frameTimeCounter;
uniform float frameTime;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/panini.glsl"
#include "/util/taa.glsl"
#include "/util/wavyLeaves.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

// Main ------------------------------------------------------------------------------------------

void main() {
    viewPos = model2view();
    vec3 feetPos = view2feet(viewPos);
    vec3 feetPos_prev = feet2prev(feetPos);

    texcoord = modelTexcoord();
    glcolor = vec4(gl_Color.rgb, 1.0);
    ao = gl_Color.a;

    // Wavy blocks
#ifdef WAVY_LEAVES
    feetPos = wave(feetPos, frameTimeCounter, texcoord, mc_midTexCoord, mc_Entity);
    feetPos_prev = wave(feetPos_prev, frameTimeCounter - frameTime, texcoord, mc_midTexCoord, mc_Entity);
#endif
    // Bring back to view space
    viewPos = feet2view(feetPos);
    viewPos_prev = feet2view(feetPos_prev, gbufferPreviousModelView);

    vec3 up_prev = 100 * eye2view(vec3(0, 1, 0), gbufferPreviousModelView);
    clipPos_prev = panini(viewPos_prev, up_prev);
    
    gl_Position = panini(viewPos, upPosition);
    gl_Position = jitter(gl_Position);

    

    lmcoord = modelLmcoord();
    normal = view2eye(modelNormal());
}

// Helper implementations ------------------------------------------------------------------------