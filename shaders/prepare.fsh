#version 150 compatibility
#define COMPOSITE
#define FRAGMENT

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

uniform float eyeAltitude;
uniform float rainStrength;

uniform float far;

uniform int worldTime;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/settings/lighting.glsl"
#include "/lib/volumetrics/world0_fog.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:5 */

void main() {
   vec3 viewDir = normalize(eyePlayerPos);

   vec3 rayleighOpacity = backgroundRayleighOpacity(viewDir.y);
   float mieOpacity = backgroundMieOpacity(viewDir.y);

   float VoL = dot(viewDir, sunDir);

   vec3 skyColor = getSkyColor(viewDir.y, sunDir.y, VoL, rayleighOpacity, mieOpacity , 1.0);

   vec2 dither = mod(gl_FragCoord.xy + vec2(0.0, 1.0), 2);

   gl_FragData[0] = vec4(skyColor * skyColor, 1.0);
}