#if !defined RANDOM
#define RANDOM

const int ref = int(exp2(24));
const float to_float = 1.0 / ref;

const int phi = 10368890;
const ivec2 phi2 = ivec2(5447863, 12664746);
const ivec2 phi2_inv = ivec2(12664746, 9560334);
const ivec3 phi3_inv = ivec3(13743434, 11258244, 9222444);

const ivec3 phi3 = ivec3(3703471, 8224462, 13743434);

float r1(int seed) {
    int basis = seed * phi;
    return mod(basis, ref) * to_float;
}

float r2_grid(ivec2 seed) {
    ivec2 basis = seed * phi2_inv;
    return mod(basis.x + basis.y, ref) * to_float;
}

float r2_grid(ivec2 seed, int t) {
    ivec2 basis = seed * phi2_inv;
    int offset = t * phi;
    return mod(basis.x + basis.y + offset, ref) * to_float;
}

float r3_grid(ivec3 seed) {
    ivec3 basis = seed * phi3_inv;
    return mod(basis.x + basis.y + basis.z, ref) * to_float;
}

float r3_grid(ivec3 seed, int t) {
    ivec3 basis = seed * phi3_inv;
    int offset = t * phi;
    return mod(basis.x + basis.y + basis.z + offset, ref) * to_float;
}

vec2 r2(int seed) {
    ivec2 basis = phi2 * seed;
    return mod(basis, ref) * to_float;
}

vec3 r3(int seed) {
    ivec3 basis = phi3 * seed;
    return mod(basis, ref) * to_float;
}

#endif