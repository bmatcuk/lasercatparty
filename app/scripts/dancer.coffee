"use strict"

class Dancer
  constructor: (@texture, x, z) ->
    @material = new THREE.SpriteMaterial map: @texture
    @sprite = new THREE.Sprite @material
    @sprite.position.x = x
    @sprite.position.z = z
    #@sprite.position.y = 10
    @sprite.scale.x = @sprite.scale.y = @sprite.scale.z = 200
    @sprite.visible = false
    @sprite.scale.x = 0 - @sprite.scale.x if Math.random() > 0.5
    @paused = false

  setScene: (scene) ->
    scene.add @sprite

  show: ->
    @sprite.visible = true

  startAnimation: (timestamp, bpm) ->
    @beatLength = 60000 / bpm
    @nextUpdate = timestamp + @beatLength

  stopAnimation: ->
    @nextUpdate = null

  play: (timestamp) ->
    @nextUpdate += timestamp - @paused if @nextUpdate?
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @nextUpdate? and !@paused
      if @nextUpdate <= timestamp
        @sprite.scale.x = 0 - @sprite.scale.x
        @nextUpdate += @beatLength while @nextUpdate <= timestamp

module.exports = Dancer

