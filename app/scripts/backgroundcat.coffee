"use strict"

class Paw
  # posX and posY are the distance, in pixels, from the middle of backgroundcat
  # to the upper left corner of the paw. Negative values indicate the upper
  # left corner is to the left (x) or above (y) the center of backgroundcat.
  #
  # jointX and jointY are the distance, in pixels, from the top left of the paw
  # to the point of articulation. These values will always be positive unless
  # the point of articulation falls up and/or left of the actual paw itself.
  constructor: (@texture, container, posX, posY, jointX, jointY, widthFactor, heightFactor) ->
    width = @texture.image.width * widthFactor
    height = @texture.image.height * heightFactor
    @geometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material
    @plane.position.x = width / 2.0 - jointX * widthFactor
    @plane.position.y = height / -2.0 + jointY * heightFactor

    @joint = new THREE.Object3D
    @joint.add @plane
    @joint.position.x = (jointX + posX) * widthFactor
    @joint.position.y = (posY + jointY) * heightFactor * -1.0
    container.add @joint

    @joint.visible = false
    @paused = false

  show: ->
    @joint.visible = true

  hide: (timestamp, fadeout) ->
    if fadeout?
      @material.opacity = 1
      @fadeout =
        start: timestamp
        length: fadeout
    else
      @joint.visible = false

  play: (timestamp) ->
    @fadeout.start += timestamp - @paused if @fadeout?
    @paused = false

  pause: (timestamp) ->
    @paused = timestamp

  update: (timestamp) ->
    if @fadeout? and !@paused
      if timestamp >= @fadeout.start + @fadeout.length
        @joint.visible = false
        @material.opacity = 1
        @fadeout = null
      else
        @material.opacity = (@fadeout.length - timestamp + @fadeout.start) / @fadeout.length

class LeftPaw extends Paw
  constructor: (texture, container, widthFactor, heightFactor) ->
    super texture, container, -221.0, 33.0, 110.0, 18.0, widthFactor, heightFactor

class RightPaw extends Paw
  constructor: (texture, container, widthFactor, heightFactor) ->
    super texture, container, 111.0, 33.0, 14.0, 14.0, widthFactor, heightFactor

class Paws
  constructor: (leftPawTexture, rightPawTexture, widthFactor, heightFactor) ->
    @container = new THREE.Object3D
    @leftPaw = new LeftPaw leftPawTexture, @container, widthFactor, heightFactor
    @rightPaw = new RightPaw rightPawTexture, @container, widthFactor, heightFactor

  setScene: (scene) ->
    scene.add @container

  show: ->
    do @leftPaw.show
    do @rightPaw.show

  hide: (timestamp, fadeout) ->
    @leftPaw.hide timestamp, fadeout
    @rightPaw.hide timestamp, fadeout

  resizeFromCat: (y, scale) ->
    @container.position.y = y
    @container.scale.x = @container.scale.y = scale

  play: (timestamp) ->
    @leftPaw.play timestamp
    @rightPaw.play timestamp

  pause: (timestamp) ->
    @leftPaw.pause timestamp
    @rightPaw.pause timestamp

  update: (timestamp) ->
    @leftPaw.update timestamp
    @rightPaw.update timestamp

