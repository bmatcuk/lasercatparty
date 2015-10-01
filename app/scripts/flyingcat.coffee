"use strict"

class FlyingCat
  constructor: (@texture) ->
    @material = new THREE.SpriteMaterial map: @texture
    @sprite = new THREE.Sprite @material
    @sprite.visible = false
    @paused = false

  setScene: (scene) ->
    scene.add @sprite

  startAnimation: (timestamp, @curve, @animationLength) ->
    if @curve.get(0).x < @curve.get(1).x
      @sprite.scale.x = 0 - @sprite.scale.x if @sprite.scale.x < 0
    else if @sprite.scale.x > 0
      @sprite.scale.x = 0 - @sprite.scale.x

    @animationStart = timestamp
    @sprite.visible = true

  stopAnimation: ->
    @animationStart = null

  play: (timestamp) ->
    @animationStart += timestamp - @paused if @animationStart
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @animationStart and !@paused
      if timestamp > @animationStart + @animationLength
        @sprite.visible = false
        do @stopAnimation
      else
        point = @curve.get (timestamp - @animationStart) / @animationLength
        @sprite.position.x = point.x
        @sprite.position.y = point.y

module.exports = FlyingCat

