#if !defined TEXEL_SNAP_GLSL
#define TEXEL_SNAP_GLSL

#include "/lib/util/math.glsl"

mat2 inverse(mat2 m) {
  return mat2(m[1][1],-m[0][1],
             -m[1][0], m[0][0]) / (m[0][0]*m[1][1] - m[0][1]*m[1][0]);
}

vec2 getOffsetToTexel(vec2 texelSpace) {
   mat2 texel2pixMat = inverse(mat2(dFdx(texelSpace), dFdy(texelSpace)));
   return texel2pixMat * (vec2(0.5) - fract(texelSpace));
}

vec2 getDitheredTexelOffset(vec2 texelSpace, float radius, vec2 dither) {
   mat2 texel2pixMat = inverse(mat2(dFdx(texelSpace), dFdy(texelSpace)));
   return texel2pixMat * vec2((vec2(0.5) + radius * (dither - 0.5)) - fract(texelSpace));
}

#define quantize(v, offset) (((v) + (offset.x * dFdx(v)) + (offset.y * dFdy(v))))

#endif // End of document