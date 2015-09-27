"use strict"

class DanceFloor
  constructor: (@colorScale) ->
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
    @paused = false

  setScene: (scene) ->
    scene.add @plane

  show: ->
    @plane.visible = true

  startAnimation: (timestamp, bpm) ->
    @animationStart = timestamp
    @beatLength = 60000 / bpm

  stopAnimation: ->
    @animationStart = null

  play: (timestamp) ->
    @animationStart += timestamp - @paused if @animationStart?
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @animationStart? and !@paused
      progress = (timestamp - @animationStart) / @beatLength
      @uniforms.progress.value = progress - Math.floor progress

      colorProgress = (timestamp - @animationStart) / (@beatLength * 12)
      colorProgress -= Math.floor colorProgress
      @uniforms.color.value.set.apply @uniforms.color.value, @colorScale(colorProgress).gl()

module.exports = DanceFloor

