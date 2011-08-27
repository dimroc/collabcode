@include = ->
  get '/': ->
    console.log '[TRACE] at root "/"'
    render 'index'

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
    div id: 'panel', ->
      p 'welcome'
    script src: '/root.js'
