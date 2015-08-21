"use strict"

class Waveform
  constructor: ->
    @canvas = document.createElement 'canvas'
    @canvas.width = 1024
    @canvas.height = 64

    @context = @canvas.getContext '2d'
    @context.fillStyle = '#ff0000'
    @context.fillRect 0, 0, 1024, 64
    @context.globalCompositeOperation = 'copy'

    @geometry = new THREE.PlaneBufferGeometry 2.0, 1.2
    @texture = new THREE.Texture @canvas
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material
    @plane.position.y = 0.5
    @plane.position.z = -0.25

  setScene: (scene) ->
    scene.add @plane

  resize: (left, top) ->
    @plane.position.y = top / 2.0 - 0.05
    @plane.scale.x = left
    @plane.scale.y = top

  update: (timestamp) ->
    if @lastUpdate? and @context.globalAlpha > 0.0
      if @lastUpdate < timestamp - 500
        @context.globalAlpha = @context.globalAlpha - 0.1
        @context.drawImage @canvas, 0, 0, 1024, 64, 0, 0, 1024, 64
        @lastUpdate = timestamp
      @texture.needsUpdate = true
    else
      @lastUpdate = timestamp

module.exports = Waveform

