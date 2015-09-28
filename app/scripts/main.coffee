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
rndi = (min, max) ->
  Math.floor rnd min, max

begin = ->
  # color scale
  colorScale = chroma.scale(['hsl(0,90%,50%)', 'hsl(180,90%,50%)', 'hsl(350,90%,50%)']).mode('hsl')

  # do background.loadRandom
  init = Promise.all [
    scene.init document.getElementById 'container'
    do background.loadRandom
    backgroundcat.init colorScale
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
    spectrum = new SpectrumAnalyzer colorScale
    waveform = new Waveform
    scene.addBackgroundObj background
    scene.addBackgroundObj spectrum
    scene.addBackgroundObj waveform
    scene.addBackgroundObj backgroundcat
    scene.addMidStationaryObj leftpaw
    scene.addMidStationaryObj rightpaw

    # dance floor
    danceFloor = new DanceFloor colorScale
    scene.addBackPerspectiveObj danceFloor

    # dancers
    dancePositions = []
    for i in [0...4]
      for j in [0...4]
        dancePositions.push [-400 + 200 * i + rnd(0, 200), -400 + 200 * j + rnd(0, 200)]
    for i in [0..5]
      pos = dancePositions.splice(rndi(0, dancePositions.length), 1)[0]
      bike = invisiblebike.apply null, pos
      scene.addFrontPerspectiveObj bike
    for i in [0..5]
      pos = dancePositions.splice(rndi(0, dancePositions.length), 1)[0]
      muffin = muffincat.apply null, pos
      scene.addFrontPerspectiveObj muffin

    # start rendering
    do scene.start

    # startup the jukebox
    jukebox = new Jukebox
    runner = (script) ->
      document.getElementById('albumart').setAttribute 'src', script.image
      document.getElementById('link').setAttribute 'href', script.url
      document.getElementById('artist').textContent = script.artist
      document.getElementById('title').textContent = script.title
      document.getElementById('controls').style.display = 'block'

      playButton = document.getElementById 'button'
      toggle = (e) ->
        do e.preventDefault
        if playButton.classList.toggle 'pause'
          do jukebox.play
        else
          script.pause window.performance.now()
          jukebox.pause().then -> script.play window.performance.now()
        playButton.classList.toggle 'play'
      playButton.addEventListener 'click', toggle

      script.run
        scene: scene
        background: background
        backgroundcat: backgroundcat
        danceFloor: danceFloor
        spectrum: spectrum
        waveform: waveform
      jukebox.play().then ->
        document.getElementById('controls').style.display = 'none'
        playButton.removeEventListener 'click', toggle
        # TODO: jukebox.loadNext().then runner
    jukebox.loadNext().then runner

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

