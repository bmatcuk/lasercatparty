"use strict"

BACKGROUNDS = [
  {image: "/images/sharpless2-106.jpg", name: "Sharpless 2-106", link: "http://hubblesite.org/newscenter/archive/releases/2011/38/image/a/"}
  {image: "/images/30doradus.jpg", name: "30 Doradus", link: "http://hubblesite.org/newscenter/archive/releases/2012/01/image/a/"}
  {image: "/images/hh901.jpg", name: "Mystic Mountain, Carina Nebula, HH 901, HH 902", link: "http://hubblesite.org/newscenter/archive/releases/2010/13/image/a/"}
  {image: "/images/westerlund2.jpg", name: "Westerlund 2, Gum 29, Carina", link: "http://hubblesite.org/newscenter/archive/releases/2015/12/image/a/"}
  {image: "/images/ngc4038.jpg", name: "Antennae Galaxies, NGC 4038-4039", link: "http://hubblesite.org/gallery/album/galaxy/pr2006046a/"}
  {image: "/images/m82.jpg", name: "Starburst Galaxy M82", link: "http://hubblesite.org/gallery/album/galaxy/pr2006014a/hires/true/"}
  {image: "/images/m83.jpg", name: "Spiral Galaxy M83", link: "http://hubblesite.org/gallery/album/galaxy/pr2014004a/hires/true/"}
  {image: "/images/m81.jpg", name: "Spiral Galaxy M81", link: "http://hubblesite.org/gallery/album/galaxy/pr2007019a/hires/true/"}
  {image: "/images/m101.jpg", name: "Spiral Galaxy M101", link: "http://hubblesite.org/gallery/album/galaxy/pr2006010a/"}
]

class Background
  constructor: (@texture) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [width, height] = if aspect > 1.0 then [2.0 * aspect, 2.0] else [2.0, 2.0 / aspect]

    @geometry = new THREE.PlaneBufferGeometry width, height
    @material = new THREE.MeshBasicMaterial map: @texture
    @plane = new THREE.Mesh @geometry, @material
    @plane.position.z = -0.9

  setScene: (scene) ->
    scene.add @plane

class BackgroundReflection
  constructor: (@texture) ->
    # calculate width and height
    aspect = @texture.image.width / @texture.image.height
    [halfwidth, halfheight] = if aspect > 1.0 then [1.0 * aspect, 1.0] else [1.0, 1.0 / aspect]
    narrow = 0.2

    vertices = new Float32Array [
      -halfwidth, halfheight, 0.0
      halfwidth, halfheight, 0.0
      -narrow * halfwidth, -halfheight * 0.5, 0.0
      narrow * halfwidth, -halfheight * 0.5, 0.0
    ]
    indexes = new Uint16Array [0, 2, 1, 2, 3, 1]
    uvs = new Float32Array [
      0, 0, 1
      1, 0, 1
      0, narrow, narrow
      narrow, narrow, narrow
    ]

    @geometry = new THREE.BufferGeometry
    @geometry.addAttribute 'position', new THREE.BufferAttribute vertices, 3
    @geometry.addAttribute 'index', new THREE.BufferAttribute indexes, 1
    @geometry.addAttribute 'uvs', new THREE.BufferAttribute uvs, 3
    @geometry.parameters =
      width: 2.0 * halfwidth
      height: 2.0 * halfheight

    @uniforms =
      background:
        type: 't'
        value: @texture
      backgroundOffset:
        type: 'f'
        value: 0.0
      shading:
        type: 'c'
        value: new THREE.Color 0xff808080

    @material = new THREE.ShaderMaterial
      uniforms: @uniforms
      attributes:
        uvs:
          type: 'v3'
      vertexShader: require 'shaders/background_reflection_vert'
      fragmentShader: require 'shaders/background_reflection_frag'

    @plane = new THREE.Mesh @geometry, @material
    @plane.position.z = -0.8

  setScene: (scene) ->
    scene.add @plane

  resize: (left, top) ->
    factor = 2.0 / 5.0
    @plane.position.y = 2.0 * top * factor - top - @geometry.parameters.height / 2.0
    @uniforms.backgroundOffset.value = (@geometry.parameters.height / 2.0 - top + 2.0 * top * factor) / @geometry.parameters.height

module.exports =
  loadRandom: ->
    new Promise (resolve, reject) ->
      idx = Math.floor(Math.random() * BACKGROUNDS.length)
      img = BACKGROUNDS[idx]
      texture = THREE.ImageUtils.loadTexture img.image, THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter

        background = new Background texture
        #reflection = new BackgroundReflection texture
        resolve background

