#if !defined(EXP_FOG_GLSL)
#define EXP_FOG_GLSL

#include "/lib/util/math.glsl"

float getOpticalDepth(float altitude, float diffY, float dist, float falloff, float density) {
    vec2 y = vec2(altitude, altitude + diffY) / falloff;
    vec2 eny = exp(-y);
    float avgDensity = diffY == 0 ? eny[0] : (eny[0] - eny[1]) / (y[1] - y[0]);
    return dist * avgDensity * density;
}

float getInfiniteDepth(float altitude, float vY, float falloff, float density) {
   return falloff * density * exp(-altitude * vY / falloff) / vY;
}

float RayleighPhaseFunction(float nu) {
    float k = 3.0 / (16.0 * PI);
    return k * (1.0 + nu * nu);
}

float MiePhaseFunction(float g, float nu) {
    float g2 = g * g;
    float k = 3.0 / (8.0 * PI) * (1.0 - g2) / (2.0 + g2);
    return k * (1.0 + nu * nu) / pow(1.0 + g2 - 2.0 * g * nu, 1.5);
}

#endif // end of document