#version 120

#include "/lib/framebuffer.glsl"

varying vec4 texcoord;

varying vec3 lightVector;
varying vec3 lightColor;
varying vec3 skyColor;


/*uniform vec3 cameraPosition;
uniform sampler2D gdepthtex;*/
// depth from the sun to the closest pixel to the sun
/*uniform sampler2D shadow;
uniform sampler2D shadowcolor0;*/

/*uniform sampler2D noisetex;*/

/*uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float viewHeight;
uniform float viewWidth;*/

/*uniform mat4 shadowModelView;
uniform mat4 shadowProjection;*/


/*float getDepth(in vec2 coord) {
  return texture2D(gdepthtex, coord).r;
}*/

/*vec4 getCameraSpacePosition(in vec2 coord) {
  float depth = getDepth(coord);
  vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
  vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;
  return positionCameraSpace / positionCameraSpace.w;
}

vec4 getWorldSpacePosition(in vec2 coord) {
  vec4 positionCameraSpace = getCameraSpacePosition(coord);
  vec4 positionWorldSpace = gbufferModelViewInverse * positionCameraSpace;
  positionWorldSpace.xyz += cameraPosition;
  return positionWorldSpace;
}*/

/*vec3 getShadowSpacePosition(in vec2 coord) {
  vec4 positionWorldSpace = getWorldSpacePosition(coord);

  positionWorldSpace.xyz -= cameraPosition;
  vec4 positionShadowSpace = shadowModelView * positionWorldSpace;
  positionShadowSpace = shadowProjection * positionShadowSpace;
  positionShadowSpace /= positionShadowSpace.w;

  //float distance2D = positionShadowSpace.x * positionShadowSpace.x + positionShadowSpace.z * positionShadowSpace.z;
  //distort(positionShadowSpace, distance2D);

  return positionShadowSpace.xyz * 0.5 + 0.5;
}*/

/*mat2 getRotationMatrix(in vec2 coord) {
  float theta = texture2D(
    noisetex,
    coord * vec2(
      viewWidth / noiseTextureResolution,
      viewHeight / noiseTextureResolution
      )
  ).r;
  return mat2(
    cos(theta), - sin(theta),
    sin(theta), cos(theta)
  );
}*/

/*vec3 getShadowColor(in vec2 coord) {
  vec3 shadowCoord = getShadowSpacePosition(coord);

  mat2 rotationMatrix = getRotationMatrix(coord);
  float visibility = 0;
  vec3 shadowColor = vec3(0);
  for(int y = -1; y <= 2; y++) {
    for(int x = -1; x <= 2; x++) {
      vec2 offset = vec2(x, y) / shadowMapResolution;
      offset = rotationMatrix * offset;
      float shadowMapSample = texture2D(shadow, shadowCoord.st + offset).r;
      visibility = step(shadowCoord.z - shadowMapSample, 0.00005);

      vec3 colorSample = texture2D(shadowcolor0, shadowCoord.st + offset).rgb;
      shadowColor += mix(colorSample, vec3(1.0), visibility);
    }
  }
  return shadowColor *= 0.111;
}*/

struct Fragment {
  vec3 albedo;
  vec3 normal;

  float emission;
};

struct LightMap {
  float blockLight;
  float skyLight;

};

Fragment getFragment(in vec2 coord) {
  Fragment frag;

  frag.albedo = getAlbedo(coord);
  frag.normal = getNormal(coord);
  frag.emission = getEmission(coord);

  return frag;
}

LightMap getLightMapSample(in vec2 coord) {
  LightMap lightMap;

  lightMap.blockLight = getBlockLight(coord);
  lightMap.skyLight = getSkyLight(coord);

  return lightMap;
}

/*void calculateLitSurface(inout vec3 color) {
  vec3 sunlight = vec3(1.0, 0.9, 0.6) * getShadowColor(texcoord.st);
  vec3 ambientLighting = vec3(0.3, 0.3, 0.7);

  LightMap lightMap = getLightMapSample(texcoord.st);

  vec3 torchColor = vec3(1.0, 0.9, 0.7) * 0.1;
  vec3 blockLight = torchColor * lightMap.blockLight;

  color *= (sunlight + ambientLighting + blockLight);
}*/

vec3 calculateLighting(in Fragment frag, in LightMap lightMap) {
  float directLightStrength = dot(frag.normal, lightVector);
  directLightStrength = max(0.0, directLightStrength);
  vec3 directLight = directLightStrength * lightColor * 1.5;

  vec3 torchColor = vec3(1.0, 0.9, 0.7) * 0.1;
  vec3 blockLight = torchColor * lightMap.blockLight;

  vec3 skyLight = skyColor * lightMap.skyLight;

  vec3 litColor = frag.albedo * (directLight + skyLight + blockLight);
  return mix(litColor, frag.albedo, frag.emission);
}

void main() {
  vec3 finalComposite = getAlbedo(texcoord.st);
  vec3 finalCompositeNormal = texture2D(gnormal, texcoord.st).rgb;
  vec3 finalCompositeDepth = texture2D(gdepth, texcoord.st).rgb;

  Fragment frag = getFragment(texcoord.st);
  LightMap lightMap = getLightMapSample(texcoord.st);

  finalComposite = calculateLighting(frag, lightMap);

  GCOLOR_OUT = vec4(finalComposite, 1.0f);
  GNORMAL_OUT = vec4(finalCompositeNormal, 1.0f);
  GDEPTH_OUT = vec4(finalCompositeDepth, 1.0f);
}
