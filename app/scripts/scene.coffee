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

    # objects interested in updates
    @notifyUpdate = []

    # objects interested in click events
    @clickHandlers = []

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
    @notifyUpdate.push obj if obj.update?
    @clickHandlers.push obj if obj.handleClick?
    obj.resize? @orthoCamera.right, @orthoCamera.top
    obj.setScene @background

  removeBackgroundObj: (obj) ->
    idx = @backgroundObjs.indexOf obj
    @backgroundObjs.splice idx, 1 if idx >= 0
    if obj.update?
      idx = @notifyUpdate.indexOf obj
      @notifyUpdate.splice idx, 1 if idx >= 0
    if obj.handleClick?
      idx = @clickHandlers.indexOf obj
      @clickHandlers.splice idx, 1 if idx >= 0
    obj.removeScene @background

  addBackPerspectiveObj: (obj) ->
    @backPerspectiveObjs.push obj
    @notifyUpdate.push obj if obj.update?
    @clickHandlers.push obj if obj.handleClick?
    obj.setScene @backPerspective

  addMidStationaryObj: (obj) ->
    @midStationaryObjs.push obj
    @notifyUpdate.push obj if obj.update?
    @clickHandlers.push obj if obj.handleClick?
    obj.resize? @orthoCamera.right, @orthoCamera.top
    obj.setScene @midStationary

  addFrontPerspectiveObj: (obj) ->
    @frontPerspectiveObjs.push obj
    @notifyUpdate.push obj if obj.update?
    @clickHandlers.push obj if obj.handleClick?
    obj.setScene @frontPerspective

  addFrontStationaryObj: (obj) ->
    @frontStationaryObjs.push obj
    @notifyUpdate.push obj if obj.update?
    @clickHandlers.push obj if obj.handleClick?
    obj.setScene @frontStationary

  registerForUpdates: (obj) ->
    @notifyUpdate.push obj
    @clickHandlers.push obj if obj.handleClick?

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
      obj.update(timestamp) for obj in @notifyUpdate

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

  handleClick: ->
    timestamp = window.performance.now()
    obj.handleClick(timestamp) for obj in @clickHandlers

module.exports =
  init: (parent) ->
    scene = new Scene parent

    autoRotateTimeout = null
    detachMouseEvents = null
    mousedown = (e) ->
      manualRotate = false
      startX = x = e.clientX
      mousemove = (e) ->
        if !manualRotate and Math.abs(e.clientX - startX) > 5
          if autoRotateTimeout?
            clearTimeout autoRotateTimeout
            autoRotateTimeout = null
          do scene.stopAutoRotate
          manualRotate = true
        if manualRotate
          scene.manualRotate -= (e.clientX - x) * 0.01
          x = e.clientX
      mouseup = (e) ->
        if manualRotate
          autoRotateTimeout = setTimeout((-> scene.startAutoRotate window.performance.now()), 1000)
        else
          do scene.handleClick
        do detachMouseEvents
      detachMouseEvents = ->
        parent.removeEventListener 'mousemove', mousemove
        parent.removeEventListener 'mouseup', mouseup
        detachMouseEvents = null
      parent.addEventListener 'mousemove', mousemove
      parent.addEventListener 'mouseup', mouseup
    parent.addEventListener 'mousedown', mousedown

    touchstart = (e) ->
      return unless e.touches.length is 1
      manualRotate = false
      startX = x = e.touches[0].pageX
      touchmove = (e) ->
        return unless e.touches.length is 1
        if !manualRotate and Math.abs(e.touches[0].pageX - startX) > 5
          if autoRotateTimeout?
            clearTimeout autoRotateTimeout
            autoRotateTimeout = null
          do scene.stopAutoRotate
          manualRotate = true
        if manualRotate
          scene.manualRotate -= (e.touches[0].pageX - x) * 0.01
          x = e.touches[0].pageX
      touchend = (e) ->
        if manualRotate
          autoRotateTimeout = setTimeout((-> scene.startAutoRotate window.performance.now()), 1000)
        else
          do scene.handleClick
        do detachTouchEvents
      detachTouchEvents = ->
        parent.removeEventListener 'touchmove', touchmove
        parent.removeEventListener 'touchend', touchend
        detachTouchEvents = null
      parent.addEventListener 'touchmove', touchmove
      parent.addEventListener 'touchend', touchend
      do detachMouseEvents if detachMouseEvents?
    parent.addEventListener 'touchstart', touchstart

    Promise.resolve scene

