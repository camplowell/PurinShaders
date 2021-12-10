#if !defined(FOG_LUT_GLSL)
#define FOG_LUT_GLSL

vec4 sampleFogLUT(vec3 samplePos) {
   vec2 layerResolution = textureSize(colortex4, 0) / 8.0;
   vec2 layerCoord = clamp(samplePos.xy, 1.0 / layerResolution, 1.0 - 1.0 / layerResolution) / 8.0;
   if (samplePos.z >= 1.0) {
      return vec4(texture2D(colortex4, layerCoord + vec2(7.0 / 8.0)).rgb, 1.0);
   }
   float layer = samplePos.z * (8.0 * 8.0);

   int layerNear = clamp(int(floor(samplePos.z * (8.0 * 8.0))) - 1, -1, 8 * 8 - 1);
   int layerFar =  min(layerNear + 1, 8 * 8 - 1);

   vec2 layerOffNear = ivec2(mod(layerNear, 8.0), floor(layerNear / 8.0)) / 8.0;
   vec2 layerOffFar = ivec2(mod(layerFar, 8.0), floor(layerFar / 8.0)) / 8.0;

   vec4 nearCol = layerNear < 0 ? vec4(0.0) : texture2D(colortex4, layerCoord + layerOffNear);
   vec4 farCol = texture2D(colortex4, layerCoord + layerOffFar);

   return mix(nearCol, farCol, fract(layer));
}

#endif // end of document