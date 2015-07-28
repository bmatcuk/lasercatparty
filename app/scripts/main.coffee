"use strict"

jukebox = require 'scripts/jukebox'
scene = require 'scripts/scene'
background = require 'scripts/background'
DanceFloor = require 'scripts/dance_floor'
backgroundcat = require 'scripts/backgroundcat'
leftpaw = require 'scripts/leftpaw'
rightpaw = require 'scripts/rightpaw'
invisiblebike = require 'scripts/invisiblebike'
muffincat = require 'scripts/muffincat'

rnd = (min, max) ->
  Math.random() * (max - min) + min

begin = ->
  # do background.loadRandom
  init = Promise.all [
    do jukebox.init
    scene.init document.getElementById 'container'
    do background.loadRandom
    do backgroundcat.init
    do leftpaw.init
    do rightpaw.init
    do invisiblebike.init
    do muffincat.init
  ]
  init.then (things) ->
    [jukebox, scene, backgrounds, backgroundcat, leftpaw, rightpaw, invisiblebike, muffincat] = things
    [background, backgroundReflection] = backgrounds

    # add paws to background cat
    backgroundcat.addLeftPaw leftpaw
    backgroundcat.addRightPaw rightpaw

    # add background and background cat to scene
    scene.addBackgroundObj background
    scene.addBackgroundObj backgroundReflection
    scene.addBackgroundObj backgroundcat
    scene.addMidStationaryObj leftpaw
    scene.addMidStationaryObj rightpaw

    # dance floor
    danceFloor = new DanceFloor
    danceFloor.show window.performance.now() #TODO: remove
    scene.addBackPerspectiveObj danceFloor

    # dancers
    for i in [0..5]
      bike = invisiblebike rnd(-400, 400), rnd(-400, 400)
      scene.addFrontPerspectiveObj bike
    for i in [0..5]
      muffin = muffincat rnd(-400, 400), rnd(-400, 400)
      scene.addFrontPerspectiveObj muffin

    # start rendering
    do scene.start

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

