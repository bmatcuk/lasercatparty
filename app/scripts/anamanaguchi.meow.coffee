"use strict"

module.exports = (dancer) ->
  kick = dancer.createKick
    onKick: ->
      # TODO

    offKick: ->
      # TODO

  dancer.onceAt 0, -> do kick.on

