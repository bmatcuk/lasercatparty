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

  hide: (timestamp, fadeout) ->
    if fadeout?
      @material.transparent = true
      @material.opacity = 1
      @fadeout =
        start: timestamp
        length: fadeout
    else
      @plane.visible = false

  startAnimation: (timestamp, bpm) ->
    @animationStart = timestamp
    @beatLength = 60000 / bpm

  stopAnimation: ->
    @animationStart = null

  play: (timestamp) ->
    @animationStart += timestamp - @paused if @animationStart?
    @fadeout.start += timestamp - @paused if @fadeout?
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    unless @paused
      if @animationStart?
        progress = (timestamp - @animationStart) / @beatLength
        @uniforms.progress.value = progress - Math.floor progress

        colorProgress = (timestamp - @animationStart) / (@beatLength * 12)
        colorProgress -= Math.floor colorProgress
        @uniforms.color.value.set.apply @uniforms.color.value, @colorScale(colorProgress).gl()
      if @fadeout?
        if timestamp >= @fadeout.start + @fadeout.length
          @plane.visible = false
          @material.transparent = false
          @material.opacity = 1
          @fadeout = null
        else
          @material.opacity = (@fadeout.length - timestamp + @fadeout.start) / @fadeout.length

module.exports = DanceFloor

