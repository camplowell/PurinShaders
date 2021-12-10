#if !defined LIGHT_COL_GLSL
#define LIGHT_COL_GLSL

#include "/lib/util/math.glsl"

#if defined(VERTEX) || defined(SUN_DIR) || defined(SUN_DIR_EARLY)
void resolveSunDir() {
#if defined(SUN_DIR_EARLY)
    // Recalculate Optifine's sunPos in scene space (sunPosition is behind a frame here)
    float sunPhase = fract(worldTime / 24000.0 - 0.25);
    float sunTheta = (sunPhase + (cos(sunPhase * PI) * -0.5 + 0.5 - sunPhase) / 3.0) * 2.0 * PI;
    vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994));
    sunDir = vec3(-sin(sunTheta), cos(sunTheta) * sunRotationData);
#else
    sunDir = normalize(mat3(gbufferModelViewInverse) * sunPosition + gbufferModelViewInverse[3].xyz);
#endif
}
#endif

// Get the mix factor between sunrise/sunset and day/night
// sunrise/sunset = 0, day/night = 1
// Requires sunDir
const float SUN_MIX_F0 = 0.1;
const float SUN_MIX_WIDTH = SUN_MIX_F0 / (1. - SUN_MIX_F0);
float azimuthColorFac(float vy, float f0, float width) {
    return (1.0 - (width / (pow(vy - 0.2, 2) + width))) 
                * (1. / (1. - f0));
}

#define mixByTime(morn, day, eve, night) mix(mix(morn, eve, float(sunDir.x < 0.0)), mix(day, night, float(sunDir.y < 0.2)), azimuthColorFac(sunDir.y, SUN_MIX_F0, SUN_MIX_WIDTH))

float getSunVisibility(float sunY, float viewY, float VoL) {
    return smoothstep(-0.2, 0.1, 
            sunY
          + 0.2 * smoothstep(-.1, .1 * (1. - VoL), viewY))
      * smoothstep(-0.2, 0.1, sunY);
}


#endif // end of document