"use strict"

TOTAL_BAR_ANGLE = 180.0 / 7.0 * Math.PI / 180.0
BAR_ANGLE = TOTAL_BAR_ANGLE / 2.0
LENGTH_START = 0.2
LENGTH_END = 0.8

class SpectrumBar
  constructor: (@geometry, angle) ->
    @uniforms =
      power:
        type: 'f'
        value: 0.5

    @material = new THREE.ShaderMaterial
      uniforms: @uniforms
      attributes:
        uvs:
          type: 'v3'
      vertexShader: require 'shaders/spectrum_bar_vert'
      fragmentShader: require 'shaders/spectrum_bar_frag'

    @plane = new THREE.Mesh @geometry, @material
    @plane.rotateOnAxis(new THREE.Vector3(0, 0, 1), angle)
    @plane.position.z = -0.5

  setScene: (scene) ->
    scene.add @plane

class SpectrumAnalyzer
  constructor: ->
    # calculate vertices for a bar
    tan = Math.tan(BAR_ANGLE / 2.0)
    halfTopWidth = LENGTH_END * tan
    halfBottomWidth = LENGTH_START * tan
    narrowFactor = halfBottomWidth / halfTopWidth

    vertices = new Float32Array [
      -halfTopWidth, LENGTH_END, 0.0
      halfTopWidth, LENGTH_END, 0.0
      -halfBottomWidth, LENGTH_START, 0.0
      halfBottomWidth, LENGTH_START, 0.0
    ]
    indexes = new Uint16Array [0, 2, 1, 2, 3, 1]
    uvs = new Float32Array [
      0, 1, 1
      1, 1, 1
      0, 0, narrowFactor
      narrowFactor, 0, narrowFactor
    ]

    @geometry = new THREE.BufferGeometry
    @geometry.addAttribute 'position', new THREE.BufferAttribute vertices, 3
    @geometry.addAttribute 'index', new THREE.BufferAttribute indexes, 1
    @geometry.addAttribute 'uvs', new THREE.BufferAttribute uvs, 3

    angle = Math.PI / 2.0
    @bars = for i in [0...8]
      new SpectrumBar @geometry, angle - i * TOTAL_BAR_ANGLE

  setScene: (scene) ->
    bar.setScene(scene) for bar in @bars

module.exports = SpectrumAnalyzer

