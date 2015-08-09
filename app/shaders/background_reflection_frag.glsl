uniform sampler2D background;
uniform float backgroundOffset;
uniform vec3 shading;
varying vec3 vUv;

void main() {
  if (vUv.s > 1.0 || vUv.s < 0.0)
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
  else
    gl_FragColor = vec4(shading, 1.0) * texture2DProj(background, vUv);
}

