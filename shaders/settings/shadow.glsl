#if !defined ST_SHADOW_GLSL
#define ST_SHADOW_GLSL //DO NOT TOUCH!

#define SHADOW_CHUNKS 12 //Shadow distance in chunks. [6 8 12 16 24 32]
#define COLOR_SHADOWS // Transparent surfaces cast shadows
#define SUN_PATH_ROT -15 // Tilts the sun path. [-45 -40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45]
#define SHADOW_SAMPLES 3 // Makes shadows less noisy at the expense of speed. [1 2 3 4 8 16]
#define SHADOW_SWAY // Makes swaying leaves cast swaying shadows.

const float shadowIntervalSize = 1.0;


#if SHADOW_CHUNKS==6

	const float shadowDistance = 96.0;
	const int shadowMapResolution = 512;

	const float shadowDepthMul = 0.75;

#elif SHADOW_CHUNKS==8

	const float shadowDistance = 128.0;
	const int shadowMapResolution = 768;

	const float shadowDepthMul = 0.75;

#elif SHADOW_CHUNKS==12

	const float shadowDistance = 192.0;
	const int shadowMapResolution = 1024;

	const float shadowDepthMul = 0.75;

#elif SHADOW_CHUNKS==16

	const float shadowDistance = 256.0;
	const int shadowMapResolution = 1024;

	const float shadowDepthMul = 0.75;

#elif SHADOW_CHUNKS==24

	const float shadowDistance = 384.0;
	const int shadowMapResolution = 2048;

	const float shadowDepthMul = 0.50;

#elif SHADOW_CHUNKS==32

	const float shadowDistance = 512.0;
	const int shadowMapResolution = 2048;

	const float shadowDepthMul = 0.50;

#endif

#if SUN_PATH_ROT==-45
	const float sunPathRotation = -45.0;
#elif SUN_PATH_ROT==-40
	const float sunPathRotation = -40.0;
#elif SUN_PATH_ROT==-35
	const float sunPathRotation = -35.0;
#elif SUN_PATH_ROT==-30
	const float sunPathRotation = -30.0;
#elif SUN_PATH_ROT==-25
	const float sunPathRotation = -25.0;
#elif SUN_PATH_ROT==-20
	const float sunPathRotation = -20.0;
#elif SUN_PATH_ROT==-15
	const float sunPathRotation = -15.0;
#endif

#endif