uniform sampler2D gcolor;
uniform sampler2D gnormal;
uniform sampler2D gdepth;

uniform float frameTimeCounter;

const int RGBA = 0;
const int RGBA16 = 1;
const int gcolorFormat = RGBA16;
const int gdepthFormat = RGBA;
const int gnormalFormat = RGBA16;
//const int shadowMapResolution = 4096;
//const float sunPathRotation = 25.0;
//const int noiseTextureResolution = 64;

#define GCOLOR_OUT gl_FragData[0]
#define GDEPTH_OUT gl_FragData[1]
#define GNORMAL_OUT gl_FragData[2]
#define PI 3.14159265359

#define framebuffer
#include "/shaders.settings"

float percentage = STRENGTH;

float intensity() {
  #ifdef VARYING_INTENSITY
    return sin(frameTimeCounter/(percentage+1)) * percentage;
  #else
    return percentage;
  #endif
}

void colorCorrect(inout vec3 color, in float distance2D) {
  float r = color.r;
  float g = color.g;
  float b = color.b;
  float v = 0.75;
  float i = percentage;
  float graph = ((frameTimeCounter*i)/(COLOR_BAND_SIZE * v) + (distance2D/pow(distance2D, v))/COLOR_BAND_SIZE);

  r = sin(graph);
  g = sin(graph + (2 * PI/3));
  b = sin(graph + (4 * PI/3));

  color = color + (vec3(r, g, b) * (intensity() * COLOR_STRENTH/4));
}

void distort(inout vec4 position, in float distance2D) {
  float i = percentage;
  position.y += intensity() * sin(distance2D/1000 + frameTimeCounter*i) * distance2D/1000 * WAVING_STRENGTH;

  float y = position.y;
  float x = position.x;

  float theta = sin(frameTimeCounter + intensity()) * sin(cos(frameTimeCounter/2400))/10 * ROTATION_STRENGTH;

  // rotation
  position.y = x * sin(theta) + y * cos(theta);
  position.x = x * cos(theta) - y * sin(theta);
}

vec3 getAlbedo(in vec2 coord) {
  return pow(texture2D(gcolor, coord).rgb, vec3(2.2));
}

vec3 getNormal(in vec2 coord) {
  return texture2D(gnormal, coord).rgb * 2.0 - 1.0;
}

float getEmission(in vec2 coord) {
  return texture2D(gdepth, coord).a;
}

float getBlockLight(in vec2 coord) {
  return texture2D(gdepth, coord).r;
}

float getSkyLight(in vec2 coord) {
  return texture2D(gdepth, coord).g;
}
