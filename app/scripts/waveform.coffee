"use strict"

class Waveform
  constructor: ->
    @canvas = document.createElement 'canvas'
    @canvas.width = 1024
    @canvas.height = 256

    @context = @canvas.getContext '2d'
    @waveforms = new Array 16
    @waveformIdx = 0

    @geometry = new THREE.PlaneBufferGeometry 2.0, 1.2
    @texture = new THREE.Texture @canvas
    @material = new THREE.MeshBasicMaterial map: @texture, transparent: true
    @plane = new THREE.Mesh @geometry, @material
    @plane.position.y = 0.5
    @plane.position.z = -0.25

  setScene: (scene) ->
    scene.add @plane

  resize: (left, top) ->
    @plane.position.y = top / 2.0 - 0.05
    @plane.scale.x = left
    @plane.scale.y = top

  updateWaveform: (waveform) ->
    @waveforms[@waveformIdx] = new Uint8Array 1024 unless @waveforms[@waveformIdx]?
    wave = @waveforms[@waveformIdx]
    for i in [0..waveform.length]
      wave[i] = 128 - Math.round(waveform[i] * 64)
    @waveformIdx = (@waveformIdx + 1) & 0x0f

    @context.clearRect 0, 0, 1024, 256
    idx = @waveformIdx
    for i in [0...@waveforms.length]
      wave = @waveforms[idx]
      continue unless wave

      do @context.beginPath
      @context.strokeStyle = "rgba(255, 255, 255, #{(i * 16 + 15) / 255})"
      @context.moveTo 0, @waveforms[idx][0]
      for x in [1...wave.length]
        @context.lineTo x, wave[x]
      do @context.stroke
      idx = (idx + 1) & 0x0f

    @texture.needsUpdate = true

module.exports = Waveform

