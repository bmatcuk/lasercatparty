"use strict"

jukebox = require 'scripts/jukebox'
scene = require 'scripts/scene'
background = require 'scripts/background'
DanceFloor = require 'scripts/dance_floor'
backgroundcat = require 'scripts/backgroundcat'
leftpaw = require 'scripts/leftpaw'
rightpaw = require 'scripts/rightpaw'

begin = ->
  # do background.loadRandom
  init = Promise.all [
    do jukebox.init
    scene.init document.getElementById 'container'
    do background.loadRandom
    do backgroundcat.init
    do leftpaw.init
    do rightpaw.init
  ]
  init.then (things) ->
    [jukebox, scene, background, backgroundcat, leftpaw, rightpaw] = things

    # add paws to background cat
    backgroundcat.addLeftPaw leftpaw
    backgroundcat.addRightPaw rightpaw

    # add objs to scene
    scene.addBackgroundObj background
    scene.addBackgroundObj backgroundcat
    scene.addMidStationaryObj leftpaw
    scene.addMidStationaryObj rightpaw

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

