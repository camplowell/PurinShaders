#version 150 compatibility
#define VERTEX

out vec2 texcoord;
out vec4 glcolor;

out float entityId;

out vec3 worldPos;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform float near;
uniform float far;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjectionInverse;

uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;

attribute vec3 mc_Entity;
attribute vec2 mc_midTexCoord;

vec3 eyePlayerPos;
vec3 feetPlayerPos;

float NoShadow;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/settings/vertex.glsl"
#include "/settings/shadow.glsl"

//#include "/lib/vertex/shadowDistortion.glsl"

#define EYE_PLAYER_POS
#define FEET_PLAYER_POS
#define WORLD_POS
#define IS_SHADOW
#include "/lib/util/spaceConversion.glsl"

#ifdef WIND_SWAY
#include "/lib/vertex/windSway.glsl"
#endif

#include "/lib/lighting/shadows.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
   resolveSpaceConversions();
   entityId = mc_Entity.x - 10000;
   int blockId = int(entityId);

   texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
   glcolor = gl_Color;

   if (mc_Entity.b == 0) {
      glcolor.a = 1.0;
   }
   
#ifdef WIND_SWAY
   vec3 pos = applySway(blockId);
   // Set vertex position to displaced version
   gl_Position = gl_ProjectionMatrix * shadowModelView * vec4(pos, 1.0);
#else
   gl_Position = ftransform();
#endif
   gl_Position.z *= shadowDepthMul;

   gl_Position.xy = distortShadow(gl_Position.xy);
}