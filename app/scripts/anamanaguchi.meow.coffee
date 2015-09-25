"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Anamanaguchi'
  title: 'Meow'
  image: '/images/anamanaguchi.meow.jpg'
  url: 'https://soundcloud.com/anamanaguchi/meow-1'

  run: (objs) ->
    super objs

    #kick = @dancer.createKick
    #  onKick: ->

    #  offKick: ->

    @dancer.onceAt 3.14, -> objs.background.show window.performance.now(), 7000

    @dancer.onceAt 10.7, ->
      now = window.performance.now()
      objs.danceFloor.show now
      objs.danceFloor.startAnimation now, 100
      objs.spectrum.show now
      objs.spectrum.startAnimation now, 100
      objs.backgroundcat.show now
      obj.show now for obj in objs.scene.frontPerspectiveObjs

    @dancer.onceAt 212, ->
      do objs.danceFloor.stopAnimation
      do objs.spectrum.stopAnimation

module.exports = Script

