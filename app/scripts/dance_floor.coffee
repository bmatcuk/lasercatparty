"use strict"

class DanceFloor
  constructor: ->
    @uniforms =
      progress:
        type: 'f'
        value: 0.0
      color:
        type: 'v3'
        value: new THREE.Vector3 1.0, 0.0, 0.0
      type:
        type: 'i'
        value: 0

    @geometry = new THREE.PlaneBufferGeometry 1200, 1200, 1, 1
    @material = new THREE.ShaderMaterial
      uniforms: @uniforms
      vertexShader: require 'shaders/dance_floor_vert'
      fragmentShader: require 'shaders/dance_floor_frag'
    @material.shading = THREE.FlatShading
    @plane = new THREE.Mesh @geometry, @material
    @plane.rotateOnAxis(new THREE.Vector3(1, 0, 0), Math.PI / -2.0)
    @plane.visible = false

  setScene: (scene) ->
    scene.add @plane

  show: (timestamp) ->
    @plane.visible = true

  update: (timestamp) ->
    progress = timestamp / 5000
    @uniforms.progress.value = progress - Math.floor progress

module.exports = DanceFloor

