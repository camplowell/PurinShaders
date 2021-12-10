#version 150 compatibility


in  vec2 texcoord;
in  vec4 glcolor;
in  float shadowFade;

in float entityId;

in vec3 worldPos;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform sampler2D tex;

//uniform sampler2D noisetex;
//const int noiseTextureResolution = 64;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/lib/util/math.glsl"
#include "/lib/util/texelSnap.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:0 */

void main() {
   vec4 color = texelFetch(tex, ivec2(texcoord * textureSize(tex, 0)), 0);
   vec4 albedo = color * glcolor;
   int id = int(entityId + 0.5);
   if (id == 20) {
      //vec3 noisePos = mod(worldPos, 4.0) * 0.5;
      //vec3 noise0 = texture2D(noisetex, noisePos.xz + floor(noisePos.y * noiseTextureResolution) * PHI).rgb;
      //vec3 noise1 = texture2D(noisetex, noisePos.xz + ceil(noisePos.y * noiseTextureResolution) * PHI).rgb;
      float fadeDepth = pow(color.r, 5);
      //gl_FragData[0] = vec4(vec3(0.0, 0.0, 1.0), 0.2);
      gl_FragData[0] = vec4(vec3(1.0, 1.0, fadeDepth), 1.0);
   } else {
      //gl_FragData[0] = vec4(albedo.rgb, 1.0);//float(albedo.a > 0.0) * (albedo.a * 0.25) + 0.75);
      gl_FragData[0] = vec4(min(albedo.rgb, 254.0/255.0), 1.0);
   }
   if (albedo.a == 0.0) {
      discard;
   }
   
}