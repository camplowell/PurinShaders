#version 150 compatibility
#define COMPOSITE
#define VERTEX

out vec2 globalTexCoord;
out vec3 eyePlayerPos;
out vec3 sunDir;

out vec3 sunCol;
out vec4 lmSkyCol;

out float MIE_FALLOFF;
out float MIE_DENSITY;
out float mieIsotropy;
out vec3 rayleighCol;
out vec3 mieCol;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform float eyeAltitude;
uniform float rainStrength;

#include "/settings/shadow.glsl"
uniform int worldTime;

uniform float near;
uniform float far;

vec2 texcoord;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/settings/lighting.glsl"

#define EYE_PLAYER_POS
#include "/lib/util/spaceConversion.glsl"

#define SUN_DIR_EARLY
#include "/lib/lighting/lightColor.glsl"

#include "/lib/volumetrics/world0_fog.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
   texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
   
   resolveSpaceConversions(1.0);
   resolveSunDir();

   sunCol = mixByTime(SUN_COL_MORN, SUN_COL_DAY, SUN_COL_EVE, vec3(0.0));
   lmSkyCol =  mixByTime(LM_SKY_MORN, LM_SKY_DAY, LM_SKY_EVE, LM_SKY_NIGHT);

   resolveSkyParams();

   gl_Position = ftransform();
   globalTexCoord = texcoord;
}