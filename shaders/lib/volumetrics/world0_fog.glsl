#if !defined(W0_FOG_GLSL)
#define W0_FOG_GLSL

#include "/settings/overworld_sky.glsl"

#include "/lib/util/math.glsl"
#include "/lib/lighting/lightColor.glsl"
#include "/lib/volumetrics/exponentialFog.glsl"

/*
float MIE_FALLOFF;
float MIE_DENSITY;
float mieIsotropy;
vec3 rayleighCol;
vec3 mieCol;
*/

#if defined(VERTEX)
void resolveSkyParams() {
    float rainSmoothed =  rainStrength * rainStrength * rainStrength;
    MIE_FALLOFF = mix(mixByTime(MIE_MORN_F, MIE_DAY_F, MIE_EVE_F, MIE_NGHT_F), MIE_RAIN_F, rainSmoothed);
    MIE_DENSITY = mix(mixByTime(MIE_MORN_A, MIE_DAY_A, MIE_EVE_A, MIE_NGHT_A), MIE_RAIN_A, rainSmoothed) * 0.00390625;
    mieIsotropy = mix(0.8, 0.10, rainStrength);
    rayleighCol = mixByTime(SKY_MORN_COL, SKY_DAY_COL, SKY_EVE_COL, SKY_NGHT_COL);
    mieCol = mixByTime(MIE_MORN_COL, MIE_DAY_COL, MIE_EVE_COL, MIE_NGHT_COL);
}
#endif

vec3 backgroundRayleighOpacity(float vy) {
    float d = max(eyeAltitude - SEA_LEVEL, 4.0);

    float d0 = (vy < 0.0) ?
          getOpticalDepth(0., d, d, SKY_FALLOFF, SKY_DENSITY) 
        : getInfiniteDepth(eyeAltitude - SEA_LEVEL, 1., SKY_FALLOFF, SKY_DENSITY);

    vec3 f0 = 1. - exp(-d0 * (0.5 * SKY_BASE_COL + 0.5));
    vec3 lobeW = f0 / (1.0 - f0);
    return lobeW / ((vy * vy) + lobeW);
}

float backgroundMieOpacity(float vy) {
    float d = max(eyeAltitude - SEA_LEVEL, 4.0);
    float d0 = vy > 0.0 ? 
          getInfiniteDepth(eyeAltitude - SEA_LEVEL, 1.0, MIE_FALLOFF, MIE_DENSITY)
        : getOpticalDepth(0., d, d, MIE_FALLOFF, MIE_DENSITY);
    float f0 = 1.0 - exp(-d0);
    float lobeW = f0 / (1.0 - f0);
    return lobeW / ((vy * vy) + lobeW);
}

vec3 fogRayleighOpacity(vec3 eyeViewPos) {
    float d = getOpticalDepth(eyeAltitude - SEA_LEVEL, eyeViewPos.y, length(eyeViewPos), SKY_FALLOFF, SKY_DENSITY);
    return 1.0 - exp(-d * (0.5 * SKY_BASE_COL + 0.5));
}
float fogMieOpacity(vec3 eyeViewPos) {
    float d = getOpticalDepth(eyeAltitude - SEA_LEVEL, eyeViewPos.y, length(eyeViewPos), MIE_FALLOFF, MIE_DENSITY);
    return 1.0 - exp(-d);
}

vec3 getSkyColor(float viewY, float sunY, float VoL, vec3 rayleighOpacity, float mieOpacity, float distanceFade) {
    vec3 rayleigh = rayleighOpacity * 20.0 * RayleighPhaseFunction(VoL) * rayleighCol;
    //float localIsotropy = mix(0.1, mieIsotropy, distanceFade);
    vec3 mie = ((8.0 * mix(sunCol, SUN_COL_DAY, rainStrength) * mix(MiePhaseFunction(0.1, VoL), MiePhaseFunction(mieIsotropy, VoL), distanceFade) * getSunVisibility(sunY, viewY, VoL))
                            + (4.0 * MOON_COL * mix(MiePhaseFunction(0.1, -VoL), MiePhaseFunction(mieIsotropy, -VoL), distanceFade) * getSunVisibility(-sunY, viewY, -VoL))
                            + mieCol * mix(2.0, MIE_RAIN_DARKEN, smoothstep(0., 1., rainStrength)));
    
    //vec3 mie = vec3(MiePhaseFunction(mieIsotropy, -VoL) * getSunVisibility(-sunY, viewY, -VoL));
    //mie *= mieOpacity;
    vec3 ret = mix(rayleigh, mie, mieOpacity);
    float maxC = max(ret.r, max(ret.g, ret.b));
    return ret / (1.0 + mix(vec3(maxC), ret, 0.75)); //rayleigh * (1.0 - 0.5 * mieOpacity) + 0.5 * mie / (0.5 + maxC);
}

vec4 getFog() {
   vec3 viewDir = normalize(eyePlayerPos);
   float dist = length(eyePlayerPos);
   //float d2d = length(eyePlayerPos.xz);

   float fadeEnd = (far - 22.627416998);
   float fac = smoothstep(0.6 * far, far, dist);

   vec3 rayleighOpacity = mix(fogRayleighOpacity(eyePlayerPos), backgroundRayleighOpacity(viewDir.y), fac);
   float mieOpacity = mix(fogMieOpacity(eyePlayerPos), backgroundMieOpacity(viewDir.y), fac);

   //return vec4();
   return vec4(getSkyColor(viewDir.y, sunDir.y, dot(viewDir, sunDir), rayleighOpacity, mieOpacity, fac), mix(mieOpacity, 1.0, fac));
}

#endif // end of document