#version 150 compatibility
#define COMPOSITE


in  vec2 texcoord;

in  vec3 sunDir;
in  vec3 sunCol;
in  vec3 moonCol;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform sampler2D noisetex;
const int noiseTextureResolution = 64;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform float near;
uniform float far;

uniform vec3 cameraPosition;

uniform float viewWidth;
uniform float viewHeight;

uniform int isEyeInWater;

vec3 eyePlayerPos;

const vec3 waterAlbedo = vec3(1.0, 0.5, 0.2);

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/lib/util/math.glsl"

#include "/lib/volumetrics/fog_lut.glsl"
#include "/lib/volumetrics/exponentialFog.glsl"

#include "/lib/lighting/lightColor.glsl"

#define EYE_PLAYER_POS
#include "/lib/util/spaceConversion.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:0 */

void main() {
   ivec2 pixel = ivec2(gl_FragCoord.xy);

   float opaqueDepth = texelFetch(depthtex1, pixel, 0).x;
   float waterDepth = texelFetch(depthtex0, pixel, 0).x;
   vec4 transparentCol = texelFetch(colortex2, pixel, 0);
   vec3 waterFactor = texelFetch(colortex3, pixel, 0).rgb;



   resolveSpaceConversions(waterDepth);
   float waterDist = length(eyePlayerPos);

   resolveSpaceConversions(opaqueDepth);
   float dist = length(eyePlayerPos);

   

   vec3 col = texelFetch(colortex0, pixel, 0).rgb;
   
   float waterDepthOffset = dist - waterDist;
   if (isEyeInWater > 0) {
      waterDepthOffset = mix(min(dist, waterDist), dist, max(waterFactor.b - waterFactor.g, 0.0));
      waterFactor.r = max(waterFactor.r, 0.0001);
      waterFactor.b = 0.0;
   }

   // Clip waterDepthOffset to only where it applies
   waterDepthOffset = waterFactor.r > 0.0 && (dist < far || isEyeInWater == 1) ? waterDepthOffset : 0.0;

   float fogFactor = dist / far;
   vec4 fog = sampleFogLUT(vec3(texcoord, (dist - waterDepthOffset) / (far)));
   //vec4 waterFog = sampleFogLUT(vec3(texcoord, waterDist / far));

   vec3 waterMult = exp(-0.05 * waterAlbedo * waterDepthOffset);

   vec3 viewDir = normalize(eyePlayerPos);
   float VoL = dot(sunDir, viewDir);

   //col = vec3(0.25 * float(dist < far));

   col *= waterMult;

   col = col * (dist >= far ? 1.0 : 1.0 - fog.a) + fog.rgb;

   //transparentCol.a *= (1.0 - fog.a);
   
   col = col * (1.0 - transparentCol.a) + transparentCol.rgb * 
      mix(waterMult, 
         vec3(1.0), 
         max(fog.a, float(waterFactor.b > waterFactor.g)));
   
   col += 4.0 * sunCol * (1.0 - waterMult) * (1.0 - waterAlbedo) * MiePhaseFunction(0.1, VoL) * getSunVisibility(sunDir.y, viewDir.y, VoL) * (1.0 - fog.a);
   col += 1.0 * moonCol * (1.0 - waterMult) * (1.0 - waterAlbedo) * MiePhaseFunction(0.1, -VoL) * getSunVisibility(-sunDir.y, viewDir.y, -VoL) * (1.0 - fog.a);

   gl_FragData[0] = vec4(col, 1.0);
}