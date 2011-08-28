port = Number(process.env.VMC_APP_PORT || process.env.C9_PORT || process.env.PORT || 3000)
zappa = require('zappa')
nko = require('nko')
nko('n710A/A4SZeui+7c')

# export NODE_ENV=production

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
  include 'collabs.coffee'
  include 'root.coffee'
