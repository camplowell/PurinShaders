#version 150 compatibility
#define COMPOSITE

out vec2 texcoord;

// ===============================================================================================
// Global variables
// ===============================================================================================

// ===============================================================================================
// Includes
// ===============================================================================================

// ===============================================================================================
// Helpers
// ===============================================================================================

// ===============================================================================================
// Main
// ===============================================================================================

void main() {
   gl_Position = ftransform();
   texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}