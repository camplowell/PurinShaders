#version 150 compatibility

out vec4 glcolor;

// ===============================================================================================
// Global variables
// ===============================================================================================

//uniform int renderStage;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;

uniform float near;
uniform float far;

vec3 sunDir;
vec3 eyePlayerPos;

// ===============================================================================================
// Includes
// ===============================================================================================

#define EYE_PLAYER_POS
#include "/lib/util/spaceConversion.glsl"

#include "/lib/lighting/lightColor.glsl"
#include "/settings/overworld_sky.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
   /*
   if (renderStage == MC_RENDER_STAGE_STARS) {
      gl_Position = ftransform();
   } else {
      gl_Position = vec4(-1.0, -1.0, -1.0, 0.0);
   }
   */
   gl_Position = vec4(-1.0, -1.0, -1.0, 0.0);

   resolveSpaceConversions();

   glcolor = gl_Color;
   vec3 eyeDir = normalize(eyePlayerPos);

   vec3 falloff = vec3(0.2, 0.4, 1.0) * 0.02;

   glcolor.rgb *= 2. * (1. - falloff / (eyeDir.y * eyeDir.y + falloff)) * float(eyeDir.y > 0.0);
}