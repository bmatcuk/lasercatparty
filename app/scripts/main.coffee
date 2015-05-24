"use strict"

music = require 'scripts/music'
background = require 'scripts/background'

module.exports =
  unleashTheUnicorns: ->
    music.loadRandom()
    do background.loadRandom

