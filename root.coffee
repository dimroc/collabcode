@include = ->
  get '/': ->
    console.log '[TRACE] at root "/"'
    render 'index', layout: no

  at wannabe: ->
    console.log '[TRACE] received message wannabe!'
    io.sockets.emit 'said', nickname: client.nickname

  client '/root.js': ->
    connect()

    at said: ->
      console.log 'client received said'

    $().ready ->
      emit 'wannabe', nickname: prompt('pick a nickname')

  view index: ->
    doctype 5
    html ->
      head ->
        title 'collab coding'
        script src: '/socket.io/socket.io.js'
        script src: '/zappa/jquery.js'
        script src: '/zappa/zappa.js'
        script src: '/root.js'
      body ->
        div id: 'panel'
