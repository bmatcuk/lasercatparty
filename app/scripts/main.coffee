"use strict"

jukebox = require 'scripts/jukebox'
background = require 'scripts/background'

module.exports = ->
  init = Promise.all [
    do jukebox.init
  ]
  do background.loadRandom

