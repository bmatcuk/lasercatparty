"use strict"

class Scene
  constructor: (parent) ->
    @paused = true
    @bpm = 140

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

    # ortho camera
    if aspect <= 1.0
      @orthoCamera = new THREE.OrthographicCamera 0 - aspect, aspect, 1.0, -1.0, -1.0, 1.0
    else
      @orthoCamera = new THREE.OrthographicCamera -1.0, 1.0, 1.0 / aspect, -1.0 / aspect, -1.0, 1.0

    # perspective camera
    @perspectiveCamera = new THREE.PerspectiveCamera 75, aspect, 0.1, 2000
    @perspectiveCamera.position.y = 250
    @perspectiveCamera.position.z = 1000

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

      # perspective camera
      @perspectiveCamera.aspect = aspect
      do @perspectiveCamera.updateProjectionMatrix

      # renderer
      @renderer.setSize width, height

  addBackgroundObj: (obj) ->
    @backgroundObjs.push obj
    obj.setScene @background

  addBackPerspectiveObj: (obj) ->
    @backPerspectiveObjs.push obj
    obj.setScene @backPerspective

  addMidStationaryObj: (obj) ->
    @midStationaryObjs.push obj
    obj.setScene @midStationary

  addFrontPerspectiveObj: (obj) ->
    @frontPerspectiveObjs.push obj
    obj.setScene @frontPerspective

  start: ->
    render = (timestamp) =>
      return if @paused
      requestAnimationFrame render

      # rotate the camera
      t = timestamp * 0.000005
      @perspectiveCamera.position.x = Math.sin(t) * 1000
      @perspectiveCamera.position.z = Math.cos(t) * 1000
      @perspectiveCamera.lookAt @backPerspective.position

      # update
      obj.update(timestamp) for obj in @backgroundObjs
      obj.update(timestamp) for obj in @backPerspectiveObjs
      obj.update(timestamp) for obj in @midStationaryObjs
      obj.update(timestamp) for obj in @frontPerspectiveObjs

      # render
      do @renderer.clear
      @renderer.render @background, @orthoCamera
      do @renderer.clearDepth
      @renderer.render @backPerspective, @perspectiveCamera
      do @renderer.clearDepth
      @renderer.render @midStationary, @orthoCamera
      do @renderer.clearDepth
      @renderer.render @frontPerspective, @perspectiveCamera

    # start the rendering loop
    @paused = false
    render window.performance.now()

  pause: -> @paused = true

module.exports =
  init: (parent) ->
    Promise.resolve new Scene parent

