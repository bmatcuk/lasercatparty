"use strict"

class AbstractScript
  constructor: (@dancer) ->

  run: (objs) ->
    @dancer.after 0, ->
      objs.waveform.updateWaveform(@getWaveform())
      objs.spectrum.updateSpectrum(@getSpectrum())

module.exports = AbstractScript

