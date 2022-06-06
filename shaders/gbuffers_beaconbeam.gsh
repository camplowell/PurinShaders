#version 410 compatibility
//#extension GL_ARB_geometry_shader4 : enable
#define GEOMETRY

#include "/util/common.glsl"
#include "/util/panini.glsl"
#include "/util/taa.glsl"

layout(triangles) in;
layout(triangle_strip, max_vertices = 48) out;

in VertexAttrib
{
  vec2 texcoord;
  vec4 glcolor;
} vertex[];

out vec2 texcoord;
out vec4 glcolor;

uniform vec3 upPosition;

void main() {
    vec3 pos[3];
    for (int i = 0; i < 3; i++) {
        pos[i] = (gl_ModelViewMatrix * gl_in[i].gl_Position).xyz;
    }
    vec3 from = pos[0];
    vec3 to = 0.5 * (pos[1] + pos[2]);
    vec3 dir = normalize(to - from);

    float tClosest = dot(-from, dir) / length(to - from);
    float d = length(from + dir * tClosest);
    float overlap = sqrt(far * far - d * d);

    // Determine section of beacon beam inside view distance (spherical)
    float start = max(0, tClosest - overlap);
    float stop = min(1, tClosest + overlap);

    // Cull segment behind the camera
    float startZ = pos[0].z;
    float stopZ = pos[1].z;
    if (startZ > 0) {
        start = startZ / (startZ - stopZ);
    }
    if (stopZ > 0) {
        stop = startZ / (startZ - stopZ);
    }
    // Remap tClosest to the range (start, stop)
    tClosest = clamp((tClosest - start) / (stop - start), 0, 1);
    for(int i=0; i<48; i++) {
        float fac = (i / 2) / 23.0;
        if (i > 1 && i < 46) {
            // Bias the detail towards the closest point
            fac = (fac - tClosest);
            fac = mix(fac * fac * fac, fac * abs(fac), 1.0 / (d + 1.0)) + tClosest;
        }
        // Remap factor to the beam's full range
        fac = mix(start, stop, fac);
        // Spawn vertices
        vec3 viewPos = mix(pos[0], pos[2 - i % 2], fac);
        gl_Position =  jitter(panini(viewPos, upPosition));
        texcoord = mix(vertex[0].texcoord, vertex[2 - i % 2].texcoord, fac);
        glcolor = mix(vertex[0].glcolor, vertex[2 - i % 2].glcolor, fac);
        EmitVertex();
    }
    EndPrimitive();
}