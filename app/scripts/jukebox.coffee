"use strict"

MUSIC = [
  {audio: "/audio/Anamanaguchi - Meow.mp3", script: "scripts/anamanaguchi.meow"}
  {audio: "/audio/Ashworth - Meow Mix.mp3", script: "scripts/ashworth.meow-mix"}
]

class Jukebox
  constructor: ->
    @currentTrack = Math.floor(Math.random() * MUSIC.length)

  loadNext: ->
    #@currentTrack = (@currentTrack + 1) % MUSIC.length
    @currentTrack = 0 # TODO: remove
    @playPromise = null
    new Promise (resolve, reject) =>
      done = =>
        script = require MUSIC[@currentTrack].script
        resolve new script @dancer
      @dancer = new Dancer
      @dancer.load src: MUSIC[@currentTrack].audio
      if @dancer.isLoaded()
        do done
      else
        @dancer.bind 'loaded', done

  play: ->
    if @playPromise
      do @dancer.play
      return @playPromise

    @playPromise = new Promise (resolve, reject) =>
      do @dancer.play
      onended = =>
        @dancer.audio.removeEventListener 'ended', onended
        @playPromise = null
        do @dancer.pause
        do resolve
      @dancer.audio.addEventListener 'ended', onended

  pause: ->
    new Promise (resolve, reject) =>
      do @dancer.pause
      onunpaused = =>
        @dancer.audio.removeEventListener 'play', onunpaused
        do resolve
      @dancer.audio.addEventListener 'play', onunpaused

module.exports = Jukebox

