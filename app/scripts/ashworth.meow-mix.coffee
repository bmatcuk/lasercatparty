"use strict"

AbstractScript = require 'scripts/abstract_script'

class Script extends AbstractScript
  artist: 'Ashworth'
  title: 'Meow Mix'
  image: '/images/ashworth.meow-mix.jpg'
  url: 'https://soundcloud.com/meowmixofficial/a_meow_mix_by_ashworth'

  run: (objs) ->
    super objs

module.exports = Script

