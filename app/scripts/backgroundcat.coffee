"use strict"

class BackgroundCat
  constructor: (@texture, @colorScale) ->
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

    @paused = false

  setScene: (scene) ->
    scene.add @plane
    scene.add @lasers

  show: ->
    @plane.visible = true
    do @leftPaw.show
    do @rightPaw.show

  hide: (timestamp, fadeout) ->
    @leftPaw.hide timestamp, fadeout
    @rightPaw.hide timestamp, fadeout
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

    @lasers.position.y = @plane.position.y
    @lasers.scale.x = @lasers.scale.y = scale

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

  play: (timestamp) ->
    @leftPaw.play timestamp
    @rightPaw.play timestamp
    @animationStart += timestamp - @paused if @animationStart?
    @fadeout.start += timestamp - @paused if @fadeout?
    @paused = false

  pause: (timestamp) ->
    @leftPaw.pause timestamp
    @rightPaw.pause timestamp
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
      texture = THREE.ImageUtils.loadTexture "/images/backgroundcat.png", THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter
        resolve new BackgroundCat texture, colorScale

