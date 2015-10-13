"use strict"

class AbstractScript
  constructor: (@registrar) ->

  run: (@objs) ->
    @registrar.after 0, ->
      objs.waveform.updateWaveform(@getWaveform()) if objs.waveform
      objs.spectrum.updateSpectrum(@getSpectrum())

    do (registrar = @registrar) ->
      registrar.onceAt 0, ->
        queueNyan = (nyan) =>
          do nyan.hide
          t = @getCurrentTime() + Math.random() * 5.0
          if t + 2 < @getDuration()
            registrar.onceAt t, ->
              y = Math.random() * 0.8 - 0.4
              do nyan.show
              nyan.set 1.1, y
              nyan.moveTo(-1.5, y, window.performance.now(), 1500).then queueNyan

        for nyan in objs.nyans
          queueNyan nyan

  nearestBeat: (t, bpm) -> Math.round(t * bpm / 60.0) * 60.0 / bpm

  onceAtRandomOnBeat: (min, max, bpm, handler) ->
    beatLength = 60000 / bpm
    min = Math.floor(min * 1000 / beatLength)
    max = Math.ceil(max * 1000 / beatLength)
    beat = Math.round(Math.random() * (max - min) + min)
    @registrar.onceAt beat * beatLength / 1000.0, handler

  scheduleLasers: (t, stop, bpm) ->
    beatLength = 60 / bpm
    turnOff = 0
    while t < stop
      turnOff = t + (0.1 + Math.random() * 0.4) * beatLength
      if turnOff < stop
        @registrar.onceAt t, => do @objs.backgroundcat.lasersOn
        @registrar.onceAt turnOff, => do @objs.backgroundcat.lasersOff
      t = turnOff + (0.1 + Math.random() * 0.4) * beatLength

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

