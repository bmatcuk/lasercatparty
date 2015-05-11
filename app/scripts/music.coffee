"use strict"

DEFAULT_MUSIC = "https://soundcloud.com/hailtiki/sets/lasercat-party"

clientId = require('scripts/apis').soundcloud
SC.initialize client_id: clientId

context = new (window.AudioContext || window.webkitAudioContext)()
audio = new Audio()
audio.crossOrigin = "anonymous"
audio.loop = false
audio.addEventListener 'ended', loadNextTrack

media = context.createMediaElementSource audio
media.connect context.destination

tracks = null
currentTrack = -1
loadNextTrack = ->
  return unless tracks?
  currentTrack++
  currentTrack = 0 if currentTrack >= tracks.length
  audio.src = "#{tracks[currentTrack].stream_url}?client_id=#{clientId}"
  do audio.load
  do audio.play

module.exports =
  load: (url) ->
    new Promise (resolve, reject) ->
      url = DEFAULT_MUSIC unless url?
      SC.get 'https://api.soundcloud.com/resolve', {url: url}, (track, err) ->
        if err?
          reject err
          return

        currentTrack = -1
        if track.tracks?
          tracks = track.tracks
        else
          tracks = [track]
        do loadNextTrack

  play: audio.play

