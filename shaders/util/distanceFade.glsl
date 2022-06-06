#if !defined DISTANCEFADE
#define DISTANCEFADE

float sharpstep(float x) {
  // Evaluate polynomial
  return x+(x-(x*x*(3-2*x)));
}

float distanceFade(float dist) {
    float cullFac = r2_grid(ivec2(gl_FragCoord.xy), frameCounter);
    cullFac = sharpstep(cullFac); //smootherstep(cullFac);
    if (dist > (far - (FADE_SIZE * cullFac))) {
        return 0.0;
    }
    return 1.0;
}

float distanceFade(vec3 viewPos) {
    return distanceFade(length(viewPos));
}

#endif