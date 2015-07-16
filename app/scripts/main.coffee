"use strict"

jukebox = require 'scripts/jukebox'
scene = require 'scripts/scene'
background = require 'scripts/background'
DanceFloor = require 'scripts/dance_floor'

begin = ->
  # do background.loadRandom
  init = Promise.all [
    do jukebox.init
    scene.init document.getElementById 'container'
    do background.loadRandom
  ]
  init.then (things) ->
    [jukebox, scene, background] = things

    # add objs to scene
    scene.addBackgroundObj background

    danceFloor = new DanceFloor
    danceFloor.show window.performance.now() #TODO: remove
    scene.addBackPerspectiveObj danceFloor

    # start rendering
    do scene.start

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

