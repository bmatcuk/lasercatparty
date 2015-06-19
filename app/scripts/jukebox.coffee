"use strict"

MUSIC = [
  {audio: "/audio/Anamanaguchi - Meow.mp3", build: require("scripts/anamanaguchi.meow"), name: "Anamanaguchi - Meow"},
  {audio: "/audio/Ashworth - Meow Mix.mp3", build: require("scripts/ashworth.meow-mix"), name: "Ashworth - Meow Mix"}
]

class Jukebox
  constructor: ->
    @currentTrack = Math.floor(Math.random() * MUSIC.length)
    @dancer = new Dancer

  loadNext: ->
    @currentTrack = (@currentTrack + 1) % MUSIC.length
    new Promise (resolve, reject) =>
      @dancer.load src: MUSIC[@currentTrack].audio
      MUSIC[@currentTrack].build @dancer
      if @dancer.isLoaded()
        do resolve
      else
        @dancer.bind 'loaded', resolve

  play: ->
    do @dancer.play

module.exports = Jukebox

