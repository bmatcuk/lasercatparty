"use strict"

Jukebox = require 'scripts/jukebox'
background = require 'scripts/background'

module.exports =
  unleashTheUnicorns: ->
    do background.loadRandom

    jukebox = new Jukebox
    jukebox.errorDelegate = (err) -> console.log err
    jukebox.analysisDelegate = (freqData, timeData, level, beat) -> console.log level if beat
    jukeboxPromise = do jukebox.load
    jukeboxPromise.then -> do jukebox.playRandom

