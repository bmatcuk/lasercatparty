"use strict"

class InvisibleBike
  constructor: (@texture, x, z) ->
    @material = new THREE.SpriteMaterial map: @texture
    @sprite = new THREE.Sprite @material
    @sprite.position.x = x
    @sprite.position.z = z
    #@sprite.position.y = 10
    @sprite.scale.x = @sprite.scale.y = @sprite.scale.z = 200

  setScene: (scene) ->
    scene.add @sprite

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/invisiblebike.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve (x, y) ->
          new InvisibleBike texture, x, y

