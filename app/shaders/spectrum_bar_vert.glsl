uniform float power;
attribute vec3 uvs;
varying vec2 vUv;

void main() {
  vUv = uvs.st / uvs.p;
  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}

