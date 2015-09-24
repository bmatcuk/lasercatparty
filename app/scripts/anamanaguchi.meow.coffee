"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Anamanaguchi'
  title: 'Meow'
  image: '/images/anamanaguchi.meow.jpg'
  url: 'https://soundcloud.com/anamanaguchi/meow-1'

  run: (objs) ->
    super objs

    @dancer.onceAt 3.14, -> objs.background.show window.performance.now(), 7000

    @dancer.onceAt 10.7, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.spectrum.show now
      objs.backgroundcat.show now
      obj.show now for obj in objs.scene.frontPerspectiveObjs

module.exports = Script

