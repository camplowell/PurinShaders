#if !defined TAA
#define TAA

// ===============================================================================================
// Large
// ===============================================================================================

vec3 feet2prev(vec3 feetPos) {
    return feetPos + (cameraPosition - previousCameraPosition);
}

vec3 view2prev(vec3 viewPos) {
    return feet2view(feet2prev(view2feet(viewPos)), gbufferPreviousModelView);
}

#if defined FRAGMENT
vec2 getOffset(vec4 clipPos_prev) {
    vec2 screenPos = vec2(gl_FragCoord.xy / vec2(viewWidth, viewHeight));
    vec2 screenPos_prev = (clipPos_prev.xy / clipPos_prev.w) * 0.5 + 0.5;
    return screenPos_prev - screenPos;
}
#endif

vec2 getJitter() {
    return (r2(frameCounter) - 0.5) / vec2(viewWidth, viewHeight);
}

vec4 jitter(vec4 clipPos) {
    return clipPos + vec4(getJitter() * 2.0 * clipPos.w, 0, 0);
}

// Small -----------------------------------------------------------------------------------------

#endif