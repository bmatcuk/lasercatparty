"use strict"

class AbstractScript
  constructor: (@dancer) ->

  run: (@objs) ->
    @dancer.after 0, ->
      objs.waveform.updateWaveform(@getWaveform())
      objs.spectrum.updateSpectrum(@getSpectrum())

  play: (timestamp) ->
    @objs.background.play timestamp
    @objs.danceFloor.play timestamp
    @objs.spectrum.play timestamp
    obj.play timestamp for obj in @objs.scene.frontPerspectiveObjs

  pause: (timestamp) ->
    @objs.background.pause timestamp
    @objs.danceFloor.pause timestamp
    @objs.spectrum.pause timestamp
    obj.pause timestamp for obj in @objs.scene.frontPerspectiveObjs

module.exports = AbstractScript

