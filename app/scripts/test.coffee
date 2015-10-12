"use strict"

scene = require 'scripts/scene'
background = require 'scripts/background'
backgroundcat = require 'scripts/backgroundcat'

begin = ->
  # color scale
  colorScale = chroma.scale(['hsl(0,90%,50%)', 'hsl(180,90%,50%)', 'hsl(350,90%,50%)']).mode('hsl')

  loaders = [
    scene.init(document.getElementById('container'))
    do background.loadRandom
    backgroundcat.init colorScale
  ]

  Promise.all(loaders).then (things) ->
    [scene, background, backgroundcat] = things

    do background.show
    scene.addBackgroundObj background

    do backgroundcat.show
    scene.addBackgroundObj backgroundcat
    scene.addMidStationaryObj backgroundcat.paws

    do scene.start

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

