exports.config =
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app[\\/]/
        'javascripts/vendor.js': /^(vendor|bower_components)[\\/]/
      order:
        after: /^app[\\/]scripts[\\/]main\./

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)[\\/]/
      order:
        before: /^app[\\/]stylesheets[\\/]_/

    templates:
      joinTo: 'javascripts/app.js'

  conventions:
    assets: /(assets|vendor\/assets|font)/
    ignored: /jade[\\/]runtime.js$/

  plugins:
    jaded:
      staticPatterns: /^app[\\/]static[\\/](.+)\.jade$/
    postcss:
      processors: [
        require('postcss-nested')
        require('cssnext')({browsers: '> 5%'})
      ]

