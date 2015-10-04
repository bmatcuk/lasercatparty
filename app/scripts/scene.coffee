"use strict"

CAMERA_Y = 250
LOOKAT = new THREE.Vector3 0, CAMERA_Y, 0
AUTOROTATE_FACTOR = 0.00005

class Scene
  constructor: (parent) ->
    @paused = true

    # get dimensions
    width = parent.clientWidth
    height = parent.clientHeight
    aspect = width / height

    # scenes
    @background = new THREE.Scene
    @backgroundObjs = []
    @backPerspective = new THREE.Scene
    @backPerspectiveObjs = []
    @midStationary = new THREE.Scene
    @midStationaryObjs = []
    @frontPerspective = new THREE.Scene
    @frontPerspectiveObjs = []
    @frontStationary = new THREE.Scene
    @frontStationaryObjs = []

    # ortho camera
    if aspect <= 1.0
      @orthoCamera = new THREE.OrthographicCamera 0 - aspect, aspect, 1.0, -1.0, -1.0, 1.0
    else
      @orthoCamera = new THREE.OrthographicCamera -1.0, 1.0, 1.0 / aspect, -1.0 / aspect, -1.0, 1.0

    # perspective camera
    @perspectiveCamera = new THREE.PerspectiveCamera 75, aspect, 0.1, 2000
    @perspectiveCamera.position.y = CAMERA_Y
    @perspectiveCamera.position.z = 1000
    @autoRotate = false
    @manualRotate = 0

    # renderer
    @renderer = new THREE.WebGLRenderer antialias: true
    @renderer.autoClear = false
    @renderer.setSize width, height
    parent.appendChild @renderer.domElement

    # handle resize
    window.addEventListener 'resize', =>
      width = parent.clientWidth
      height = parent.clientHeight
      aspect = width / height

      # ortho camera
      if aspect <= 1.0
        @orthoCamera.left = 0 - aspect
        @orthoCamera.right = aspect
        @orthoCamera.top = 1.0
        @orthoCamera.bottom = -1.0
      else
        @orthoCamera.left = -1.0
        @orthoCamera.right = 1.0
        @orthoCamera.top = 1.0 / aspect
        @orthoCamera.bottom = -1.0 / aspect
      do @orthoCamera.updateProjectionMatrix
      obj.resize?(@orthoCamera.right, @orthoCamera.top) for obj in @backgroundObjs
      obj.resize?(@orthoCamera.right, @orthoCamera.top) for obj in @midStationaryObjs

      # perspective camera
      @perspectiveCamera.aspect = aspect
      do @perspectiveCamera.updateProjectionMatrix

      # renderer
      @renderer.setSize width, height

  addBackgroundObj: (obj) ->
    @backgroundObjs.push obj
    obj.resize? @orthoCamera.right, @orthoCamera.top
    obj.setScene @background

  addBackPerspectiveObj: (obj) ->
    @backPerspectiveObjs.push obj
    obj.setScene @backPerspective

  addMidStationaryObj: (obj) ->
    @midStationaryObjs.push obj
    obj.resize? @orthoCamera.right, @orthoCamera.top
    obj.setScene @midStationary

  addFrontPerspectiveObj: (obj) ->
    @frontPerspectiveObjs.push obj
    obj.setScene @frontPerspective

  addFrontStationaryObj: (obj) ->
    @frontStationaryObjs.push obj
    obj.setScene @frontStationary

  start: ->
    render = (timestamp) =>
      return if @paused
      requestAnimationFrame render

      # rotate the camera
      @manualRotate = (timestamp - @autoRotate) * AUTOROTATE_FACTOR if @autoRotate
      @perspectiveCamera.position.x = Math.sin(@manualRotate) * 1000
      @perspectiveCamera.position.z = Math.cos(@manualRotate) * 1000
      @perspectiveCamera.lookAt LOOKAT

      # update
      obj.update?(timestamp) for obj in @backgroundObjs
      obj.update?(timestamp) for obj in @backPerspectiveObjs
      obj.update?(timestamp) for obj in @midStationaryObjs
      obj.update?(timestamp) for obj in @frontPerspectiveObjs
      obj.update?(timestamp) for obj in @frontStationaryObjs

      # render
      do @renderer.clear
      @renderer.render @background, @orthoCamera
      do @renderer.clearDepth
      @renderer.render @backPerspective, @perspectiveCamera
      do @renderer.clearDepth
      @renderer.render @midStationary, @orthoCamera
      do @renderer.clearDepth
      @renderer.render @frontPerspective, @perspectiveCamera
      do @renderer.clearDepth
      @renderer.render @frontStationary, @orthoCamera

    # start the rendering loop
    @paused = false
    @autoRotate = window.performance.now()
    render @autoRotate

  pause: -> @paused = true

  startAutoRotate: (timestamp) ->
    @autoRotate = timestamp - @manualRotate / AUTOROTATE_FACTOR

  stopAutoRotate: ->
    @autoRotate = false

module.exports =
  init: (parent) ->
    scene = new Scene parent

    autoRotateTimeout = null
    mousedown = (e) ->
      if autoRotateTimeout?
        clearTimeout autoRotateTimeout
        autoRotateTimeout = null
      do scene.stopAutoRotate

      x = e.clientX
      mousemove = (e) ->
        scene.manualRotate -= (e.clientX - x) * 0.01
        x = e.clientX
      mouseup = (e) ->
        autoRotateTimeout = setTimeout((-> scene.startAutoRotate window.performance.now()), 1000)
        parent.removeEventListener 'mousemove', mousemove
        parent.removeEventListener 'mouseup', mouseup
      parent.addEventListener 'mousemove', mousemove
      parent.addEventListener 'mouseup', mouseup
    parent.addEventListener 'mousedown', mousedown

    Promise.resolve scene

