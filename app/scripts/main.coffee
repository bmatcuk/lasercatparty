"use strict"

Jukebox = require 'scripts/jukebox'
scene = require 'scripts/scene'
background = require 'scripts/background'
Waveform = require 'scripts/waveform'
DanceFloor = require 'scripts/dance_floor'
SpectrumAnalyzer = require 'scripts/spectrum'
backgroundcat = require 'scripts/backgroundcat'
invisiblebike = require 'scripts/invisiblebike'
muffincat = require 'scripts/muffincat'
jazzcat = require 'scripts/jazz'
pitacat = require 'scripts/pita'
pizzacat = require 'scripts/pizzacat'
nyancat = require 'scripts/nyancat'

rnd = (min, max) ->
  Math.random() * (max - min) + min
rndi = (min, max) ->
  Math.floor rnd min, max

begin = ->
  # iOS has a few issues, so we need to detect that
  iOS = /iPad|iPhone|iPod/.test navigator.platform

  # color scale
  colorScale = chroma.scale(['hsl(0,90%,50%)', 'hsl(180,90%,50%)', 'hsl(350,90%,50%)']).mode('hsl')

  progress = document.getElementById 'loading-progress'
  markProgress = (obj) ->
    progress.setAttribute 'value', +progress.getAttribute('value') + 1
    obj

  loaders = [
    scene.init(document.getElementById 'container').then markProgress
    background.loadRandom().then markProgress
    backgroundcat.init(colorScale).then markProgress
    invisiblebike.init().then markProgress
    muffincat.init().then markProgress
    jazzcat.init().then markProgress
    pitacat.init().then markProgress
    pizzacat.init().then markProgress
    nyancat.init().then markProgress
  ]

  # +1 to max for song loading down below
  progress.setAttribute 'max', loaders.length + 1
  Promise.all(loaders).then (things) ->
    try
      [scene, background, backgroundcat, invisiblebike, muffincat, jazzcat, pitacat, pizzacat, nyancat] = things

      # try to hide the navigation bar on iOS
      if iOS or true
        document.body.style.paddingTop = '1px'
        window.scrollTo 0, 1

      # add background and background cat to scene
      spectrum = new SpectrumAnalyzer colorScale
      scene.addBackgroundObj background
      scene.addBackgroundObj spectrum
      scene.addBackgroundObj backgroundcat
      scene.addMidStationaryObj backgroundcat.paws
      unless iOS
        waveform = new Waveform
        scene.addBackgroundObj waveform

      # dance floor
      danceFloor = new DanceFloor colorScale
      scene.addBackPerspectiveObj danceFloor

      # dancers
      dancePositions = []
      for i in [0...4]
        for j in [0...4]
          dancePositions.push [-400 + 200 * i + rnd(20, 180), -400 + 200 * j + rnd(20, 180)]
      for i in [0..2]
        pos = dancePositions.splice(rndi(0, dancePositions.length), 1)[0]
        bike = invisiblebike.apply null, pos
        scene.addFrontPerspectiveObj bike
      for i in [0..2]
        pos = dancePositions.splice(rndi(0, dancePositions.length), 1)[0]
        muffin = muffincat.apply null, pos
        scene.addFrontPerspectiveObj muffin
      for i in [0..2]
        pos = dancePositions.splice(rndi(0, dancePositions.length), 1)[0]
        jazz = jazzcat.apply null, pos
        scene.addFrontPerspectiveObj jazz
      for i in [0..2]
        pos = dancePositions.splice(rndi(0, dancePositions.length), 1)[0]
        pita = pitacat.apply null, pos
        scene.addFrontPerspectiveObj pita

      # flying cats
      nyans = []
      for i in [0...5]
        nyan = nyancat -0.75, 0.04 + 0.02 * Math.random()
        scene.addBackgroundObj nyan
        nyans.push nyan
      for i in [0...5]
        nyan = nyancat -0.75, 0.06 + 0.02 * Math.random()
        scene.addFrontStationaryObj nyan
        nyans.push nyan
      scene.addFrontStationaryObj pizzacat

      # start rendering
      do scene.start

      # ui elements
      loading = document.getElementById 'loading'
      controls = document.getElementById 'controls'
      playButton = document.getElementById 'button'
      albumart = document.getElementById 'albumart'
      link = document.getElementById 'link'
      artist = document.getElementById 'artist'
      title = document.getElementById 'title'
      songProgress = document.getElementById 'song-progress'
      volume = document.getElementById 'volume'
      fullScreen = document.getElementById 'full-screen'
      rightControls = document.getElementById 'right-controls'

      # handle full screen
      if document.fullscreenEnabled or document.mozFullScreenEnabled or document.webkitFullscreenEnabled
        fullScreen.addEventListener 'click', (e) ->
          do e.preventDefault
          if fullScreen.classList.contains 'fa-expand'
            elem = document.documentElement
            (elem.requestFullscreen or elem.mozRequestFullScreen or elem.webkitRequestFullscreen).apply elem
          else
            (document.exitFullscreen or document.mozCancelFullScreen or document.webkitExitFullscreen).apply document
        fullscreenToggled = ->
          fullScreen.classList.toggle 'fa-compress'
          fullScreen.classList.toggle 'fa-expand'
        if typeof document.onfullscreenchange isnt 'undefined'
          document.addEventListener 'fullscreenchange', fullscreenToggled
        else if typeof document.onmozfullscreenchange isnt 'undefined'
          document.addEventListener 'mozfullscreenchange', fullscreenToggled
        else if typeof document.onwebkitfullscreenchange isnt 'undefined'
          document.addEventListener 'webkitfullscreenchange', fullscreenToggled
      else
        fullScreen.style.display = 'none'
        fullScreen = null

      # size of the songProgress bar
      resizeSongProgress = ->
        if controls.style.display is 'block'
          width = controls.offsetWidth - (link.offsetLeft + link.offsetWidth) - rightControls.offsetWidth - 40
          songProgress.style.width = "#{width}px"
      window.addEventListener 'resize', resizeSongProgress

      # startup the jukebox - iOS has some issues, so we need to detect that
      jukebox = new Jukebox iOS, songProgress, volume
      scene.registerForUpdates jukebox
      runner = (script) ->
        # update the ui
        do markProgress
        albumart.setAttribute 'src', script.image
        link.setAttribute 'href', script.url
        artist.textContent = script.artist
        title.textContent = script.title
        controls.style.display = 'block'
        loading.style.display = 'none'
        do resizeSongProgress

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
          nyans: nyans
          pizzacat: pizzacat
        jukebox.play().then ->
          # set progress back one because we need to load a new song
          progress.setAttribute 'value', +progress.getAttribute('value') - 1
          controls.style.display = 'none'
          loading.style.display = ''
          playButton.removeEventListener 'click', toggle
          jukebox.loadNext().then runner

      if iOS
        jukebox.loadNext().then (script) ->
          startButton = document.getElementById 'start'
          startButton.style.display = 'block'
          startButton.addEventListener 'click', (e) ->
            do e.preventDefault
            startButton.style.display = 'none'
            runner script
      else
        jukebox.loadNext().then runner

    catch e
      console.log e.stack

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

