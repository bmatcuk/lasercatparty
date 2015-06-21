"use strict"

class Script
  constructor: (@dancer) ->

  run: (scene) ->
    kick = @dancer.createKick
      onKick: ->
        # TODO

      offKick: ->
        # TODO

    @dancer.onceAt 0, -> do kick.on

module.exports = Script

