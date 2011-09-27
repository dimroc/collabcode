@logger =
  trace: (msg) ->
    dt = new Date()
    console.log "[#{dt.toLocaleTimeString()}] [TRACE] #{msg}"
  debug: (msg) ->
    dt = new Date()
    console.log "[#{dt.toLocaleTimeString()}] [DEBUG] #{msg}"
  info: (msg) ->
    dt = new Date()
    console.log "[#{dt.toLocaleTimeString()}] [INFO] #{msg}"
  warn: (msg) ->
    dt = new Date()
    console.log "[#{dt.toLocaleTimeString()}] [WARNING] #{msg}"
  error: (msg) ->
    dt = new Date()
    console.log "[#{dt.toLocaleTimeString()}] [ERROR] #{msg}"
  fatal: (msg) ->
    dt = new Date()
    console.log "[#{dt.toLocaleTimeString()}] [FATAL] #{msg}"
