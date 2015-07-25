"use strict"

class BackgroundCat
  constructor: (@texture) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [width, height] = if aspect > 1.0 then [2.0, 2.0 / aspect] else [2.0 * aspect, 2.0]

    @geometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material

  setScene: (scene) ->
    scene.add @plane

  addLeftPaw: (paw) ->
    @leftPaw = paw

  addRightPaw: (paw) ->
    @rightPaw = paw

  resize: (left, top) ->
    width = @geometry.parameters.width / 2.0
    height = @geometry.parameters.height / 2.0
    scale = 0.5 * Math.min left / width, top / height
    @plane.position.y = 0.1 * @geometry.parameters.height * scale
    @plane.scale.x = @plane.scale.y = scale

    cat =
      position: @plane.position
      geometry:
        width: width
        height: height
      image:
        width: @texture.image.width
        height: @texture.image.height
    @leftPaw?.catResize cat, scale
    @rightPaw?.catResize cat, scale

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/backgroundcat.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter

        cat = new BackgroundCat texture
        resolve cat

