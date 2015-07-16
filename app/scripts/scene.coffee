"use strict"

DanceFloor = require 'scripts/dance_floor'

class Scene
  constructor: (parent) ->
    @paused = true
    @bpm = 140

    # initialize three.js
    width = parent.clientWidth
    height = parent.clientHeight
    @scene = new THREE.Scene
    @camera = new THREE.PerspectiveCamera 75, width / height, 0.1, 2000
    @camera.position.y = 250
    @camera.position.z = 1000
    @renderer = new THREE.WebGLRenderer antialias: true
    @renderer.setSize width, height
    parent.appendChild @renderer.domElement
    window.addEventListener 'resize', =>
      width = parent.clientWidth
      height = parent.clientHeight
      @camera.aspect = width / height
      do @camera.updateProjectionMatrix
      @renderer.setSize width, height

    # create objects
    @floor = new DanceFloor @scene

  start: ->
    render = (timestamp) =>
      requestAnimationFrame render unless @paused

      # rotate the camera
      t = timestamp * 0.000005
      @camera.position.x = Math.sin(t) * 1000
      @camera.position.z = Math.cos(t) * 1000
      @camera.lookAt @scene.position

      # render
      @floor.update timestamp
      @renderer.render @scene, @camera

    # start the rendering loop
    @paused = false
    render window.performance.now()

  pause: -> @paused = true

module.exports =
  init: (parent) ->
    Promise.resolve new Scene parent

