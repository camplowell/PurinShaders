#if !defined PANINI
#define PANINI

// ===============================================================================================
// Large
// ===============================================================================================
#if PANINI_FAC == 0

vec4 panini(vec3 viewPos, vec3 upPosition) {
    return view2clip(viewPos);
}

vec3 paniniInverse(vec3 paniniPos, vec3 upPosition) {
    return ndc2view(paniniPos);
}

#else

const float PANINI_OFF = PANINI_FAC * 0.0066667;

vec3 warpView(vec3 viewPos, float vFac, float factor) {
    float dist = length(viewPos);

    vec3 warp = normalize(viewPos);
    warp -= vec3(0, 0, factor);
    warp = normalize(warp);

    return warp * dist;
}

float getPaniniScale(float vFac, float factor) {
    vec3 corner = ndc2view(vec3(1));
    corner /= length(corner * vec3(1, max(0, vFac), 1));
    return (corner.z - factor) / corner.z;
}

float intersect(vec3 dir, float zOff, float vFac) {
    // O^2 + vDt^2 + 2OvDt = 1
    // a = vD^2
    // b = 2OvD
    // c = O^2 - 1
    vec3 vD = dir * vec3(min(1.0, vFac + 1.0), max(0, vFac), 1);
    float a = dot(vD, vD);
    float b = 2 * zOff * vD.z;
    float c = zOff * zOff - 1;

    float discr = b * b - 4 * a * c;
    float q = (b > 0) ? 
            -0.5 * (b + sqrt(discr)) : 
            -0.5 * (b - sqrt(discr));
    return max(q / a, c / q);
}

vec4 panini(vec3 viewPos, vec3 upPosition) {

#if DISTORT_DOWN == 1
    float vFac = abs(0.01 * upPosition.z);
#else
    float vFac = -0.01 * upPosition.z;
#endif
    
    vFac *= abs(vFac);
    float scale = getPaniniScale(vFac, PANINI_OFF);
    // Capture ray length
    float dist = length(viewPos);

    // Project onto distortion surface
    vec3 warpPos = viewPos / length(viewPos * vec3(min(1.0, vFac + 1.0), max(0, vFac), 1));
    warpPos -= vec3(0, 0, PANINI_OFF);

    // Restore ray length
    vec3 warped = normalize(warpPos) * dist;

    // Project and restore FOV
    vec4 projected = view2clip(warped);
    projected.xy *= scale;

    return projected;
}

vec3 paniniInverse(vec3 ndc, vec3 upPosition) {

#if DISTORT_DOWN == 1
    float vFac = abs(0.01 * upPosition.z);
#else
    float vFac = -0.01 * upPosition.z;
#endif

    vFac *= abs(vFac);
    float scale = getPaniniScale(vFac, PANINI_OFF);
    ndc.xy /= scale;

    vec3 viewPos = ndc2view(ndc);
    // Capture ray length and direction
    vec3 viewDir = normalize(viewPos);
    float dist = length(viewPos);

    // Project onto distortion surface
    vec3 warpPos = viewDir * intersect(viewDir, PANINI_OFF, vFac);
    warpPos += vec3(0, 0, PANINI_OFF);

    // Restore ray length
    vec3 unwarped = normalize(warpPos) * dist;

    return unwarped;
}

#endif
// Small -----------------------------------------------------------------------------------------

#endif