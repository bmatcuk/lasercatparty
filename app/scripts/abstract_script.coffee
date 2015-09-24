"use strict"

class AbstractScript
  constructor: (@dancer) ->

  run: (objs) ->
    kick = @dancer.createKick
      onKick: ->
        # TODO

      offKick: ->
        # TODO

    @dancer.onceAt 0, -> do kick.on

    @dancer.after 0, ->
      objs.waveform.updateWaveform(@getWaveform())
      objs.spectrum.updateSpectrum(@getSpectrum())

module.exports = AbstractScript

