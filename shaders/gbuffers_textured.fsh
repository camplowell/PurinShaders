#version 150 compatibility


in  vec2 texcoord;
in  vec4 glcolor;

in  vec2 lmcoord;
in  vec3 normal;

in  vec3 shadowPos;
in  float shadowClipDist;
in  float shadowFade;
in  float shadowRadius;
in  float shadowTranslucency;

in  vec4 fog;
in  vec3 sunDir;
in  vec3 shadowDir;

in  vec3 sunCol;
in  vec4 lmSkyCol;

in  vec3 worldPos;
in  vec3 eyePlayerPos;
in  vec3 viewPos;

in  float entityId;

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

const float ao = 1.0;
const float NoS = 1.0;

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
vec3 applyFog(vec3 col) {
   return col * float(length(eyePlayerPos) < far) * (1.0 - fog.a) + fog.rgb;
}
// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:23 */

void main() {
   int id = int(entityId + 0.5);
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
   }
   
   vec4 texcol = texture2D(tex, texcoord);
   vec4 albedo = texcol * glcolor;
   vec3 blockLight = lightmap2color(lmcoord, shadowTranslucency, off2texel);

   vec3 col = albedo.rgb * max(blockLight, shadow * shadowCol);

   vec3 noisePos = worldPos / 8.0;
   vec3 noise0 = texture2D(noisetex, noisePos.xz + floor(noisePos.y * noiseTextureResolution) * PHI).rgb;
   vec3 noise1 = texture2D(noisetex, noisePos.xz + ceil(noisePos.y * noiseTextureResolution) * PHI).rgb;

   //gl_FragData[0] = vec4(mix(noise0, noise1, fract(noisePos.y * noiseTextureResolution)), 1.0);
   
   if (id == 20) {
      vec3 halfVector = normalize(-normalize(quantize(viewPos, off2texel)) + shadowDir);
      float NoH = dot(halfVector, normal);
      vec3 specular = shadowCol * mix(shadow * 2.0, 0.5 * blockLight, rainStrength); 
      specular *= pow(texcol.r, mix(8.0, 1.0, pow(max(NoH, 0.0), mix(16.0, 2.0, rainStrength))));
      specular *= pow(0.5 * NoH + 0.5, mix(8.0, 1.0, rainStrength));//float(dot(halfVector, normal) > reflectionThreshold) * pow(texcol.r * 0.75 + 0.25, 8) * 2; //smoothstep(texcol.r, 1.0, dot(halfVector, normal));
      gl_FragData[1] = vec4(texcol.r, 1.0, 0.0, 0.8);
      gl_FragData[0] = vec4(applyFog(col + specular), 0.4);
   } else {
      gl_FragData[0] = vec4(applyFog(col), albedo.a);
      gl_FragData[1] = vec4(0.0, 0.0, 1.0, 0.8);
   }
   
}