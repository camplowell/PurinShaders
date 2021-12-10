#if !defined SPACE_CONVERSION_GLSL
#define SPACE_CONVERSION_GLSL

// ===============================================================================================
// Space conversion functions
// ===============================================================================================


#if defined COMPOSITE
   vec3 getScreenPos(vec2 coord, float depth) {
      return vec3(coord, depth);
   }
#else
   vec3 getViewPos() {
      return (gl_ModelViewMatrix * gl_Vertex).xyz;
   }
#endif

#if defined(IS_SHADOW)
   vec3 clipPos2viewPos(vec3 clipPos) {
      vec4 temp = shadowProjectionInverse * vec4(clipPos, 1.0);
      return temp.xyz / temp.w;
   }
   vec3 viewPos2clipPos(vec3 viewPos) {
      vec4 clipPos4 = shadowProjection * vec4(viewPos, 1.0);
      return clipPos4.xyz / clipPos4.w;
   }
#else
   vec3 clipPos2viewPos(vec3 clipPos) {
      vec4 temp = gbufferProjectionInverse * vec4(clipPos, 1.0);
      return temp.xyz / temp.w;
   }
   vec3 viewPos2clipPos(vec3 viewPos) {
      vec4 clipPos4 = gl_ProjectionMatrix * vec4(viewPos, 1.0);
      return clipPos4.xyz / clipPos4.w;
   }
#endif

vec3 screenPos2clipPos(vec3 screenPos) {
   return screenPos * 2.0 - 1.0;
}

vec3 clipPos2screenPos(vec3 clipPos) {
   return clipPos * 0.5 + 0.5;
}

#if defined(IS_SHADOW)
   vec3 viewPos2eyePlayerPos(vec3 viewPos) {
      return mat3(shadowModelViewInverse) * viewPos;
   }
   vec3 feetPlayerPos2eyePlayerPos(vec3 feetPlayerPos) {
      return feetPlayerPos - shadowModelViewInverse[3].xyz;
   }
   vec3 eyePlayerPos2feetPlayerPos(vec3 eyePlayerPos) {
      return eyePlayerPos + shadowModelViewInverse[3].xyz;
   }
#else
   vec3 viewPos2eyePlayerPos(vec3 viewPos) {
      return mat3(gbufferModelViewInverse) * viewPos;
   }
   vec3 feetPlayerPos2eyePlayerPos(vec3 feetPlayerPos) {
      return feetPlayerPos - gbufferModelViewInverse[3].xyz;
   }
   vec3 eyePlayerPos2feetPlayerPos(vec3 eyePlayerPos) {
      return eyePlayerPos + gbufferModelViewInverse[3].xyz;
   }
#endif

vec3 feetPlayerPos2worldPos(vec3 feetPlayerPos) {
   return feetPlayerPos + cameraPosition;
}

// Kneemund/Niemand's optimized depth linearization method
float linearizeDepth(float depth) {
    return 2.0 * (near * far) / (depth * (near - far) + far);
}

// ===============================================================================================
// Cascade space dependencies
// ===============================================================================================

#if defined(WORLD_POS) && !defined(FEET_PLAYER_POS)
   #define FEET_PLAYER_POS vec3
#endif
#if defined(FEET_PLAYER_POS) && !defined(EYE_PLAYER_POS)
   #define EYE_PLAYER_POS vec3
#endif
#if defined(EYE_PLAYER_POS) && !defined(VIEW_POS)
   #define VIEW_POS vec3
#endif

#if defined COMPOSITE // Composite-specific dependencies
   #if defined(VIEW_POS) && !defined(CLIP_POS)
      #define CLIP_POS vec3
   #endif
   #if defined(CLIP_POS) && !defined(SCREEN_POS)
      #define SCREEN_POS vec3
   #endif
#else // Gbuffer-specific dependencies
   #if defined(SCREEN_POS) && !defined(CLIP_POS)
      #define CLIP_POS vec3
   #endif
   #if defined(CLIP_POS) && !defined(VIEW_POS)
      #define VIEW_POS vec3
   #endif
#endif

// ===============================================================================================
// Space conversion functions
// ===============================================================================================

#if defined COMPOSITE

   void resolveSpaceConversions(float depth) {
      #if defined SCREEN_POS
         SCREEN_POS screenPos = getScreenPos(texcoord, depth);
      #endif
      #if defined CLIP_POS
         CLIP_POS clipPos = screenPos2clipPos(screenPos);
      #endif
      #if defined VIEW_POS
         VIEW_POS viewPos = clipPos2viewPos(clipPos);
      #endif
      #if defined EYE_PLAYER_POS
         EYE_PLAYER_POS eyePlayerPos = viewPos2eyePlayerPos(viewPos);
      #endif
      #if defined FEET_PLAYER_POS
         FEET_PLAYER_POS feetPlayerPos = eyePlayerPos2feetPlayerPos(eyePlayerPos);
      #endif
      #if defined WORLD_POS
         WORLD_POS worldPos = feetPlayerPos2worldPos(feetPlayerPos);
      #endif
   }

#else

   void resolveSpaceConversions() {
      #if defined VIEW_POS
         VIEW_POS viewPos = getViewPos();
      #endif
      #if defined CLIP_POS
         CLIP_POS clipPos = viewPos2clipPos(viewPos);
      #endif
      #if defined SCREEN_POS
         SCREEN_POS screenPos = clipPos2screenPos(clipPos);
      #endif
      #if defined EYE_PLAYER_POS
         EYE_PLAYER_POS eyePlayerPos = viewPos2eyePlayerPos(viewPos);
      #endif
      #if defined FEET_PLAYER_POS
         FEET_PLAYER_POS feetPlayerPos = eyePlayerPos2feetPlayerPos(eyePlayerPos);
      #endif
      #if defined WORLD_POS
         WORLD_POS worldPos = feetPlayerPos2worldPos(feetPlayerPos);
      #endif
   }

#endif

#endif // End of document