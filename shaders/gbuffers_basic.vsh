#version 150 compatibility
#define VERTEX

out vec4 glcolor;

out vec2 lmcoord;

out vec3 shadowPos;
out float shadowClipDist;
out float NoS;
out float shadowFade;
out float shadowRadius;
out float shadowTranslucency;

out vec4 fog;
out vec3 sunDir;

out vec3 sunCol;
out vec4 lmSkyCol;

out vec3 eyePlayerPos;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform vec3 cameraPosition;
uniform float eyeAltitude;

uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;
uniform vec3 sunPosition;

uniform float near;
uniform float far;

attribute vec3 mc_Entity;

uniform int worldTime;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

uniform ivec2 eyeBrightness;

vec3 feetPlayerPos;
vec3 worldPos;
vec3 viewPos;

float MIE_FALLOFF;
float MIE_DENSITY;
float mieIsotropy;
vec3 rayleighCol;
vec3 mieCol;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/settings/vertex.glsl"
#include "/settings/shadow.glsl"
#include "/settings/lighting.glsl"

#include "lib/util/math.glsl"

#define VIEW_POS
#define EYE_PLAYER_POS
#define FEET_PLAYER_POS
#define WORLD_POS
#include "/lib/util/spaceConversion.glsl"

#define SUN_DIR_EARLY
#include "/lib/lighting/lightColor.glsl"

#include "/lib/volumetrics/world0_fog.glsl"

#include "/lib/lighting/shadows.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
   resolveSpaceConversions();
   resolveSunDir();
   sunCol = mixByTime(SUN_COL_MORN, SUN_COL_DAY, SUN_COL_EVE, vec3(0.0));
   lmSkyCol =  mixByTime(LM_SKY_MORN, LM_SKY_DAY, LM_SKY_EVE, LM_SKY_NIGHT);
   resolveSkyParams();

   int blockId = int(mc_Entity.x - 10000);

   glcolor = gl_Color;

   vec3 shadowDir = normalize(shadowLightPosition);
   
   gl_Position = ftransform();

   float VoL = dot(normalize(viewPos), shadowDir);

   NoS = smoothstep(0.25, -0.25, VoL);

   float estimatedShadowDist = length(eyePlayerPos) / shadowDistance;
   float shadowBias = fAcos(NoS);
   shadowPos = feetPlayerPos2shadowPos(feetPlayerPos);

   shadowClipDist = length(shadowPos * 2.0 - 1.0);
   shadowFade = smoothstep(0.9, 1.0, shadowClipDist);

   shadowPos.z -= 0.001 * (smoothstep(0.0, 1.0, shadowClipDist) + 0.5 * shadowBias);

   shadowTranslucency = 0.0625;
   shadowRadius = max(1.5, (64 * rainStrength) * (1.0 - length(shadowPos.xy * 2.0 - 1.0)));
   
   fog = getFog();
   lmcoord = (eyeBrightness / 240.0 * 33.05 / 32.0) - (1.05 / 32.0);
}