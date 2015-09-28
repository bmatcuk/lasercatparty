"use strict"

class LeftPaw
  constructor: (@texture) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [width, height] = if aspect > 1.0 then [2.0, 2.0 / aspect] else [2.0 * aspect, 2.0]

    @geometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material
    @plane.visible = false
    @paused = false

  setScene: (scene) ->
    scene.add @plane

  show: ->
    @plane.visible = true

  hide: (timestamp, fadeout) ->
    if fadeout?
      @material.opacity = 1
      @fadeout =
        start: timestamp
        length: fadeout
    else
      @plane.visible = false

  catResize: (cat, scale) ->
    xfactor = 2.0 * (58.0 - @texture.image.width / 2.0) / cat.image.width - 1.0
    yfactor = -2.0 * (110.0 + @texture.image.height / 2.0) / cat.image.height + 1.0
    scaleFactor = if cat.image.width > cat.image.height
      if @texture.image.width > @texture.image.height
        @texture.image.width / cat.image.width
      else
        @texture.image.height / cat.image.width
    else
      if @texture.image.width > @texture.image.height
        @texture.image.width / cat.image.height
      else
        @texture.image.height / cat.image.height
    @plane.position.x = cat.position.x + xfactor * cat.geometry.width * scale
    @plane.position.y = cat.position.y + yfactor * cat.geometry.height * scale
    @plane.scale.x = @plane.scale.y = scaleFactor * scale

  play: (timestamp) ->
    @fadeout.start += timestamp - @paused if @fadeout?
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @fadeout? and !@paused
      if timestamp >= @fadeout.start + @fadeout.length
        @plane.visible = false
        @material.opacity = 1
        @fadeout = null
      else
        @material.opacity = (@fadeout.length - timestamp + @fadeout.start) / @fadeout.length

module.exports =
  init: ->
    new Promise (resolve, reject) ->
      texture = THREE.ImageUtils.loadTexture "/images/leftpaw.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter

        paw = new LeftPaw texture
        resolve paw

