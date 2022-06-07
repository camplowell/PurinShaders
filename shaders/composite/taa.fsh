#version 410 compatibility
#define FRAGMENT

// ===============================================================================================
// Variables
// ===============================================================================================

in vec2 texcoord;

// Uniforms --------------------------------------------------------------------------------------

uniform sampler2D colortex0;
uniform sampler2D colortex1;
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
    vec3 offset = texture(colortex3, unjittered).xyz;
    vec2 expectedPos = unjittered + offset.xy;
    ivec2 pixel = ivec2(unjittered * vec2(viewWidth, viewHeight));
    int width = int(viewWidth);
    int height = int(viewHeight);
    
    // Fetch neighborhood colors
    vec3 clip_origin = vec3(0.0);
    vec3 clip_extent = vec3(0.0);
    float depth = 0.0;
    float depth_min = 1.0;
    float depth_max = 0.0;
    float samples = 0;
    for (int y = max(0, pixel.y - SEARCH_RADIUS); y < min(pixel.y + SEARCH_RADIUS, int(viewHeight)); y++) {
        for (int x = max(0, pixel.x - SEARCH_RADIUS); x < min(pixel.x + SEARCH_RADIUS, int(viewWidth)); x++) {
            vec3 current = rgb2yuv(texelFetch(colortex0, ivec2(x, y), 0).rgb);
            clip_origin += current;
            clip_extent += current * current;
            samples += 1.0;

            float depth_current = 16.0 / (16.0 + texelFetch(colortex1, ivec2(x, y), 0).x);
            depth_min = min(depth_min, depth_current);
            depth_max = max(depth_max, depth_current);
            if (x == pixel.x && y == pixel.y) {
                depth = depth_current;
            }
        }
    }
    clip_origin /= samples;
    clip_extent = 0.5 * sqrt(clip_extent / samples - clip_origin * clip_origin);
    
    // Fetch history color
    vec3 col = texture(colortex0, unjittered).rgb;
    vec4 hist = texture(colortex5, expectedPos);
    hist.a = 16.0 / hist.a - 16.0;
    hist.a -= offset.z;
    hist.a = 16.0 / (16.0 + hist.a);

    // Find weight
    float weight = 0.9375;
    if (
        min(expectedPos.x, expectedPos.y) < 0 
     || max(expectedPos.x, expectedPos.y) > 1
     || hist.a < depth_min - 0.001
     || hist.a > depth_max + 0.001
    ) {
        weight = 0;
        col = yuv2rgb(clip_origin);
    }
    
    
    vec3 clipCol = rgb2yuv(hist.rgb) - clip_origin;
    vec3 unit_off = abs(clipCol / max(clip_extent, 0.0001));
    float unit_max = max(max(unit_off.x, unit_off.y), unit_off.z);

    if (unit_max > 1.0) {
        hist.rgb = yuv2rgb(clip_origin + clipCol / unit_max);
    }
    
    gl_FragData[0] = vec4(mix(col, hist.rgb, weight), depth);
    //gl_FragData[0] = vec4(vec3(weight), depth);
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
