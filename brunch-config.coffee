exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo:
        'scripts/app.js': /^app(\/|\\)(?!templates)/
        'scripts/vendor.js': /^(?!app)/
      order:
        before: [
          'app/util/ng-core.coffee'
          'app/main.coffee'
        ]
    stylesheets:
      joinTo: 'styles/app.css'
    templates:
      noSourceMap: true
      sourceMaps: false
      joinTo:  #['js/templates.js']
        'scripts/templates.js': /^(app)/

  # clean compiled js file from modules header and wrap it like coffeescript should
  modules:
    definition: false
    wrapper: false

  plugins:

    coffeescript:
      bare: false

    autoprefixer:
      browsers: ["last 1 version", "> 1%", "ie 8", "ie 7"]
      options:
        cascade: false

    uglify:
      mangle: false
      compress:
        global_defs:
          DEBUG: false

  paths:
    public: 'www'

  keyword:
    filePattern: /\.(js|css|html|txt)$/

    # Extra files to process which `filePattern` wouldn't match
    # extraFiles: [
    #   'public/version.txt'
    # ]

    # By default keyword-brunch has these keywords: (using information from package.json)
    #     {!version!}, {!name!}, {!date!}, {!timestamp!}
    map:
      mode: 'dev'
      built: -> (new Date).toISOString()
      baseurl: 'http://www.myurl.com'

  overrides:
    production:
      keyword:
        map:
          mode: 'production'
          baseurl: 'http://www.myurl.com'
