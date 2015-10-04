"use strict"

FlyingCat = require 'scripts/flyingcat'

class NyanCat extends FlyingCat
  # we call the nyan texture @texture because the code in FlyingCat assumes that
  constructor: (@texture, @trailTexture, z, scale) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [width, height] = if aspect > 1.0 then [1.0, 1.0 / aspect] else [1.0 * aspect, 1.0]

    # we call the nyan material @material because the code in FlyingCat assumes that
    @nyanGeometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true, side: THREE.DoubleSide
    @nyan = new THREE.Mesh @nyanGeometry, @material

    # dimensions of the rainbow trail
    trailWidth = width / @texture.image.width * @trailTexture.image.width
    trailHeight = height
    trailLength = Math.random() * 5.0 + 1.0
    trailRight = width / -2.0
    trailLeft = trailRight - trailWidth * trailLength
    trailTop = trailHeight / 2.0
    trailBottom = 0 - trailTop

    # geometry
    trailVertices = new Float32Array [
      trailLeft, trailTop, 0.0
      trailRight, trailTop, 0.0
      trailLeft, trailBottom, 0.0
      trailRight, trailBottom, 0.0
    ]
    trailIndexes = new Uint16Array [0, 2, 1, 2, 3, 1]
    trailUvs = new Float32Array [
      1.0 - trailLength, 1
      1.0, 1
      1.0 - trailLength, 0
      1.0, 0
    ]

    @trailGeometry = new THREE.BufferGeometry
    @trailGeometry.addAttribute 'position', new THREE.BufferAttribute trailVertices, 3
    @trailGeometry.addAttribute 'index', new THREE.BufferAttribute trailIndexes, 1
    @trailGeometry.addAttribute 'uv', new THREE.BufferAttribute trailUvs, 2
    @trailGeometry.parameters =
      width: trailWidth
      height: trailHeight

    @trailMaterial = new THREE.MeshBasicMaterial map: @trailTexture, transparent: true, side: THREE.DoubleSide
    @trail = new THREE.Mesh @trailGeometry, @trailMaterial

    # we name our object @sprite because the code in FlyingCat assumes that
    @sprite = new THREE.Object3D
    @sprite.scale.x = @sprite.scale.y = @sprite.scale.z = scale
    @sprite.position.z = z
    @sprite.add @nyan
    @sprite.add @trail
    @sprite.visible = false
    @paused = false
    window.test = @

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      textures = [
        new Promise (resolveTexture, reject) ->
          texture = THREE.ImageUtils.loadTexture "/images/nyan.png", THREE.UVMapping, ->
            texture.minFilter = THREE.NearestFilter
            resolveTexture texture
        new Promise (resolveTexture, reject) ->
          texture = THREE.ImageUtils.loadTexture "/images/progress.png", THREE.UVMapping, ->
            texture.wrapS = THREE.RepeatWrapping
            resolveTexture texture
      ]
      Promise.all(textures).then (textures) ->
        [nyanTexture, trailTexture] = textures
        resolve (z, scale) ->
          new NyanCat nyanTexture, trailTexture, z, scale

