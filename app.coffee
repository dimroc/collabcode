port = Number(process.env.VMC_APP_PORT || process.env.C9_PORT || process.env.PORT || 3000)
zappa = require('zappa')

zappa port, ->
  enable 'serve jquery'

  publicDir = __dirname + '/public'
  use 'logger', 'bodyParser', 'cookieParser', express.session({secret: 'collaborative coffee'})
  use 'methodOverride', app.router
  use express.compiler(src: publicDir, enable: ['sass', 'coffeescript'])
  use 'static'

  configure
    development: -> use errorHandler: {dumpExceptions: on, showStack: on}
    production: -> use 'errorHandler'

  include 'collab.coffee'
  include 'root.coffee'