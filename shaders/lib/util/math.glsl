#if !defined MATH_GLSL
#define MATH_GLSL

// Useful constants
#define PI 3.14159265359
#define TWO_PI 6.28318530718

#define PHI 1.61803398875

// Sebastien Lagarde's fast approximation of acos(x)
float fAcos(float inX)
{
    float x = abs(inX);
    float res = -0.155972 * x + 1.56467; // p(x)
    res *= sqrt(1.0f - x);

    return (inX >= 0) ? res : PI - res; // Undo range reduction
}

#endif // End of document