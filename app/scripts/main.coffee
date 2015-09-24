"use strict"

Jukebox = require 'scripts/jukebox'
scene = require 'scripts/scene'
background = require 'scripts/background'
Waveform = require 'scripts/waveform'
DanceFloor = require 'scripts/dance_floor'
SpectrumAnalyzer = require 'scripts/spectrum'
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
    scene.init document.getElementById 'container'
    do background.loadRandom
    do backgroundcat.init
    do leftpaw.init
    do rightpaw.init
    do invisiblebike.init
    do muffincat.init
  ]
  init.then (things) ->
    [scene, background, backgroundcat, leftpaw, rightpaw, invisiblebike, muffincat] = things

    # add paws to background cat
    backgroundcat.addLeftPaw leftpaw
    backgroundcat.addRightPaw rightpaw

    # add background and background cat to scene
    spectrum = new SpectrumAnalyzer
    waveform = new Waveform
    scene.addBackgroundObj background
    scene.addBackgroundObj spectrum
    scene.addBackgroundObj waveform
    scene.addBackgroundObj backgroundcat
    scene.addMidStationaryObj leftpaw
    scene.addMidStationaryObj rightpaw

    # dance floor
    danceFloor = new DanceFloor
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

    # startup the jukebox
    jukebox = new Jukebox
    jukebox.loadNext().then (script) ->
      document.getElementById('albumart').setAttribute 'src', script.image
      document.getElementById('link').setAttribute 'href', script.url
      document.getElementById('artist').textContent = script.artist
      document.getElementById('title').textContent = script.title

      script.run
        scene: scene
        background: background
        danceFloor: danceFloor
        spectrum: spectrum
        waveform: waveform
      jukebox.play().then ->
        console.log 'song done'

    playButton = document.getElementById 'button'
    playButton.addEventListener 'click', (e) ->
      do e.preventDefault
      if playButton.classList.toggle 'pause'
        do jukebox.play
      else
        do jukebox.pause
      playButton.classList.toggle 'play'

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