class BackgroundCat
  constructor: (@texture, leftPawTexture, rightPawTexture, @colorScale) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [width, height] = if aspect > 1.0 then [2.0, 2.0 / aspect] else [2.0 * aspect, 2.0]

    @geometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material
    @plane.visible = false

    laserRadius = 6 * width / @texture.image.width
    @laserGeometry = new THREE.CylinderGeometry laserRadius, laserRadius, 2
    @laserMaterial = new THREE.MeshBasicMaterial color: new THREE.Color @colorScale(0).num(), transparent: true
    @laserMaterial.opacity = 0.5
    @lasers = new THREE.Object3D
    @lasers.visible = false

    laserRotation = 14.0 / 180.0 * Math.PI
    laserXOffset = 0.0 - Math.sin laserRotation
    laserYOffset = 1.0 - Math.cos laserRotation
    leftLaser = new THREE.Mesh @laserGeometry, @laserMaterial
    leftLaser.position.x = width * 100.0 / @texture.image.width - width / 2.0 + laserXOffset
    leftLaser.position.y = height / 2.0 - height * 20.0 / @texture.image.height + 1.0 - laserYOffset
    leftLaser.rotateOnAxis new THREE.Vector3(0.0, 0.0, 1,0), laserRotation
    @lasers.add leftLaser

    rightLaser = new THREE.Mesh @laserGeometry, @laserMaterial
    rightLaser.position.x = width * 144.0 / @texture.image.width - width / 2.0 + laserXOffset
    rightLaser.position.y = height / 2.0 - height * 10.0 / @texture.image.height + 1.0 - laserYOffset
    rightLaser.rotateOnAxis new THREE.Vector3(0.0, 0.0, 1,0), laserRotation
    @lasers.add rightLaser

    @paws = new Paws leftPawTexture, rightPawTexture, width / @texture.image.width, height / @texture.image.height

    @paused = false

  setScene: (scene) ->
    scene.add @plane
    scene.add @lasers

  show: ->
    @plane.visible = true
    do @paws.show

  hide: (timestamp, fadeout) ->
    @paws.hide timestamp, fadeout
    do @lasersOff
    if fadeout?
      @material.opacity = 1
      @fadeout =
        start: timestamp
        length: fadeout
    else
      @plane.visible = false

  lasersOn: ->
    @lasers.visible = true if @plane.visible and !@fadeout?

  lasersOff: ->
    @lasers.visible = false

  startAnimation: (timestamp, bpm) ->
    @animationStart = timestamp
    @beatLength = 60000 / bpm

  stopAnimation: ->
    @animationStart = null

  resize: (left, top) ->
    width = @geometry.parameters.width / 2.0
    height = @geometry.parameters.height / 2.0
    scale = 0.5 * Math.min left / width, top / height
    @plane.position.y = 0.1 * @geometry.parameters.height * scale
    @plane.scale.x = @plane.scale.y = scale

    @lasers.position.y = @plane.position.y
    @lasers.scale.x = @lasers.scale.y = scale

    @paws.resizeFromCat @plane.position.y, scale

  play: (timestamp) ->
    @paws.play timestamp
    @animationStart += timestamp - @paused if @animationStart?
    @fadeout.start += timestamp - @paused if @fadeout?
    @paused = false

  pause: (timestamp) ->
    @paws.pause timestamp
    @paused = timestamp

  update: (timestamp) ->
    unless @paused
      if @animationStart?
        progress = (timestamp - @animationStart) / (@beatLength * 12)
        progress -= Math.floor progress
        @laserMaterial.color.setRGB.apply @laserMaterial.color, @colorScale(progress).gl()
      if @fadeout?
        if timestamp >= @fadeout.start + @fadeout.length
          @plane.visible = false
          @material.opacity = 1
          @fadeout = null
        else
          @material.opacity = (@fadeout.length - timestamp + @fadeout.start) / @fadeout.length

module.exports =
  init: (colorScale) ->
    new Promise (resolve, reject) ->
      textures = [
        new Promise (resolveTexture, rejectTexture) ->
          texture = THREE.ImageUtils.loadTexture "/images/backgroundcat.png", THREE.UVMapping, ->
            texture.minFilter = THREE.NearestFilter
            resolveTexture texture
        new Promise (resolveTexture, rejectTexture) ->
          texture = THREE.ImageUtils.loadTexture "/images/leftpaw.png", THREE.UVMapping, ->
            texture.minFilter = THREE.NearestFilter
            resolveTexture texture
        new Promise (resolveTexture, rejectTexture) ->
          texture = THREE.ImageUtils.loadTexture "/images/rightpaw.png", THREE.UVMapping, ->
            texture.minFilter = THREE.NearestFilter
            resolveTexture texture
      ]
      Promise.all(textures).then (textures) ->
        [catTexture, leftPawTexture, rightPawTexture] = textures
        resolve new BackgroundCat catTexture, leftPawTexture, rightPawTexture, colorScale

