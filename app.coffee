port = Number(process.env.VMC_APP_PORT || process.env.C9_PORT || process.env.PORT || 3000)
zappa = require('zappa')
logger = require('log4js').getLogger()

zappa port, ->
  enable 'serve jquery'
  io.set 'transports', ['xhr-polling', 'websocket', 'flashsocket', 'htmlfile']

  publicDir = __dirname + '/public'
  use 'logger', 'bodyParser', 'cookieParser', express.session({secret: 'collaborative coffee'})
  use 'methodOverride', app.router
  use express.compiler(src: publicDir, enable: ['sass', 'coffeescript'])
  use 'static'

  configure
    development: -> use errorHandler: {dumpExceptions: on, showStack: on}
    production: -> use 'errorHandler'

  # a collection of views and functionality used in subsequent includes.
  include 'base.coffee'

  # handles all the schemas and models used app side mapped to a mongo collection/document.
  include 'models.coffee'

  # actual resources for the website.
  include 'collabs.server.coffee'
  include 'collabs.client.coffee'
  include 'collabs.view.coffee'

  include 'root.coffee'
