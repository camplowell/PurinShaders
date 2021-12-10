#if !defined(SHADOW_GLSL)
#define SHADOW_GLSL

vec2 distortShadow(vec2 shadowPos) {
   //return shadowPos;
   float dist = length(shadowPos);
   float newDist = dist/mix(1.0, dist, 0.9); //log(dist * shadowDistance * 0.25 + 1.0) / log(shadowDistance * 0.25 + 1.0);
   return shadowPos * newDist / dist;
}

#if !defined(IS_SHADOW)
vec3 feetPlayerPos2shadowPos(vec3 feetPlayerPos) {
   vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
   vec3 shadowClipPos = (shadowProjection * vec4(shadowViewPos, 1.0)).xyz;
   shadowClipPos.xy = distortShadow(shadowClipPos.xy);
   shadowClipPos.z *= shadowDepthMul;
   return shadowClipPos * 0.5 + 0.5;
}
#endif

#ifdef SAMPLE_SHADOW

#define shadowDepthTest(depth, transition) smoothstep(0.0, ((transition) * 0.015625) * shadowDepthMul, adjustedPos.z - (depth))

#ifdef COLOR_SHADOWS
   vec3 getShadow(float radius, float shadowTransition, inout vec2 dither) {
      if (NoS <= 0.001) {
         return vec3(0.0);
      }
      if (shadowFade >= 1.0) {
         return vec3(NoS);
      }
      
   #if defined(NO_SHADOW_JITTER)
      vec3 adjustedPos = shadowPos;
      vec4 shadowCol = texture2D(shadowcolor0, adjustedPos.xy);

      float opaqueDepth = texture2D(shadowtex1, adjustedPos.xy).x;
      float transparentDepth = texture2D(shadowtex0, adjustedPos.xy).x;

      shadowCol.rgb = mix(vec3(1.0), shadowCol.rgb, shadowDepthTest(transparentDepth, shadowTransition));
      shadowCol.rgb *= (1.0 - shadowDepthTest(opaqueDepth, shadowTransition));
      return shadowCol.rgb * NoS;
   #else
      vec3 sum = vec3(0.0);
      for(int i = 0; i < SHADOW_SAMPLES; i++) {
         vec2 shadowOff = getDitheredTexelOffset(texcoord * textureSize(tex, 0), 1.0, dither);
         dither = fract(dither + PHI);
         vec3 adjustedPos = quantize(shadowPos, shadowOff);
         adjustedPos.xy += (dither - 0.5) * radius / shadowMapResolution;
         adjustedPos.z = min(adjustedPos.z, shadowPos.z);

         vec4 shadowCol = texelFetch(shadowcolor0, ivec2(adjustedPos.xy * textureSize(shadowcolor0, 0)), 0);

         float opaqueDepth = texture2D(shadowtex1, adjustedPos.xy).x;
         float transparentDepth = texture2D(shadowtex0, adjustedPos.xy).x;
         float localTransition = shadowTransition;
         if (shadowCol.rg == vec2(1.0)) {
            localTransition = max(8.0 * shadowCol.b, shadowTransition);
            shadowCol.rgb = vec3(0.2, 0.4, 1.0);
         }
         shadowCol.rgb = mix(vec3(1.0), shadowCol.rgb, shadowDepthTest(transparentDepth, localTransition));
         shadowCol.rgb *= (1.0 - shadowDepthTest(opaqueDepth, shadowTransition));
         sum += shadowCol.rgb;
      }
      return mix(sum / SHADOW_SAMPLES, vec3(1.0), shadowFade) * NoS;
   #endif
   }
#else
   vec3 getShadow(float radius, float shadowTransition, inout vec2 dither) {
      if (NoS <= 0.0) {
         return vec3(0.0);
      }
      if (shadowFade >= 1.0) {
         return vec3(NoS);
      }
   #if defined (NO_SHADOW_JITTER)
      vec3 adjustedPos = shadowPos;
      float opaqueDepth = texture2D(shadowtex1, adjustedPos.xy).x;

      return vec3((1.0 - shadowDepthTest(opaqueDepth)) * NoS);
   #else
      vec3 sum = vec3(0.0);
      for(int i = 0; i < SHADOW_SAMPLES; i++) {
         vec2 shadowOff = getDitheredTexelOffset(texcoord * textureSize(tex, 0), 1, dither);
         dither = fract(dither + PHI);
         
         vec3 adjustedPos = quantize(shadowPos, shadowOff);
         adjustedPos.xy += (dither - 0.5) * radius / shadowMapResolution;
         adjustedPos.z = min(adjustedPos.z, shadowPos.z);

         float opaqueDepth = texture2D(shadowtex1, adjustedPos.xy).x;

         sum += 1.0 - shadowDepthTest(opaqueDepth, shadowTransition);
      }
      return mix(sum / SHADOW_SAMPLES, vec3(1.0), shadowFade) * NoS;
   #endif
   }
#endif

#endif

#endif // end of document