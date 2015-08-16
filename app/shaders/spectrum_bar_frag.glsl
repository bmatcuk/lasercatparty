uniform float power;
uniform vec3 color;
uniform float progress;
varying vec2 vUv;

void main() {
  if (vUv.t > power) {
    discard;
  } else if (fract(vUv.t * 10.0) + 0.1 <= 0.2) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
  } else {
    float factor = max(0.0, sin((progress - vUv.t) * 6.283185307));
    gl_FragColor = mix(vec4(color, 1.0), vec4(1.0, 1.0, 1.0, 1.0), factor);
  }
}

