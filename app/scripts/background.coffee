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

module.exports =
  loadRandom: ->
    new Promise (resolve, reject) ->
      idx = Math.floor(Math.random() * BACKGROUNDS.length)
      img = BACKGROUNDS[idx]
      texture = THREE.ImageUtils.loadTexture img.image, THREE.UVMapping, ->
        texture.minFilter = THREE.NearestFilter

        background = new Background texture
        resolve background

