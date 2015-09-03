"use strict"

class AbstractScript
  constructor: (@dancer) ->
    window.dancer = @dancer #TODO: remove

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

    @dancer.onceAt 5, -> objs.background.show window.performance.now(), 2000

module.exports = AbstractScript

