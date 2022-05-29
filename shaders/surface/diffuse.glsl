#if !defined DIFFUSE
#define DIFFUSE

vec3 shade(vec3 albedo, vec3 lighting) {
    return mix(pow(albedo, 1 / lighting), albedo * lighting, step(lighting, vec3(1.0)));
}

vec3 shadeDiffuse(vec3 albedo, vec3 lightmap, vec3 normal) {
    float oldEmulation = 0.75 + (0.15 * normal.y) - (0.1 * abs(normal.x));
    return shade(oldEmulation * albedo, lightmap);
}

#endif