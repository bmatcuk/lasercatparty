"use strict"

Dancer = require 'scripts/dancer'

class Pita extends Dancer

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/pita.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve (x, y) ->
          new Pita texture, x, y

