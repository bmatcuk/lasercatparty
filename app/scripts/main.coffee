"use strict"

music = require 'scripts/music'

module.exports =
  unleashTheUnicorns: ->
    music.load().then -> do music.play

