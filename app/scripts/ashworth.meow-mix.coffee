"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Ashworth'
  title: 'Meow Mix'
  image: '/images/ashworth.meow-mix.jpg'
  url: 'https://soundcloud.com/meowmixofficial/a_meow_mix_by_ashworth'

  run: (objs) ->
    super objs

    @registrar.onceAt 1.875, ->
      do objs.pizzacat.show
      objs.pizzacat.set -1.1, -0.1
      objs.pizzacat.moveTo(0, -0.1, window.performance.now(), 5625, 'easeout').then ->
        objs.pizzacat.hover(0.01, window.performance.now(), 27656, 59).then ->
          objs.pizzacat.moveTo(1.1, -0.1, window.performance.now(), 5000, 'easein').then ->
            do objs.pizzacat.hide

    @registrar.onceAt 22.5, -> objs.background.show window.performance.now(), 7500

    @registrar.onceAt 29.85, ->
      objs.countdown.start 12, window.performance.now(), 937.5

    @scheduleLasers 41.1, 140.6, 128

    @registrar.onceAt 41.1, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.danceFloor.startAnimation now, 128
      objs.spectrum.show now
      objs.spectrum.startAnimation now, 128
      objs.backgroundcat.show now
      objs.backgroundcat.startAnimation now, 128
      for obj in objs.scene.frontPerspectiveObjs
        obj.show now
        obj.startAnimation now, 128

    @registrar.onceAt 140.6, ->
      do objs.spectrum.stopAnimation
      do objs.spectrum.hide

      now = window.performance.now()
      objs.danceFloor.hide now, 1875
      objs.backgroundcat.hide now, 1875
      do objs.backgroundcat.stopAnimation
      obj.hide now, 1875 for obj in objs.scene.frontPerspectiveObjs

    @registrar.onceAt 142.475, ->
      do objs.danceFloor.stopAnimation
      do obj.stopAnimation for obj in objs.scene.frontPerspectiveObjs
      objs.background.hide window.performance.now(), 7500

module.exports = Script

