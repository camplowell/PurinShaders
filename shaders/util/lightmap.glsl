#if !defined LIGHTMAP
#define LIGHTMAP

// ===============================================================================================
// Large
// ===============================================================================================

float getHorizonFac(int worldTime) {
    float phase = fract((worldTime + 1000) / 12000.0);
    float fac = 2 * abs(phase - 0.5);
    return smoothstep(0, 1, fac * fac);
}

float _mixByTime(float dawn, float noon, float dusk, float night, int worldTime) {
    return mix(
        worldTime > 11000 && worldTime < 23000 ? night : noon,
        worldTime > 5000 && worldTime < 17000 ? dusk : dawn,
        getHorizonFac(worldTime));
}

vec3 _mixByTime(vec3 dawn, vec3 noon, vec3 dusk, vec3 night, int worldTime) {
    return mix(
        worldTime > 11000 && worldTime < 23000 ? night : noon,
        worldTime > 5000 && worldTime < 17000 ? dusk : dawn,
        getHorizonFac(worldTime));
}

#define mixByTime(param, worldTime) _mixByTime(param ## _DAWN, param ## _NOON, param ## _DUSK, param ## _NGHT, worldTime)

vec3 getSkyLight(vec3 skyColor, float strength) {
    float skyMax = max(skyColor.r, max(skyColor.g, skyColor.b));
    return pow(max(skyColor, 0.001), vec3(1.0 - skyMax * strength)) * strength;
}

vec3 lm2rgb(
    vec2 lmcoord, 
    float ao,
    vec3 skyColor,
    float dist
) {
    float adjustedAO = ao * 0.125 + 0.875;
    vec2 adjustedLm = lmcoord;
    adjustedLm *= adjustedLm * vec2(1, adjustedAO);
    return (
          TORCH_COL * adjustedLm.r
        + getSkyLight(skyColor, adjustedLm.g));
}

vec3 getAmbient(float dist, float ao) {
    float adjustedAO = ao * 0.125 + 0.875;
    return AMBIENT_COL * AMBIENT_VAL * adjustedAO * (32.0 / (dist + 32.0));
}

// Small -----------------------------------------------------------------------------------------

#endif