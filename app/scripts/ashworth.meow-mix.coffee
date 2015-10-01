"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Ashworth'
  title: 'Meow Mix'
  image: '/images/ashworth.meow-mix.jpg'
  url: 'https://soundcloud.com/meowmixofficial/a_meow_mix_by_ashworth'

  run: (objs) ->
    super objs

    kickCount = 0
    kick = @dancer.createKick
      onKick: ->
        do objs.backgroundcat.lasersOn if kickCount is 0
        kickCount = (kickCount + 1) & 0x03

      offKick: ->
        do objs.backgroundcat.lasersOff if kickCount is 3

    @onceAtRandomOnBeat 0, 12, 128, =>
      now = window.performance.now()
      curve = new Bezier -1.5,-0.3, 0,0, 1.5,-0.3
      @randomFlyingCat().startAnimation now, curve, 128 * 36

    @onceAtRandomOnBeat 12, 24, 128, =>
      now = window.performance.now()
      curve = new Bezier 1.5,-0.4, 0,0.1, -1.5,-0.4
      @randomFlyingCat().startAnimation now, curve, 128 * 36

    @onceAtRandomOnBeat 24, 38, 128, =>
      now = window.performance.now()
      curve = new Bezier -1.5,0, 0,0.3, 1.5,0
      @randomFlyingCat().startAnimation now, curve, 128 * 36

    @dancer.onceAt 22.5, -> objs.background.show window.performance.now(), 7500

    @dancer.onceAt 41.1, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.danceFloor.startAnimation now, 128
      objs.spectrum.show now
      objs.spectrum.startAnimation now, 128
      objs.backgroundcat.show now
      objs.backgroundcat.startAnimation now, 128
      do kick.on
      for obj in objs.scene.frontPerspectiveObjs
        obj.show now
        obj.startAnimation now, 128

    @dancer.onceAt 140.6, ->
      do objs.spectrum.stopAnimation
      do objs.spectrum.hide

      now = window.performance.now()
      objs.danceFloor.hide now, 1875
      objs.backgroundcat.hide now, 1875
      do objs.backgroundcat.stopAnimation
      do kick.off
      obj.hide now, 1875 for obj in objs.scene.frontPerspectiveObjs

    @dancer.onceAt 142.475, ->
      do objs.danceFloor.stopAnimation
      do obj.stopAnimation for obj in objs.scene.frontPerspectiveObjs
      objs.background.hide window.performance.now(), 7500

module.exports = Script

