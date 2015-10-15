"use strict"

scene = require 'scripts/scene'
background = require 'scripts/background'

begin = ->
  # color scale
  colorScale = chroma.scale(['hsl(0,90%,50%)', 'hsl(180,90%,50%)', 'hsl(350,90%,50%)']).mode('hsl')

  loaders = [
    scene.init(document.getElementById('container'))
    do background.loadRandom
  ]

  Promise.all(loaders).then (things) ->
    [scene, background] = things

    do background.show
    background.handleClick = (timestamp) ->
      scene.removeBackgroundObj background
      background.loadNext().then ->
        do background.show
        scene.addBackgroundObj background
    scene.addBackgroundObj background

    do scene.start

    backgroundcat.startAnimation window.performance.now(), 100

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

