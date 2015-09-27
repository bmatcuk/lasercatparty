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
      do objs.danceFloor.stopAnimation
      do objs.spectrum.stopAnimation
      do obj.stopAnimation for obj in objs.scene.frontPerspectiveObjs

module.exports = Script

