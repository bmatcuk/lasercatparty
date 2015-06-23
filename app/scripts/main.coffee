"use strict"

jukebox = require 'scripts/jukebox'
scene = require 'scripts/scene'
background = require 'scripts/background'

begin = ->
  # do background.loadRandom
  init = Promise.all [
    do jukebox.init
    scene.init document.getElementById 'container'
  ]
  init.then (things) ->
    [jukebox, scene] = things
    scene.floor.show window.performance.now()
    do scene.start

module.exports = ->
  if document.readyState is 'complete'
    do begin
  else
    window.addEventListener 'load', begin

