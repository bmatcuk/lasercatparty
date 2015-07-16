uniform float progress;
uniform vec3 color;
uniform int type;
varying vec2 vUv;

void main() {
  vec2 center = -1.0 + 2.0 * vUv;
  vec2 uv = center * 10.0;
  if (fract(uv.x) + 0.1 <= 0.2 || fract(uv.y) + 0.1 <= 0.2) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    uv = floor(uv);
    float dist = length(uv) / 28.284271247;
    float factor = max(0.0, sin((progress - dist) * 6.283185307));
    gl_FragColor = mix(vec4(color, 1.0), vec4(1.0, 1.0, 1.0, 1.0), factor);
  }
}
