#if !defined(BLOCKLIGHT_GLSL)
#define BLOCKLIGHT_GLSL

#include "/settings/lighting.glsl"
#include "/lib/lighting/lightColor.glsl"

#include "/lib/util/texelSnap.glsl"

// polynomial smooth min (k = 0.1);
float smax( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return max( a, b ) + h*h*h*k*(1.0/6.0);
}

vec3 lightmap2color(vec2 lmcoord, float subsurfaceFac, vec2 off2texel) {
    float ao_q = quantize(ao, off2texel);

    ao_q = pow(ao_q, 1.0 / (2.0 + subsurfaceFac)) * 0.5 + 0.5;

    vec2 lmcoordAdjusted = quantize(lmcoord, off2texel) * vec2(LM_TORCH.a, lmSkyCol.a);
    lmcoordAdjusted.y *= ao_q;
    float totalBright = (lmcoordAdjusted.x + lmcoordAdjusted.y);

    float brightness = smax(lmcoordAdjusted.x, lmcoordAdjusted.y, totalBright) * 0.75;
    float weight = totalBright < 0.000001 ? 0.5 : smoothstep(0.0, totalBright, lmcoordAdjusted.x); //pow(clamp(lmcoordAdjusted.x / totalBright, 0.0, 1.0), 1.5);

    vec3 col = mix(lmSkyCol.rgb, LM_TORCH.rgb, weight);
    col = pow(col, vec3((1.0 - max(lmcoordAdjusted.x, lmcoordAdjusted.y)) * lightFalloff));// * brightness;

    return max(W0_DARK.rgb * W0_DARK.a * ao_q, col * brightness);
}

vec3 lightmap2colorBasic(vec2 lmcoord) {
    //float ao_q = quantize(ao, off2texel);

    //ao_q = pow(ao_q, 1.0 / (2.0 + subsurfaceFac)) * 0.5 + 0.5;

    vec2 lmcoordAdjusted = lmcoord * vec2(LM_TORCH.a, lmSkyCol.a);
    //lmcoordAdjusted.y *= ao_q;
    float totalBright = (lmcoordAdjusted.x + lmcoordAdjusted.y);

    float brightness = smax(lmcoordAdjusted.x, lmcoordAdjusted.y, totalBright) * 0.75;
    float weight = totalBright < 0.000001 ? 0.5 : smoothstep(0.0, totalBright, lmcoordAdjusted.x); //pow(clamp(lmcoordAdjusted.x / totalBright, 0.0, 1.0), 1.5);

    vec3 col = mix(lmSkyCol.rgb, LM_TORCH.rgb, weight);
    col = pow(col, vec3((1.0 - max(lmcoordAdjusted.x, lmcoordAdjusted.y)) * lightFalloff));// * brightness;

    return max(W0_DARK.rgb * W0_DARK.a, col * brightness);
}

#endif // end of document