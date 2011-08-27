@include = ->
  get '/collab/:id': ->
    console.log "[TRACE] retrieve id #{@id}"
    render 'collab', layout: no

  client '/collab.js': ->
    $().ready ->
      alert 'welcome'

  view collab: ->
    doctype 5
    html ->
      head ->
        title 'collab coding'
        script src: '/socket.io/socket.io.js'
        script src: '/zappa/jquery.js'
        script src: '/zappa/zappa.js'
        script src: '/collab.js'
      body ->
        div id: 'panel', ->
          p @id
          
