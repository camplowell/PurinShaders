#if !defined LIGHTMAP
#define LIGHTMAP

// ===============================================================================================
// Large
// ===============================================================================================

vec3 getSkyLight(vec3 skyColor, float strength) {
    float skyMax = max(skyColor.r, max(skyColor.g, skyColor.b));
    return pow(max(skyColor, 0.01), vec3(1.0 - skyMax * strength)) * strength;
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
        + getSkyLight(skyColor, adjustedLm.g)
        + AMBIENT_COL * adjustedAO * inversesqrt(0.125 * dist + 1));
}

// Small -----------------------------------------------------------------------------------------

#endif