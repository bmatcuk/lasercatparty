"use strict"

MUSIC = [
  {audio: "/audio/Anamanaguchi - Meow.mp3", script: "scripts/anamanaguchi.meow"}
  {audio: "/audio/Ashworth - Meow Mix.mp3", script: "scripts/ashworth.meow-mix"}
]

class Jukebox
  constructor: (@iOS, @songProgress, @volume) ->
    @currentTrack = Math.floor(Math.random() * MUSIC.length)

    # handle volume changes
    mousedown = (e) =>
      return unless @dancer?
      mousemove = (e) =>
        vol = Math.min(1.0, Math.max(0.0, (e.clientX - @volume.offsetLeft) / @volume.offsetWidth))
        @dancer.setVolume vol
        @volume.setAttribute 'value', @dancer.getVolume()
      mouseup = (e) =>
        mousemove e
        @volume.removeEventListener 'mousemove', mousemove
        @volume.removeEventListener 'mouseup', mouseup
      @volume.addEventListener 'mousemove', mousemove
      @volume.addEventListener 'mouseup', mouseup
    @volume.addEventListener 'mousedown', mousedown

  loadNext: ->
    @currentTrack = (@currentTrack + 1) % MUSIC.length
    @playPromise = null
    new Promise (resolve, reject) =>
      done = =>
        @dancer.unbind 'loaded'

        @progressHandler = =>
          @songProgress.setAttribute 'value', @dancer.audio.currentTime
        @songProgress.setAttribute 'max', @dancer.audio.duration
        @dancer.audio.addEventListener 'timeupdate', @progressHandler

        @volume.setAttribute 'value', @dancer.getVolume()
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
        @dancer.audio.removeEventListener 'timeupdate', @progressHandler
        @dancer.audio.removeEventListener 'ended', onended
        @progressHandler = null
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

