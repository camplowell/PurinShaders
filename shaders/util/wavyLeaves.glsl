#if !defined WAVES
#define WAVES

#ifdef WAVY_LEAVES
// ===============================================================================================
// Large
// ===============================================================================================

float tiltedSin(float x, float bias) {
    float s = sin(x);
    float c = cos(x);
    float bc = bias + c;
    return -s * inversesqrt(bc * bc + s * s);
}

#define PI 3.14159265
vec3 wave(vec3 feetPos, float time, vec2 texcoord, vec2 midTexCoord, vec3 mc_Entity) {
    vec3 worldPos = feetPos + cameraPosition;
    float timeScale = 36.0 * PI / 3600.0;
    int blockId = int(mc_Entity.x + 0.5);
    float fast = 1.0;
    if (bitfieldExtract(blockId, 13, 1) == 1) {
        fast = 0.0;
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

    float gust = mix(tiltedSin(11 * t, 0.7), tiltedSin(13 * t, 0.7), sin(worldPos.z * 0.01) * .4 + .5) * 0.5 + 0.5;
    gust *= mix(0.5 * gust * gust, gust, windiness);
    fast *= gust;
    
    vec2 offset = sin(t * vec2(79, 89) + 0.0625 * vec2(worldPos.z, -worldPos.z)) * 0.5;
    offset += t * vec2(103, 167) + 0.2 * vec2(offset.y, -offset.x);
    offset = vec2(tiltedSin(offset.x, 0.5) + 1, sin(offset.y) * 0.5);
    offset += vec2(tiltedSin(t * 863, 0.25), sin(t * 947)) * fast * 0.125;
    offset *= 0.5 * gust * fac;
    
    //vec2 offset = vec2(gust * fac, 0);

    feetPos.xz -= offset;
    feetPos.y += sqrt(1.0 - (offset.x * offset.x + offset.y * offset.y)) - 1.0;
    //feetPos.x -= windiness * fac;
    return feetPos;
}

#endif
// Small -----------------------------------------------------------------------------------------

#endif