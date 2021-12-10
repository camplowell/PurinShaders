#version 150 compatibility

in  vec2 texcoord;

// ===============================================================================================
// Global variables
// ===============================================================================================

uniform sampler2D colortex5;

uniform sampler2D noisetex;
const int noiseTextureResolution = 64;

uniform float viewWidth;
uniform float viewHeight;

// ===============================================================================================
// Includes
// ===============================================================================================

#include "/lib/util/math.glsl"

// ===============================================================================================
// Helpers
// ===============================================================================================



// ===============================================================================================
// Main
// ===============================================================================================

/* DRAWBUFFERS:0 */

void main() {
   vec2 dither = texelFetch(noisetex, ivec2(mod(gl_FragCoord.xy, noiseTextureResolution)), 0).xy;
   vec3 col = texture2D(colortex5, texcoord).rgb;
   //ivec2 size5 = textureSize(colortex5, 0) - 1;
   //vec3 col = texelFetch(colortex5, ivec2(clamp(gl_FragCoord.xy * 0.125 + (dither - 0.5), ivec2(0), size5)), 0).rgb;
   col = sqrt(col);
   dither = fract(dither + PHI);
   //col += (dither.x - 0.5) / 128.0;
   //vec3 col = texture2D(colortex5, clamp(texcoord + (dither - 0.5) * 128.0 / vec2(viewWidth, viewHeight), 0.0, 1.0)).rgb;
   

   //gl_FragData[0] = vec4(col, 1.0);
   gl_FragData[0] = vec4(0.0, 0.0, 0.0, 1.0);
}