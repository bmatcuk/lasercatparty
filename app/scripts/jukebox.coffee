"use strict"

MUSIC = [
  {audio: "/audio/Anamanaguchi - Meow.mp3", script: "scripts/anamanaguchi.meow"}
  {audio: "/audio/Ashworth - Meow Mix.mp3", script: "scripts/ashworth.meow-mix"}
]

class ScriptEvents
  constructor: (@jukebox) ->
    @events = []

  fireAt: (timestamp) ->
    for i in [@events.length - 1..0]
      event = @events[i]
      switch event.type
        when "after"
          if timestamp >= event.timestamp
            event.callback.apply @jukebox
        when "before"
          if timestamp < event.timestamp
            event.callback.apply @jukebox
        when "between"
          if event.startTime <= timestamp < event.endTime
            event.callback.apply @jukebox
        when "onceAt"
          if timestamp >= event.timestamp
            event.callback.apply @jukebox
            @events.splice i, 1

  after: (t, callback) ->
    @events.push
      type: "after"
      timestamp: t
      callback: callback

  before: (t, callback) ->
    @events.push
      type: "before"
      timestamp: t
      callback: callback

  between: (t1, t2, callback) ->
    @events.push
      type: "between"
      startTime: t1
      endTime: t2
      callback: callback

  onceAt: (t, callback) ->
    @events.push
      type: "onceAt"
      timestamp: t
      callback: callback

class Jukebox
  constructor: (@iOS, @songProgress, @volume) ->
    @currentTrack = Math.floor(Math.random() * MUSIC.length)
    @paused = true

    # build audio processing pipeline
    @context = new (window.AudioContext || window.webkitAudioContext)()
    @gain = do @context.createGain
    @gain.gain.value = 1.0
    @gain.connect @context.destination

    @analyser = do @context.createAnalyser
    @analyser.fftSize = 1024
    @analyser.connect @gain
    @freqData = new Float32Array @analyser.frequencyBinCount
    @timeData = new Float32Array @analyser.fftSize

    unless @iOS
      # iOS has a MediaElementAudioSourceNode, but it doesn't work. We use an
      # AudioBufferSourceNode instead, but that means the whole file must be
      # downloaded before playback can start. Also, we can't actually create
      # the node until we begin playback, because the node itself cannot
      # pause - it must be stopped and a new node created to resume.
      @audio = new Audio
      @audio.addEventListener 'durationchange', =>
        @songProgress.setAttribute 'max', @audio.duration
      @audio.addEventListener 'timeupdate', =>
        @songProgress.setAttribute 'value', @audio.currentTime

      @source = @context.createMediaElementSource @audio
      @source.connect @analyser

    # handle volume changes
    mousedown = (e) =>
      mousemove = (e) =>
        vol = Math.min(1.0, Math.max(0.0, (e.clientX - @volume.offsetLeft) / @volume.offsetWidth))
        @gain.gain.value = vol
        @volume.setAttribute 'value', vol
      mouseup = (e) =>
        mousemove e
        @volume.removeEventListener 'mousemove', mousemove
        @volume.removeEventListener 'mouseup', mouseup
      @volume.addEventListener 'mousemove', mousemove
      @volume.addEventListener 'mouseup', mouseup
    @volume.addEventListener 'mousedown', mousedown
    @volume.setAttribute 'value', @gain.gain.value

  loadNext: ->
    @currentTrack = (@currentTrack + 1) % MUSIC.length
    @playPromise = null
    new Promise (resolve, reject) =>
      done = =>
        if @iOS
          # TODO: unbind event listener
        else
          @audio.removeEventListener 'canplay', done

        @scriptEvents = new ScriptEvents @
        script = require MUSIC[@currentTrack].script
        resolve new script @scriptEvents

      if @iOS
        # TODO: load song via AJAX
      else
        @audio.src = MUSIC[@currentTrack].audio
        if @audio.readyState >= HTMLMediaElement.HAVE_ENOUGH_DATA
          do done
        else
          @audio.addEventListener 'canplay', done

  play: ->
    if @playPromise
      # promise is already created, so just restart playback
      if @iOS
        # TODO: recreate buffer node and start where we left off
      else
        do @audio.play
      @paused = false
      return @playPromise

    @playPromise = new Promise (resolve, reject) =>
      if @iOS
        # TODO: create buffer node and start playback
      else
        do @audio.play
      @paused = false

      onended = =>
        if @iOS
          # TODO: remove event listener
        else
          @audio.removeEventListener 'ended', onended

        @playPromise = null
        do resolve

      if @iOS
        # TODO: add event listener
      else
        @audio.addEventListener 'ended', onended

  pause: ->
    new Promise (resolve, reject) =>
      if @iOS
        # TODO: stop playback
      else
        do @audio.pause
      @paused = true

      onunpaused = =>
        if @iOS
          # TODO: remove listener
        else
          @audio.removeEventListener 'play', onunpaused
        do resolve

      if @iOS
        # TODO: add listener
      else
        @audio.addEventListener 'play', onunpaused

  update: (timestamp) ->
    return if @paused

    audioTime = if @iOS
      # TODO
    else
      @audio.currentTime
    @scriptEvents.fireAt audioTime

  getWaveform: ->
    @analyser.getFloatTimeDomainData @timeData
    @timeData

  getSpectrum: ->
    @analyser.getFloatFrequencyData @freqData
    @freqData

  getCurrentTime: ->
    if @iOS
      # TODO
    else
      @audio.currentTime

  getDuration: ->
    if @iOS
      # TODO
    else
      @audio.duration

module.exports = Jukebox

