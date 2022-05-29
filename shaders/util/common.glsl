#if !defined COMMON
#define COMMON

// ===============================================================================================
// Gbuffer formats
// ===============================================================================================
/*
// Colortex0: primary drawbuffer
const int colortex0Format = RGB16;
// Colortex1: primary depth
const int colortex1Format = R32F;
const vec4 colortex1ClearColor = vec4(1024, 1024, 1024, 1024);
// Colortex2: water depth
const int colortex2Format = R32F;
const vec4 colortex2ClearColor = vec4(1024, 1024, 1024, 1024);
// Colortex3: velocity
const int colortex3Format = RG16F;
// Colortex5: history
const int colortex5Format = RGB16;
const bool colortex5Clear = false;
*/
// ===============================================================================================
// Settings
// ===============================================================================================

#include "/settings/color.glsl"
#include "/settings/distortion.glsl"

// ===============================================================================================
// Uniforms
// ===============================================================================================

uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

// ===============================================================================================
// Common libraries
// ===============================================================================================

#include "/util/space.glsl"
#include "/util/random.glsl"

#endif