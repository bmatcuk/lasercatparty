"use strict"

DEFAULT_MUSIC = "https://soundcloud.com/hailtiki/sets/lasercat-party"

clientId = require('scripts/apis').soundcloud
SC.initialize client_id: clientId

context = new (window.AudioContext || window.webkitAudioContext)()
audio = new Audio()
audio.mozAudioChannelType = "content"
audio.preload = "auto"
audio.type = "audio/mpeg"
audio.crossOrigin = "anonymous"
audio.loop = false
audio.addEventListener 'abort', (e) -> console.log e
audio.addEventListener 'error', (e) -> console.log e
window.test = audio

media = context.createMediaElementSource audio
media.connect context.destination

tracks = null
currentTrack = -1
loadNextTrack = ->
  console.log 'Loading next track'
  audio.removeEventListener 'ended', loadNextTrack
  return unless tracks?
  currentTrack++
  currentTrack = 0 if currentTrack >= tracks.length
  audio.src = "#{tracks[currentTrack].stream_url}"
  audio.addEventListener 'canplay', playCurrentTrack
  do audio.load
playCurrentTrack = ->
  console.log 'Playing current track...'
  audio.removeEventListener 'canplay', playCurrentTrack
  do audio.play

module.exports =
  load: (url) ->
    new Promise (resolve, reject) ->
      url = DEFAULT_MUSIC unless url?
      SC.get '/resolve', {url: url}, (track, err) ->
        if err?
          reject err
          return

        # we need to grab the actual streaming url using this hidden API endpoint
        promises = for t in (if track.tracks? then track.tracks else [track])
          do (t) ->
            new Promise (resolve, reject) ->
              SC.get "/i1/tracks/#{t.id}/streams", (streams) ->
                console.log t.stream_url
                console.log streams.http_mp3_128_url
                if streams.http_mp3_128_url?
                  t.stream_url = streams.http_mp3_128_url
                  resolve t

        Promise.all(promises).then (streams) ->
          currentTrack = -1
          tracks = streams.filter (t) -> t.stream_url?
          do loadNextTrack
          do resolve

  play: audio.play

