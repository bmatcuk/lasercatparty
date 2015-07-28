"use strict"

class MuffinCat
  constructor: (@texture, x, z) ->
    @material = new THREE.SpriteMaterial map: @texture
    @sprite = new THREE.Sprite @material
    @sprite.position.x = x
    @sprite.position.z = z
    #@sprite.position.y = 10
    @sprite.scale.x = @sprite.scale.y = @sprite.scale.z = 200

  setScene: (scene) ->
    scene.add @sprite

  update: (timestamp) ->
    if @nextUpdate?
      if @nextUpdate < timestamp
        @sprite.scale.x = 0 - @sprite.scale.x
        @nextUpdate = timestamp + Math.random() * 1000
    else
      @nextUpdate = timestamp + Math.random() * 1000

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/muffincat.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve (x, y) ->
          new MuffinCat texture, x, y

