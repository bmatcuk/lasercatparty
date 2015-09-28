"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Anamanaguchi'
  title: 'Meow'
  image: '/images/anamanaguchi.meow.jpg'
  url: 'https://soundcloud.com/anamanaguchi/meow-1'

  run: (objs) ->
    super objs

    kickCount = 0
    kick = @dancer.createKick
      onKick: ->
        do objs.backgroundcat.lasersOn if kickCount is 0
        kickCount = (kickCount + 1) & 0x03

      offKick: ->
        do objs.backgroundcat.lasersOff if kickCount is 3

    @dancer.onceAt 3.14, -> objs.background.show window.performance.now(), 7000

    @dancer.onceAt 10.7, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.danceFloor.startAnimation now, 100
      objs.spectrum.show now
      objs.spectrum.startAnimation now, 100
      objs.backgroundcat.show now
      objs.backgroundcat.startAnimation now, 100
      do kick.on
      for obj in objs.scene.frontPerspectiveObjs
        obj.show now
        obj.startAnimation now, 100

    @dancer.onceAt 212, ->
      do objs.spectrum.stopAnimation
      do objs.spectrum.hide

      now = window.performance.now()
      objs.danceFloor.hide now, 2400
      objs.backgroundcat.hide now, 2400
      do objs.backgroundcat.stopAnimation
      do kick.off
      obj.hide now, 2400 for obj in objs.scene.frontPerspectiveObjs

    @dancer.onceAt 214.4, ->
      do objs.danceFloor.stopAnimation
      do obj.stopAnimation for obj in objs.scene.frontPerspectiveObjs
      objs.background.hide window.performance.now(), 7000

module.exports = Script

