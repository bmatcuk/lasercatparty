uniform sampler2D background;
uniform float backgroundOffset;
uniform vec3 shading;
attribute vec3 uvs;
varying vec3 vUv;

void main() {
  vUv = uvs;
  vUv.t += backgroundOffset;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

