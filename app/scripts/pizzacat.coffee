"use strict"

FlyingCat = require 'scripts/flyingcat'

class PizzaCat extends FlyingCat
  constructor: (texture, path) ->
    super texture, path
    @sprite.scale.x = @sprite.scale.y = @sprite.scale.z = 0.3

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/pizzacat.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve new PizzaCat texture

