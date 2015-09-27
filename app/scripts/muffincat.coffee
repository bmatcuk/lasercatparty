"use strict"

Dancer = require 'scripts/dancer'

class MuffinCat extends Dancer

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/muffincat.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve (x, y) ->
          new MuffinCat texture, x, y

