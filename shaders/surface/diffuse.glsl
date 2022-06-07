#if !defined DIFFUSE
#define DIFFUSE

vec3 shade(vec3 albedo, vec3 lighting) {
    return mix(pow(albedo, 1 / lighting), albedo * lighting, step(lighting, vec3(1.0)));
}

vec3 shadeDiffuse(vec3 albedo, vec3 lightmap, vec3 normal) {
    float oldEmulation = 0.75 + (0.15 * normal.y) - (0.1 * abs(normal.x));
    return shade(oldEmulation * albedo, lightmap);
}

vec3 shadeDiffuse(vec3 albedo, vec3 lightmap, vec3 normal, vec3 ambient) {
    float oldEmulation = 0.75 + (0.15 * normal.y) - (0.1 * abs(normal.x));
    vec3 shaded = shade(oldEmulation * albedo, lightmap);
    float lum = max(albedo.r, max(albedo.g, albedo.b));
    vec3 raisedAlbedo = albedo * (sqrt(lum) / lum);
    vec3 amb = oldEmulation * raisedAlbedo * ambient;
    return shaded + amb * (1 - dot(lightmap, vec3(0.299, 0.587, 0.114)));
}

#endif