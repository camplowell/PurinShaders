#if !defined STOCHASTIC_TRANSPARENCY
#define STOCHASTIC_TRANSPARENCY

#define NOISE_XY 64
#define NOISE_T 64
#define T_WIDTH 8

// ===============================================================================================
// Large
// ===============================================================================================
#if defined VERTEX

vec3 getAlphaOffset(vec3 normal, vec3 viewPos) {
    vec3 seedPos = (dot(-normal, viewPos) + 11) * view2eye(normal);
    float seed = r3_grid(ivec3(seedPos * 1023));
    vec3 offset = r3(int(seed * 1023));
    return vec3(ivec3(offset * vec3(NOISE_XY, NOISE_XY, NOISE_T)));
}

#else

float getThreshold(sampler2D noisetex, vec3 alphaOffset, int frameCounter) {
    ivec3 ioff = ivec3(alphaOffset + 0.5);
    ivec3 noisePos = (ivec3(gl_FragCoord.xy, frameCounter) + ioff) % ivec3(NOISE_XY, NOISE_XY, NOISE_T);
    return clamp(texelFetch(noisetex, ivec2(
        noisePos.x + NOISE_XY * (noisePos.z % T_WIDTH), 
        noisePos.y + NOISE_XY * (noisePos.z / T_WIDTH)
    ), 0).x, (1 / 255.0), (254 / 255.0));
}

#endif

// Small -----------------------------------------------------------------------------------------

#endif