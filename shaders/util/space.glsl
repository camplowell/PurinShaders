#if !defined SPACE
#define SPACE

// ===============================================================================================
// Uniforms
// ===============================================================================================

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform float near;
uniform float far;

// ===============================================================================================
// Vertex-only transformations
// ===============================================================================================

#if defined VERTEX

vec3 model2view() {
  return (modelViewMatrix * gl_Vertex).xyz;
}

vec4 model2clip() {
  return gl_ModelViewProjectionMatrix * gl_Vertex;
}

vec2 modelTexcoord() {
  return (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

vec2 modelLmcoord() {
  return ((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * 16 / 15.0) - (0.5 / 16.0);
}

vec3 modelNormal() {
  return normalize(gl_NormalMatrix * gl_Normal);
}

#endif

// ===============================================================================================
// Generalized conversions
// ===============================================================================================

// Kneemund/Niemand's fast version from the Shaderlabs wiki
float linearizeDepth(float depth) {
    return (near * far) / (depth * (near - far) + far);
}

vec4 view2clip(vec3 viewPos) {
  return gbufferProjection * vec4(viewPos, 1.0);
}
vec3 clip2view(vec4 clipPos) {
  return vec3(gbufferProjectionInverse * clipPos);
}
vec4 view2clip(vec3 viewPos, mat4 projectionMatrix) {
  return projectionMatrix * vec4(viewPos, 1.0);
}

vec3 screen2ndc(vec3 screenPos) {
  return screenPos * 2.0 - 1.0;
}
vec3 ndc2screen(vec3 ndcPos) {
  return ndcPos * 0.5 + 0.5;
}

vec3 ndc2view(vec3 ndcPos, mat4 projectionInverse) {
  vec4 tmp = projectionInverse * vec4(ndcPos, 1.0);
  return tmp.xyz / tmp.w;
}
vec3 view2ndc(vec3 viewPos, mat4 projection) {
  vec4 ndc = projection * vec4(viewPos, 1.0);
  return ndc.xyz / ndc.w;
}

vec3 screen2view(vec3 screenPos, mat4 projectionInverse) {
    return ndc2view(screen2ndc(screenPos), projectionInverse);
}
vec3 view2screen(vec3 viewPos, mat4 projection) {
    return ndc2screen(view2ndc(viewPos, projection));
}

vec3 view2eye(vec3 viewPos, mat4 modelViewInverse) {
  return mat3(modelViewInverse) * viewPos;
}
vec3 eye2view(vec3 eyePos, mat4 modelView) {
  return mat3(modelView) * eyePos;
}

vec3 eye2feet(vec3 eyePos, mat4 modelViewInverse) {
  return eyePos + modelViewInverse[3].xyz;
}
vec3 feet2eye(vec3 feetPos, mat4 modelView) {
  return feetPos + modelView[3].xyz;
}

vec3 view2feet(vec3 viewPos, mat4 modelViewInverse) {
  return (modelViewInverse * vec4(viewPos, 1.0)).xyz;
}
vec3 feet2view(vec3 feetPos, mat4 modelView) {
  return (modelView * vec4(feetPos, 1.0)).xyz;
}

vec3 feet2world(vec3 feetPos, vec3 playerPos) {
  return feetPos + playerPos;
}

// ===============================================================================================
// Player-centric conversions
// ===============================================================================================

vec3 ndc2view(vec3 ndcPos) {
    return ndc2view(ndcPos, gbufferProjectionInverse);
}
vec3 view2ndc(vec3 viewPos) {
    return view2ndc(viewPos, gbufferProjection);
}

vec3 screen2view(vec3 screenPos) {
    return screen2view(screenPos, gbufferProjectionInverse);
}
vec3 view2screen(vec3 viewPos) {
    return view2screen(viewPos, gbufferProjection);
}

vec3 view2eye(vec3 viewPos) {
    return view2eye(viewPos, gbufferModelViewInverse);
}
vec3 eye2view(vec3 eyePos) {
    return eye2view(eyePos, gbufferModelView);
}

vec3 eye2feet(vec3 eyePos) {
    return eye2feet(eyePos, gbufferModelViewInverse);
}
vec3 feet2eye(vec3 feetPos) {
    return feet2eye(feetPos, gbufferModelView);
}

vec3 view2feet(vec3 viewPos) {
    return view2feet(viewPos, gbufferModelViewInverse);
}
vec3 feet2view(vec3 feetPos) {
    return feet2view(feetPos, gbufferModelView);
}

vec3 feet2world(vec3 feetPos) {
  return feetPos + cameraPosition;
}

// Small -----------------------------------------------------------------------------------------

#endif

