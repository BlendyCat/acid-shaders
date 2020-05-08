#version 120

#include "/lib/framebuffer.glsl"

uniform sampler2D texture;

varying vec3 tintColor;
varying vec3 normal;

varying vec4 texcoord;
varying vec4 lmcoord;

varying float distance2D;

void main() {
  vec4 blockColor = texture2D(texture, texcoord.st);
  blockColor.rgb *= tintColor;

  colorCorrect(blockColor.rgb, distance2D);

  GCOLOR_OUT = blockColor;
  GNORMAL_OUT = vec4(normal * 0.5 + 0.5, 1.0f);
  GDEPTH_OUT = vec4(lmcoord.st / 16.0, 0.0, 0.0);
}
