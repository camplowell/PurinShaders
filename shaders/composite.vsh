#version 150 compatibility
#define COMPOSITE
#define VERTEX

out vec2 texcoord;

out vec3 sunDir;
out vec3 sunCol;
out vec3 moonCol;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/lib/lighting/lightColor.glsl"
#include "/settings/lighting.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
   gl_Position = ftransform();
   texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

   resolveSunDir();
   sunCol = mixByTime(SUN_COL_MORN, SUN_COL_DAY, SUN_COL_EVE, vec3(0.0));
   moonCol = MOON_COL;
}