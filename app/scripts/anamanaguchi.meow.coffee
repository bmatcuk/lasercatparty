"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Anamanaguchi'
  title: 'Meow'
  image: '/images/anamanaguchi.meow.jpg'
  url: 'https://soundcloud.com/anamanaguchi/meow-1'

  run: (objs) ->
    super objs

    @registrar.onceAt 0, ->
      do objs.pizzacat.show
      objs.pizzacat.set -1.1, -0.1
      objs.pizzacat.moveTo(0, -0.1, window.performance.now(), 2400, 'easeout').then ->
        objs.pizzacat.hover(0.01, window.performance.now(), 5400, 4).then ->
          objs.pizzacat.moveTo(1.1, -0.1, window.performance.now(), 2400, 'easein').then ->
            do objs.pizzacat.hide

    @scheduleLasers 3.14, 212, 100

    @registrar.onceAt 3.14, -> objs.background.show window.performance.now(), 7000

    @registrar.onceAt 5.9, ->
      objs.countdown.start 4, window.performance.now(), 1200

    @registrar.onceAt 10.7, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.danceFloor.startAnimation now, 100
      objs.spectrum.show now
      objs.spectrum.startAnimation now, 100
      objs.backgroundcat.show now
      objs.backgroundcat.startAnimation now, 100
      for obj in objs.scene.frontPerspectiveObjs
        obj.show now
        obj.startAnimation now, 100

    @registrar.onceAt 212, ->
      do objs.spectrum.stopAnimation
      do objs.spectrum.hide

      now = window.performance.now()
      objs.danceFloor.hide now, 2400
      objs.backgroundcat.hide now, 2400
      do objs.backgroundcat.stopAnimation
      obj.hide now, 2400 for obj in objs.scene.frontPerspectiveObjs

    @registrar.onceAt 214.4, ->
      do objs.danceFloor.stopAnimation
      do obj.stopAnimation for obj in objs.scene.frontPerspectiveObjs
      objs.background.hide window.performance.now(), 7000

module.exports = Script

