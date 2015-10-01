"use strict"

class AbstractScript
  constructor: (@dancer) ->

  run: (@objs) ->
    @dancer.after 0, ->
      objs.waveform.updateWaveform(@getWaveform())
      objs.spectrum.updateSpectrum(@getSpectrum())

  onceAtRandomOnBeat: (min, max, bpm, handler) ->
    beatLength = 60000 / bpm
    min = Math.floor(min * 1000 / beatLength)
    max = Math.ceil(max * 1000 / beatLength)
    beat = Math.random() * (max - min) + min
    @dancer.onceAt beat * beatLength / 1000.0, handler

  randomFlyingCat: ->
    @objs.scene.frontStationaryObjs[Math.floor(Math.random() * @objs.scene.frontStationaryObjs.length)]

  play: (timestamp) ->
    @objs.background.play timestamp
    @objs.danceFloor.play timestamp
    @objs.spectrum.play timestamp
    @objs.backgroundcat.play timestamp
    obj.play timestamp for obj in @objs.scene.frontPerspectiveObjs
    obj.play timestamp for obj in @objs.scene.frontStationaryObjs

  pause: (timestamp) ->
    @objs.background.pause timestamp
    @objs.danceFloor.pause timestamp
    @objs.spectrum.pause timestamp
    @objs.backgroundcat.pause timestamp
    obj.pause timestamp for obj in @objs.scene.frontPerspectiveObjs
    obj.pause timestamp for obj in @objs.scene.frontStationaryObjs

module.exports = AbstractScript

