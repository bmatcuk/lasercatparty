"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Ashworth'
  title: 'Meow Mix'
  image: '/images/ashworth.meow-mix.jpg'
  url: 'https://soundcloud.com/meowmixofficial/a_meow_mix_by_ashworth'

  run: (objs) ->
    super objs

    @dancer.onceAt 22.5, -> objs.background.show window.performance.now(), 7500

    @dancer.onceAt 41.1, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.danceFloor.startAnimation now, 128
      objs.spectrum.show now
      objs.spectrum.startAnimation now, 128
      objs.backgroundcat.show now
      for obj in objs.scene.frontPerspectiveObjs
        obj.show now
        obj.startAnimation now, 128

    @dancer.onceAt 140.6, ->
      do objs.spectrum.stopAnimation
      do objs.spectrum.hide

      now = window.performance.now()
      objs.danceFloor.hide now, 1875
      objs.backgroundcat.hide now, 1875
      obj.hide now, 1875 for obj in objs.scene.frontPerspectiveObjs

    @dancer.onceAt 142.475, ->
      do objs.danceFloor.stopAnimation
      do obj.stopAnimation for obj in objs.scene.frontPerspectiveObjs
      objs.background.hide window.performance.now(), 7500

module.exports = Script

