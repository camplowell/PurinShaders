float sharpstep(float x) {
  // Evaluate polynomial
  return x+(x-(x*x*(3-2*x)));
}

void distanceFade(float dist) {
    float cullFac = r2_grid(ivec2(gl_FragCoord.xy), frameCounter);
    cullFac = sharpstep(cullFac); //smootherstep(cullFac);
    if (dist > (far - (FADE_SIZE * cullFac))) {
        discard;
    }
}

void distanceFade(vec3 viewPos) {
    distanceFade(length(viewPos));
}