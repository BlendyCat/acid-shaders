#version 120

#define PI 3.14159265359
#define final
#include "shaders.settings"

varying vec4 texcoord;

uniform sampler2D gcolor;
uniform float frameTimeCounter;

void vignette(inout vec3 color) {
  float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
  dist /= 1.5142f;
  dist = pow(dist, 1.2f);

  color.rgb *= 1.0f - (dist * 0.5);
}

void chromaticAberration(inout vec3 color) {
  float dist = distance(texcoord.st, vec2(0.5));
  dist /= 40;
  dist = pow(dist + 0.003, 1.4f) * CHROMATIC_ABERRATION;
  float red = texture2D(gcolor, texcoord.st + vec2(dist)).r;
  //dist /= 2;
  float green = texture2D(gcolor, texcoord.st + vec2(-dist)).g;
  color.r = red;
  color.g = green;
}

vec3 convertToHDR(in vec3 color) {
  vec3 hdrImage;

  vec3 overExposed = color * 1.5;
  vec3 underExposed = color / 1.5f;

  hdrImage = mix(underExposed, overExposed, color);

  return hdrImage;
}

void getExposure(inout vec3 color) {
  color*= 1.12;
}

void Reinhard(inout vec3 color) {
  color = color / (1.0 + color);
}

void Burgess(inout vec3 color) {
  vec3 maxColor = max(vec3(0.0), color - 0.004);
  color = (maxColor * (6.2 * maxColor + 0.05)) / (maxColor * (6.2 * maxColor + 2.7) + 0.06);
}

void gamma(inout vec3 color) {
  color = pow(color, vec3(1/2.2));
}

float A = 0.15;
float B = 0.50;
float C = 0.10;
float D = 0.20;
float E = 0.02;
float F = 0.30;
float W = 11.2;

vec3 uncharted2Math(in vec3 x) {
  return ((x * (A * x + C * B) + D * E)/(x * (A * x + B) + D * F)) - E / F;
}

vec3 uncharted2Tonemap(in vec3 color) {
  vec3 retColor;
  float exposureBias = 2.0;

  vec3 curr = uncharted2Math(exposureBias * color);

  vec3 whiteScale = vec3(1.0)/uncharted2Math(vec3(W));
  retColor = curr * whiteScale;

  return retColor;
}

void main() {
  vec3 color = texture2D(gcolor, texcoord.st).rgb;
  chromaticAberration(color);
  gamma(color);

  //vignette(color);


  gl_FragColor = vec4(color, 1.0f);
}
