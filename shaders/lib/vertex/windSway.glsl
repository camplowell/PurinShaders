/* Dependencies:
 * feetPlayerPos
 * worldPos
 * rainStrength
 * wetness
 * frameTimeCounter
 * mc_midTexCoord
 */

#if !defined WIND_SWAY_GLSL
#define WIND_SWAY_GLSL

#include "/lib/util/math.glsl"
#include "/settings/vertex.glsl"

const vec4 windFalloffs = vec4(1.0, 4.0, 12.0, 3.0);

vec3 calculateWindSway(float amt) {
   float windStrength = max(rainStrength, wetness) * 1.5 + (worldPos.y / 128.0 + 0.25);
   float time = frameTimeCounter * PI; // 1 rotation every 2 seconds  
   windStrength *= (sin(time * 0.03 + sin(0.07 * time)) * 0.2 + 0.4) * amt;

   vec3 tOff = vec3(0.1, 0.3, 0.5) * (worldPos.x - worldPos.y);
   vec4 cFac = max(1.0 - (windFalloffs / (windStrength + windFalloffs * vec4(1.0, 1.0, 0.5, 1.0))), 0.0);
   cFac.rb *= amt;

   vec2 offset = vec2(
      sin(0.7 * time + tOff.x + cFac.y * sin(2.1 * time + tOff.y)) + cFac.z * (sin(5.3 * time + tOff.z) * 0.5 - windStrength),
      cos(0.9 * time + tOff.x + cFac.y * cos(2.3 * time + tOff.y + cFac.z * cos(5.7 * time + tOff.z)))
   ) * cFac.x * 0.5;

   offset.x = mix(offset.x, -1.0, cFac.w);
   offset.y *= 0.5;

   return vec3(offset.x, 0.5 / (dot(offset, offset) + 0.5) - 1.0, offset.y);
}

vec3 calculateWaterSway(float amt) {
   float time = frameTimeCounter * PI; // 1 rotation every 2 seconds
   float windStrength = (max(rainStrength, wetness) * 0.5 + 1.0);
   windStrength *= (sin(time * 0.04 + sin(0.11 * time)) * 0.25 + 0.5) * amt;

   vec2 cFac = max(1.0 - windFalloffs.xy / (windStrength + windFalloffs.xy), 0.0);

   float tOff = (worldPos.x - worldPos.y) * 0.2;
   vec2 offset = vec2(
         sin(0.3 * time + tOff + cFac.y * amt * sin(0.7 * time + tOff)),
         cos(0.4 * time + tOff + cFac.y * amt * cos(1.1 * time + tOff))
   ) * 0.5 * cFac.x;

   return vec3(offset.x, 0.5 / (dot(offset, offset) + 0.5) - 1.0, offset.y);
}

vec3 applySway(int id) {
   vec3 pos = feetPlayerPos;
   if (id > 0 && id < 10) {
      float amt = LEAF_SWAY;
      if (id == 1 || id == 2 || id == 7) {
         // single plants
         amt = float(texcoord.y < mc_midTexCoord.y);
      } else if (id == 3 || id == 4 || id == 8 || id == 9) {
         // double plants
         amt = (float(texcoord.y < mc_midTexCoord.y) + float(id == 4));
      }
      vec3 offset;

      if (id < 6) {
         offset = calculateWindSway(amt);
      }
#if defined(SEAGRASS_SWAY) && defined(LILYPAD_SWAY)
      else {
         offset = calculateWaterSway(amt);
      }
      offset.y *= float(id != 6);
#elif defined SEAGRASS_SWAY
      else if (id > 6) {
         offset = calculateWaterSway(amt);
      }
#elif defined LILYPAD_SWAY
      else if (id == 6) {
         offset = calculateWaterSway(amt);
      }
      offset.y *= float(id != 6);
#endif

      pos += offset;
      glcolor *= 1.0 - offset.y * SWAY_HIGHLIGHTS * float(id < 6);
   }
   return pos;
}

#endif // End of document