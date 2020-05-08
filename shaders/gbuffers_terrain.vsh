#version 120

#include "/lib/framebuffer.glsl"

varying vec3 tintColor;

varying vec3 normal;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

varying float distance2D;

void main() {

  vec4 position = gl_ModelViewMatrix * gl_Vertex;

  position = gbufferModelViewInverse * position;

  distance2D = position.x * position.x + position.z * position.z;

  distort(position, distance2D);

  position = gbufferModelView * position;

  gl_Position = gl_ProjectionMatrix * position;

  texcoord = gl_MultiTexCoord0;
  lmcoord = gl_MultiTexCoord1;
  tintColor = gl_Color.rgb;
  normal = normalize(gl_NormalMatrix * gl_Normal);
}
