#version 150 compatibility
#define COMPOSITE
#define FRAGMENT

in  vec2 globalTexCoord;
in  vec3 sunDir;

in  vec3 sunCol;
in  vec4 lmSkyCol;

in  float MIE_FALLOFF;
in  float MIE_DENSITY;
in  float mieIsotropy;
in  vec3 rayleighCol;
in  vec3 mieCol;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform float eyeAltitude;

uniform float near;
uniform float far;

uniform int worldTime;
uniform float rainStrength;

vec3 eyePlayerPos;
vec2 texcoord;

// ===============================================================================================
// Includes
// ===============================================================================================

#define EYE_PLAYER_POS
#include "/lib/util/spaceConversion.glsl"

#include "/settings/lighting.glsl"
#include "/lib/volumetrics/world0_fog.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:4 */

void main() {
   texcoord = fract(globalTexCoord * 8);
   ivec2 layerIndex = ivec2(floor(globalTexCoord * 8) + vec2(1, 0));

   float layerDepth = (layerIndex.x + 8.0 * layerIndex.y) / (8.0 * 8.0);

   resolveSpaceConversions(layerDepth);

   vec3 viewDir = normalize(eyePlayerPos);

   eyePlayerPos = viewDir * layerDepth * far;

   gl_FragData[0] = getFog();
   //gl_FragData[0] = vec4(vec3(eyePlayerPos), 1.0);
}