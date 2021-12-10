#version 150 compatibility

in  vec2 texcoord;

uniform sampler2D colortex0;
//uniform sampler2D colortex5;

/*
const int colortex0Format = RGB16F;
const int colortex2Format = RGBA16F;
const int colortex3Format = RGB8;
const int colortex4Format = RGBA16F;
const int colortex5Format = RGB16F;
*/

#define TONEMAP BOTW //[sRGB ACES Hable BOTW]

#include "/lib/color/tonemaps.glsl"

void main() {
   vec3 sceneCol = texture2D(colortex0, texcoord).rgb;
   //vec3 sceneCol = texture2D(colortex4, texcoord).rgb;

   sceneCol = TONEMAP(sceneCol);

   gl_FragData[0] = vec4(sceneCol, 0.0);
}