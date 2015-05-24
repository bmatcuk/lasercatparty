"use strict"

DEFAULT_MUSIC = "https://soundcloud.com/hailtiki/sets/lasercat-party"

clientId = require('scripts/apis').soundcloud
SC.initialize client_id: clientId

reqAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || (callback) -> setTimeout(callback, 1000 / 60)

class AnalysisMachine
  constructor: (@jukebox) ->
    @freqData = new Uint8Array @jukebox.analyser.frequencyBinCount
    @timeData = new Uint8Array @jukebox.analyser.fftSize
    @running = true
    do @analysis

  analysis: ->
    @jukebox.analyser.getByteFrequencyData @freqData
    @jukebox.analyser.getByteTimeDomainData @timeData
    peak = Math.max.apply null, @timeData
    @jukebox.analysisDelegate @freqData, @timeData, peak
    if @running
      reqAnimationFrame => do @analysis

  stop: -> @running = false

class Jukebox
  constructor: (@url) ->
    @url = DEFAULT_MUSIC unless @url?
    @tracks = null
    @currentTrack = -1

    @audio = new Audio()
    @audio.mozAudioChannelType = "content"
    @audio.crossOrigin = "anonymous"
    @audio.preload = "auto"
    @audio.type = "audio/mpeg"
    @audio.loop = false
    @audio.addEventListener 'play', =>
      do @startAnalysis
    @audio.addEventListener 'ended', =>
      do @stopAnalysis
      do @playRandom
    @audio.addEventListener 'error', =>
      do @stopAnalysis
      @tracks.splice @currentTrack, 1
      do @errorDelegate
      do @playRandom

    @context = new (window.AudioContext || window.webkitAudioContext || window.mozAudioContext)()
    @analyser = context.createAnalyser()
    @analyser.fftSize = 1024
    @analyser.connect @context.destination

    @media = context.createMediaElementSource @audio
    @media.connect @analyser

  load: ->
    new Promise (resolve, reject) =>
      SC.get '/resolve', {url: @url}, (track, err) =>
        if err?
          reject err
          return

        # we need to grab the actual streaming url using this hidden API
        promises = for t in (if track.tracks? then track.tracks else [track])
          do (t) ->
            new Promise (resolve, _) ->
              SC.get "/i1/tracks/#{t.id}/stream", (streams, err) ->
                if err?
                  resolve null
                else if streams.http_mp3_128_url
                  t.stream_url = streams.http_mp3_128_url
                  resolve t

        Promise.all(promises).then (streams) =>
          @tracks = streams.filter (t) -> t? && t.stream_url?
          do resolve

  playRandom: ->
    @currentTrack = Math.floor(Math.random() * @tracks.length)
    track = @tracks[@currentTrack]
    @audio.src = "http://crossorigin.me/#{track.stream_url}"
    do @audio.play

  startAnalysis: ->
    if @machine?
      do @machine.stop
    @machine = new AnalysisMachine @

  stopAnalysis: ->
    if @machine?
      do @machine.stop
      @machine = null

  analysisDelegate: -> return

  errorDelegate: -> return

module.exports =
  jukebox: Jukebox

