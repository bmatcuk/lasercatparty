"use strict"

scene = require 'scripts/scene'
background = require 'scripts/background'
nyancat = require 'scripts/nyancat'

begin = ->
  loaders = [
    scene.init(document.getElementById('container'))
    do background.loadRandom
    do nyancat.init
  ]

  Promise.all(loaders).then (things) ->
    [scene, background, nyancat] = things

    do background.show
    scene.addBackgroundObj background

    cat = nyancat 0, 0.1
    do cat.show
    scene.addFrontStationaryObj cat

    do scene.start

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

