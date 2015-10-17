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
    @analyser.fftSize = 512
    @analyser.connect @gain
    @freqData = new Uint8Array @analyser.frequencyBinCount
    @timeData = new Uint8Array @analyser.fftSize

    @iOS = true if @iOS is false and !@context.createMediaElementSource
    unless @iOS
      # iOS has a MediaElementAudioSourceNode, but it doesn't work. We use an
      # AudioBufferSourceNode instead, but that means the whole file must be
      # downloaded before playback can start. Also, we can't actually create
      # the node until we begin playback, because the node itself cannot
      # pause - it must be stopped and a new node created to resume.
      @audio = new Audio
      @audio.addEventListener 'durationchange', =>
        @songProgress.setAttribute 'max', @audio.duration

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
        @audio.removeEventListener 'canplay', done unless @iOS

        @scriptEvents = new ScriptEvents @
        script = require MUSIC[@currentTrack].script
        resolve new script @scriptEvents

      @paused = true
      if @iOS
        request = new XMLHttpRequest
        request.open 'GET', MUSIC[@currentTrack].audio, true
        request.responseType = 'arraybuffer'
        request.onload = =>
          @context.decodeAudioData request.response, (buffer) =>
            @buffer = buffer
            @songProgress.setAttribute 'max', @buffer.duration
            do done
        do request.send
      else
        @audio.src = MUSIC[@currentTrack].audio
        if @audio.readyState >= HTMLMediaElement.HAVE_ENOUGH_DATA
          do done
        else
          @audio.addEventListener 'canplay', done

  playBuffer: ->
    if @paused is true
      @startedBuffer = @context.currentTime
      offset = 0
    else
      @startedBuffer += @context.currentTime - @paused
      offset = @context.currentTime - @startedBuffer
    @bufferNode = do @context.createBufferSource
    @bufferNode.buffer = @buffer
    @bufferNode.connect @analyser
    @bufferNode.start 0, offset
    @bufferNode.onended = =>
      unless @paused
        do @resolvePlay
        @resolvePlay = null
      @bufferNode = null

  play: ->
    if @playPromise
      # promise is already created, so just restart playback
      if @iOS
        do @playBuffer
      else
        do @audio.play
      @paused = false
      do @onunpaused
      @onunpaused = null
      return @playPromise

    @playPromise = new Promise (resolve, reject) =>
      if @iOS
        do @playBuffer
      else
        do @audio.play
      @paused = false

      onended = =>
        @audio.removeEventListener 'ended', onended unless @iOS
        @playPromise = null
        do resolve

      if @iOS
        @resolvePlay = onended
      else
        @audio.addEventListener 'ended', onended

  pause: ->
    new Promise (resolve, reject) =>
      @paused = @context.currentTime
      if @iOS
        @bufferNode.stop 0
        @bufferNode = null
      else
        do @audio.pause
      @onunpaused = resolve

  update: (timestamp) ->
    return if @paused
    t = do @getCurrentTime
    @songProgress.setAttribute 'value', t
    @scriptEvents.fireAt t

  getWaveform: ->
    @analyser.getByteTimeDomainData @timeData
    @timeData

  getSpectrum: ->
    @analyser.getByteFrequencyData @freqData
    @freqData

  getCurrentTime: ->
    if @iOS
      @context.currentTime - @startedBuffer
    else
      @audio.currentTime

  getDuration: -> if @iOS then @buffer.duration else @audio.duration

module.exports = Jukebox

