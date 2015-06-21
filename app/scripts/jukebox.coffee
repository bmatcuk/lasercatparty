"use strict"

MUSIC = [
  {audio: "/audio/Anamanaguchi - Meow.mp3", script: "scripts/anamanaguchi.meow"}
  {audio: "/audio/Ashworth - Meow Mix.mp3", script: "scripts/ashworth.meow-mix"}
]

currentTrack = 0
dancer = null
module.exports =
  init: ->
    currentTrack = Math.floor(Math.random() * MUSIC.length)
    do Promise.resolve

  loadNext: ->
    currentTrack = (currentTrack + 1) % MUSIC.length
    new Promise (resolve, reject) ->
      done = ->
        script = require MUSIC[currentTrack].script
        resolve new script dancer
      dancer = new Dancer
      dancer.load src: MUSIC[currentTrack].audio
      if dancer.isLoaded()
        do done
      else
        dancer.bind 'loaded', done

  play: ->
    new Promise (resolve, reject) ->
      do dancer.play
      onended = ->
        this.removeEventListener 'ended', onended
        do dancer.pause
        do resolve
      dancer.audio.addEventListener 'ended', onended

