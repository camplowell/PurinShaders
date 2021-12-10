#version 150 compatibility

in  vec2 texcoord;
in  vec4 glcolor;
in  float ao;

in  vec2 lmcoord;
in  vec3 normal;

in  vec3 shadowPos;
in  float shadowClipDist;
in  float NoS;
in  float shadowFade;
in  float shadowRadius;
in  float shadowTranslucency;

in  vec3 sunDir;

in  vec3 sunCol;
in  vec4 lmSkyCol;

in  vec3 eyePlayerPos;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform sampler2D tex;

uniform sampler2D noisetex;
const int noiseTextureResolution = 64;

uniform float rainStrength;

#include "/settings/shadow.glsl"
#if defined(COLOR_SHADOWS)
   uniform sampler2D shadowtex0;
#endif
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex1;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform float far;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/settings/lighting.glsl"

#include "/lib/lighting/lightColor.glsl"
#include "/lib/lighting/blockLight.glsl"
#include "/lib/util/texelSnap.glsl"
#include "/lib/util/math.glsl"

#define SAMPLE_SHADOW
#include "/lib/lighting/shadows.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:0 */

void main() {
   vec2 dither = texelFetch(noisetex, ivec2(mod(gl_FragCoord.xy, noiseTextureResolution)), 0).rg;
   vec2 off2texel = getOffsetToTexel(texcoord * textureSize(tex, 0));

   vec3 shadowCol = mix(mix(sunCol, SUN_COL_DAY, rainStrength), MOON_COL, float(sunDir.y < 0.0));
   
   vec3 shadow = vec3(0.0);
   if (rainStrength < 1.0) {
      shadow = getShadow(shadowRadius, 
         shadowTranslucency, 
         dither);
      shadow *= 1.0 - (0.02 / (abs(sunDir.y) + 0.02));
      shadow *= 1.0 - rainStrength;
      shadow *= mix(1.0, lmcoord.y * lmcoord.y, shadowFade);
   }
   
   vec4 albedo = texture2D(tex, texcoord) * glcolor;
   vec3 blockLight = lightmap2color(lmcoord, shadowTranslucency, off2texel);

   vec3 col = albedo.rgb * max(blockLight, shadow * shadowCol);
   
   gl_FragData[0] = vec4(col * float(length(eyePlayerPos) < far), albedo.a);
   //gl_FragData = vec4(shadow, albedo.a);
   //gl_FragData[0] = vec4(vec3(NoS), albedo.a);
}