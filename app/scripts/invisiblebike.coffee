"use strict"

Dancer = require 'scripts/dancer'

class InvisibleBike extends Dancer

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/invisiblebike.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve (x, y) ->
          new InvisibleBike texture, x, y

