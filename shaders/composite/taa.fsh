#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in vec2 texcoord;

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;

// ===============================================================================================
// Imports
// ===============================================================================================

#include "/util/common.glsl"
#include "/util/taa.glsl"

// ===============================================================================================
// Functions
// ===============================================================================================

// Helper declarations ---------------------------------------------------------------------------

vec3 rgb2yuv(vec3 rgb);
vec3 yuv2rgb(vec3 yuv);

// Main ------------------------------------------------------------------------------------------

/* RENDERTARGETS: 5 */ 
void main() {
    vec2 unjittered = texcoord + getJitter();
    vec2 offset = texture(colortex3, unjittered).xy;
    vec2 expectedPos = unjittered + offset;
    ivec2 pixel = ivec2(unjittered * vec2(viewWidth, viewHeight));
    int width = int(viewWidth);
    int height = int(viewHeight);
    
    // Fetch neighborhood colors
    vec3 clip_origin = vec3(0.0);
    vec3 clip_extent = vec3(0.0);
    float samples = 0;
    for (int y = max(0, pixel.y - SEARCH_RADIUS); y < min(pixel.y + SEARCH_RADIUS, int(viewHeight)); y++) {
        for (int x = max(0, pixel.x - SEARCH_RADIUS); x < min(pixel.x + SEARCH_RADIUS, int(viewWidth)); x++) {
            vec3 current = rgb2yuv(texelFetch(colortex0, ivec2(x, y), 0).rgb);
            clip_origin += current;
            clip_extent += current * current;
            samples += 1.0;
        }
    }
    clip_origin /= samples;
    clip_extent = sqrt(clip_extent / samples - clip_origin * clip_origin);
    
    // Fetch history color
    vec3 col = texture(colortex0, unjittered).rgb;
    vec3 hist = texture(colortex5, expectedPos).rgb;
    // Find weight
    float weight = 0.9375;
    if (min(expectedPos.x, expectedPos.y) < 0 || max(expectedPos.x, expectedPos.y) > 1) {
        weight = 0;
        col = yuv2rgb(clip_origin);
    }
    
    
    vec3 clipCol = rgb2yuv(hist) - clip_origin;
    vec3 unit_off = abs(clipCol / max(clip_extent, 0.0001));
    float unit_max = max(max(unit_off.x, unit_off.y), unit_off.z);

    if (unit_max > 1.0) {
        hist = yuv2rgb(clip_origin + clipCol / unit_max);
    }
    
    gl_FragData[0] = vec4(mix(col, hist, weight), 1.0);
}

// Helper implementations ------------------------------------------------------------------------

vec3 rgb2yuv(vec3 rgb){
    float y = 0.299*rgb.r + 0.587*rgb.g + 0.114*rgb.b;
    return vec3(y, 0.493*(rgb.b-y), 0.877*(rgb.r-y));
}

vec3 yuv2rgb(vec3 yuv){
    float y = yuv.x;
    float u = yuv.y;
    float v = yuv.z;
    
    return vec3(
        y + 1.0/0.877*v,
        y - 0.39393*u - 0.58081*v,
        y + 1.0/0.493*u
    );
}
