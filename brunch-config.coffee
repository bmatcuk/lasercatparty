exports.config =
  files:
    javascripts:
      joinTo:
        'javascripts/test.js': /test/
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
        require('postcss-cssnext')({browsers: '> 5%'})
        require('cssnano')
      ]

  overrides:
    production:
      optimize: true
      sourceMaps: false
      plugins: autoReload: enabled: false
      conventions: ignored: /(test|jade[\\/]runtime.js$)/

  npm: enabled: false
