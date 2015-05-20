"use strict"

#music = require 'scripts/music'
background = require 'scripts/background'

module.exports =
  unleashTheUnicorns: ->
    #music.load().then -> do music.play
    do background.loadRandom

