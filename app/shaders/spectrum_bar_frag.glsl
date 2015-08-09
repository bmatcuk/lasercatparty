uniform float power;
varying vec2 vUv;

void main() {
  if (vUv.t > power)
    discard;
  else
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}

