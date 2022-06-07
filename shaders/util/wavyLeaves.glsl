#if !defined WAVES
#define WAVES

// ===============================================================================================
// Large
// ===============================================================================================
#define PI 3.14159265
vec3 wave(vec3 feetPos, float time, vec2 texcoord, vec2 midTexCoord, vec3 mc_Entity) {
    vec3 worldPos = feetPos + cameraPosition;
    float timeScale = 36.0 * PI / 3600.0;
    int blockId = int(mc_Entity.x + 0.5);
    float flick = 1.0;
    if (bitfieldExtract(blockId, 13, 1) == 1) {
        flick = 0.0;
    }
    float windiness = 1.0 - (16.0 / (16 + max(0, worldPos.y - 63)));

    int weightType = bitfieldExtract(blockId, 10, 3);
    float yFac = 1.0;
    float fac = 1.0;
    float yTime = 1.0;
    bool bottom = texcoord.y > midTexCoord.y;
    
    if (weightType == 0) {
        // Not swaying
        return feetPos;
    } else if (weightType == 1 || weightType == 3) {
        // single or double plant (bottom)
        fac = bottom ? 0.0 : 1.0;  
    }else if (weightType == 2) {
        // double plant (top)
        fac = bottom ? 1.0 : 2.0;
    } else if (weightType == 4) {
        // Hanging (ex: chain)
        yFac = 0.0;
        yTime = -1.0;
    } else if (weightType == 5) {
        // Floating (ex: seaweed, lilypad)
        yFac = 0.0;
    }
    fac *= 0.25;
    
    float t = (time + 0.0625 * worldPos.x - 0.125 * yFac * worldPos.y) * timeScale;
    float gust = cos(5 * t + 0.0625 * worldPos.z + 0.5 * sin(47 * t)) * sin(3 * t + 0.5 * cos(7 * t + 0.125 * worldPos.z));
    gust = 0.5 * gust * gust + windiness;
     
    vec2 offset = vec2(sin(83 * t + 0.25 * cos(151 * t + gust * sin(647 * t))), 0.25 * cos(79 * t + 0.5 * gust * sin(181 * t)));
    offset = fac * (0.5 * gust * flick * offset + vec2(gust, 0));
    feetPos.xz -= offset;
    feetPos.y += sqrt(1.0 - (offset.x * offset.x + offset.y * offset.y)) - 1.0;
    //feetPos.x -= windiness * fac;
    return feetPos;
}
// Small -----------------------------------------------------------------------------------------

#endif