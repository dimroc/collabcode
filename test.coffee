padding = ->
  mongolian = require 'mongolian'

  mongo_connect = ->
    hostname = process.env.MONGO_HOST || 'localhost'
    dbname = process.env.MONGO_DB || 'test'
    user = process.env.MONGO_USER
    password = process.env.MONGO_PASS

    if user?
      connection_string = "#{user}:#{password}@#{hostname}/#{dbname}"
    else
      connection_string = "#{hostname}/#{dbname}"

    console.log connection_string
    db = new mongolian connection_string
    console.log 'finished connecting'

    things = db.collection "things"
    things.find().limit(5).forEach (thing) ->
      if thing?
        console.log thing.x

  mongo_connect()
padding()
