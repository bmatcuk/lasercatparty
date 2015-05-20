"use strict"

BACKGROUNDS = [
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2011-38-a-xlarge_web.jpg", name: "Sharpless 2-106", link: "http://hubblesite.org/newscenter/archive/releases/2011/38/image/a/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2012-01-a-xlarge_web.jpg", name: "30 Doradus", link: "http://hubblesite.org/newscenter/archive/releases/2012/01/image/a/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2010-13-a-xlarge_web.jpg", name: "Mystic Mountain, Carina Nebula, HH 901, HH 902", link: "http://hubblesite.org/newscenter/archive/releases/2010/13/image/a/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2015-12-a-xlarge_web.jpg", name: "Westerlund 2, Gum 29, Carina", link: "http://hubblesite.org/newscenter/archive/releases/2015/12/image/a/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2006-46-a-xlarge_web.jpg", name: "Antennae Galaxies, NGC 4038-4039", link: "http://hubblesite.org/gallery/album/galaxy/pr2006046a/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2006-14-a-xlarge_web.jpg", name: "Starburst Galaxy M82", link: "http://hubblesite.org/gallery/album/galaxy/pr2006014a/hires/true/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2014-04-a-xlarge_web.jpg", name: "Spiral Galaxy M83", link: "http://hubblesite.org/gallery/album/galaxy/pr2014004a/hires/true/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2007-19-a-xlarge_web.jpg", name: "Spiral Galaxy M81", link: "http://hubblesite.org/gallery/album/galaxy/pr2007019a/hires/true/"},
  {image: "http://imgsrc.hubblesite.org/hu/db/images/hs-2006-10-a-xlarge_web.jpg", name: "Spiral Galaxy M101", link: "http://hubblesite.org/gallery/album/galaxy/pr2006010a/"}
]

createBackground = (background) ->
  existingBackgrounds = document.querySelectorAll 'section.background'
  if existingBackgrounds.length
    removeExistingBackground = -> Array.prototype.forEach existingBackgrounds, (b) -> b.parentNode.removeChild b
    setTimeout(removeExistingBackground, 2000)

  bg = document.createElement 'SECTION'
  bg.style.backgroundImage = "url(#{background.image})"
  bg.classList.add 'background'
  document.body.appendChild bg

module.exports =
  loadRandom: ->
    new Promise (resolve, reject) ->
      idx = Math.floor(Math.random() * BACKGROUNDS.length)
      background = BACKGROUNDS[idx]

      onload = ->
        this.removeEventListener 'load', onload
        createBackground background
        resolve background

      image = new Image()
      image.addEventListener 'load', onload
      image.src = background.image

