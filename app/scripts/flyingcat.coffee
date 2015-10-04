"use strict"

class FlyingCat
  constructor: (@texture) ->
    @material = new THREE.SpriteMaterial map: @texture
    @sprite = new THREE.Sprite @material
    @sprite.visible = false
    @paused = false

  setScene: (scene) ->
    scene.add @sprite

  show: ->
    @sprite.visible = true

  hide: ->
    @sprite.visible = false

  set: (x, y) ->
    @sprite.position.x = x
    @sprite.position.y = y

  moveTo: (x, y, timestamp, length, ease) ->
    new Promise (resolve, reject) =>
      if x < @sprite.position.x
        @sprite.scale.x = 0 - @sprite.scale.x unless @sprite.scale.x < 0
      else if @sprite.scale.x < 0
        @sprite.scale.x = 0 - @sprite.scale.x

      @animation =
        timestamp: timestamp
        length: length
        from:
          x: @sprite.position.x
          y: @sprite.position.y
        to:
          x: x
          y: y
        ease: ease
        resolve: resolve

  hover: (dy, timestamp, length, cycles) ->
    new Promise (resolve, reject) =>
      @animation =
        timestamp: timestamp
        length: length
        from:
          x: @sprite.position.x
          y: @sprite.position.y
        to:
          x: @sprite.position.x
          y: @sprite.position.y + dy
        ease: 'hover'
        cycles: cycles
        resolve: resolve

  stopAnimation: ->
    @animation = null

  play: (timestamp) ->
    @animation.timestamp += timestamp - @paused if @animation
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @animation and !@paused
      if timestamp > @animation.timestamp + @animation.length
        resolve = @animation.resolve
        @sprite.position.x = @animation.to.x
        @sprite.position.y = @animation.to.y
        do @stopAnimation
        resolve @
      else
        progress = (timestamp - @animation.timestamp) / @animation.length
        if @animation.ease?
          switch @animation.ease
            when 'ease'
              progress = (Math.cos(progress * Math.PI) - 1.0) / -2.0
            when 'easein'
              progress = 1.0 - Math.cos(progress * Math.PI / 2.0)
            when 'easeout'
              progress = Math.sin(progress * Math.PI / 2.0)
            when 'hover'
              progress = Math.sin(progress * 2.0 * Math.PI * @animation.cycles)

        @sprite.position.x = (@animation.to.x - @animation.from.x) * progress + @animation.from.x
        @sprite.position.y = (@animation.to.y - @animation.from.y) * progress + @animation.from.y

module.exports = FlyingCat

