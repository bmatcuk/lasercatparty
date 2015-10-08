"use strict"

Dancer = require 'scripts/dancer'

class Jazz extends Dancer
  constructor: (texture, x, z) ->
    super texture, x, z
    @sprite.scale.x *= 1.1
    @sprite.scale.y *= 1.1
    @sprite.scale.z *= 1.1

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/jazz.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve (x, y) ->
          new Jazz texture, x, y

