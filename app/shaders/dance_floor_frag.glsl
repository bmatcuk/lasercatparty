uniform float progress;
uniform vec3 color;
uniform int type;
varying vec2 vUv;

void main() {
  vec2 center = -1.0 + 2.0 * vUv;
  vec2 uv = floor(center.xy * 20.0);
  float dist = length(uv) / 28.284271247;
  float factor = max(0.0, sin((progress - dist) * 6.283185307));
  gl_FragColor = mix(vec4(color, 1.0), vec4(1.0, 1.0, 1.0, 1.0), factor);
}
