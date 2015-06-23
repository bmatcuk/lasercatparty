"use strict"

class DanceFloor
  constructor: (scene) ->
    @geometry = new THREE.PlaneGeometry 2000, 2000, 10, 10
    @material = new THREE.MeshBasicMaterial color: 0xffff00, side: THREE.FrontSide
    @plane = new THREE.Mesh @geometry, @material
    @plane.visible = false
    scene.add @plane

  show: (timestamp) ->
    @plane.visible = true

  render: (timestamp) ->

module.exports = DanceFloor

