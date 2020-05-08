#version 120

#include "/lib/framebuffer.glsl"

attribute vec4 mc_Entity;

varying vec4 texcoord;
varying vec4 color;
varying float isTransparent;

float getIsTransparent(in float materialID) {
  if(materialID == 160.0) {
    return 1.0;
  }
  if(materialID == 95.0) {
    return 1.0;
  }
  if(materialID == 79.0) {
    return 1.0;
  }
  return 0;
}

void main() {
  texcoord = gl_MultiTexCoord0;
  color = gl_Color;

  isTransparent = getIsTransparent(mc_Entity.x);

  gl_Position = ftransform();
}
