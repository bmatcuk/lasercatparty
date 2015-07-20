"use strict"

class BackgroundCat
  constructor: (@texture) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [width, height] = if aspect > 1.0 then [1.0, 1.0 / aspect] else [1.0 * aspect, 1.0]

    @geometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material

  setScene: (scene) ->
    scene.add @plane

  resize: (left, top) ->
    width = @geometry.parameters.width / 2.0
    height = @geometry.parameters.height / 2.0
    scale = Math.min left / width, top / height
    @plane.scale.x = @plane.scale.y = scale

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/backgroundcat.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter

        cat = new BackgroundCat texture
        resolve cat

