"use strict"

class AbstractScript
  constructor: (@dancer) ->

  run: (@objs) ->
    @dancer.after 0, ->
      objs.waveform.updateWaveform(@getWaveform())
      objs.spectrum.updateSpectrum(@getSpectrum())

    @dancer.onceAt 0, =>
      queueNyan = (nyan) =>
        do nyan.hide
        t = @dancer.audio.currentTime + Math.random() * 5.0
        if t + 2 < @dancer.audio.duration
          @dancer.onceAt t, ->
            y = Math.random() * 0.8 - 0.4
            do nyan.show
            nyan.set 1.1, y
            nyan.moveTo(-1.5, y, window.performance.now(), 1500).then queueNyan

      for nyan in @objs.nyans
        queueNyan nyan

  onceAtRandomOnBeat: (min, max, bpm, handler) ->
    beatLength = 60000 / bpm
    min = Math.floor(min * 1000 / beatLength)
    max = Math.ceil(max * 1000 / beatLength)
    beat = Math.random() * (max - min) + min
    @dancer.onceAt beat * beatLength / 1000.0, handler

  play: (timestamp) ->
    @objs.background.play timestamp
    @objs.danceFloor.play timestamp
    @objs.spectrum.play timestamp
    @objs.backgroundcat.play timestamp
    obj.play timestamp for obj in @objs.scene.frontPerspectiveObjs
    obj.play timestamp for obj in @objs.nyans
    @objs.pizzacat.play timestamp

  pause: (timestamp) ->
    @objs.background.pause timestamp
    @objs.danceFloor.pause timestamp
    @objs.spectrum.pause timestamp
    @objs.backgroundcat.pause timestamp
    obj.pause timestamp for obj in @objs.scene.frontPerspectiveObjs
    obj.pause timestamp for obj in @objs.nyans
    @objs.pizzacat.pause timestamp

module.exports = AbstractScript

