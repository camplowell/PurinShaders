#version 150 compatibility

in  vec2 texcoord;
in  vec3 eyePlayerPos;
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

uniform sampler2D texture;

uniform float eyeAltitude;

uniform float near;
uniform float far;

uniform float rainStrength;
uniform int worldTime;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/settings/shadow.glsl"
#include "/settings/lighting.glsl"

#include "/lib/volumetrics/world0_fog.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:0 */

void main() {
   vec4 col = texture2D(texture, texcoord);

   vec3 eyeDir = normalize(eyePlayerPos);

   //vec3 falloff = vec3(0.2, 0.4, 1.0) * 0.1;
   //col.rgb *= 2. * (1. - falloff / (eyeDir.y * eyeDir.y + falloff)) * float(eyeDir.y > 0.0);

   col.rgb *= (1.0 - backgroundMieOpacity(eyeDir.y)) * float(eyeDir.y > 0.0);

   //col.rgb /= (col.rgb + 1.0);

   gl_FragData[0] = col;
}