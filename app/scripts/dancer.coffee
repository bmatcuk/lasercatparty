"use strict"

class Dancer
  constructor: (@texture, x, z) ->
    @material = new THREE.SpriteMaterial map: @texture
    @sprite = new THREE.Sprite @material
    @sprite.position.x = x
    @sprite.position.z = z
    #@sprite.position.y = 10
    @sprite.scale.x = @sprite.scale.y = @sprite.scale.z = 200
    @sprite.scale.x *= @texture.image.width / @texture.image.height
    @sprite.visible = false
    @sprite.scale.x = 0 - @sprite.scale.x if Math.random() > 0.5
    @paused = false

  setScene: (scene) ->
    scene.add @sprite

  show: ->
    @sprite.visible = true

  hide: (timestamp, fadeout) ->
    if fadeout?
      @material.transparent = true
      @material.opacity = 1
      @fadeout =
        start: timestamp
        length: fadeout
    else
      @sprite.visible = false

  startAnimation: (timestamp, bpm) ->
    @beatLength = 60000 / bpm
    @nextUpdate = timestamp + @beatLength

  stopAnimation: ->
    @nextUpdate = null

  play: (timestamp) ->
    @nextUpdate += timestamp - @paused if @nextUpdate?
    @fadeout.start += timestamp - @paused if @fadeout?
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  handleClick: (timestamp) ->
    # delay the jump by a beatLength for the cat smash
    return if !@beatLength? or @jump?
    height = Math.random() * 1.5 + 0.5
    @jump =
      timestamp: timestamp + @beatLength
      length: @beatLength * height
      startY: @sprite.position.y
      deltaY: height * 50.0

  update: (timestamp) ->
    unless @paused
      if @jump?
        if timestamp >= @jump.timestamp + @jump.length
          @sprite.position.y = @jump.startY
          @jump = null
        else if timestamp >= @jump.timestamp
          progress = (timestamp - @jump.timestamp) / @jump.length
          progress = Math.sin(progress * Math.PI)
          @sprite.position.y = @jump.deltaY * progress + @jump.startY
      else if @nextUpdate?
        if @nextUpdate <= timestamp
          @sprite.scale.x = 0 - @sprite.scale.x
          @nextUpdate += @beatLength while @nextUpdate <= timestamp
      if @fadeout?
        if timestamp >= @fadeout.start + @fadeout.length
          @sprite.visible = false
          @material.transparent = false
          @material.opacity = 1
          @fadeout = null
        else
          @material.opacity = (@fadeout.length - timestamp + @fadeout.start) / @fadeout.length

module.exports = Dancer

