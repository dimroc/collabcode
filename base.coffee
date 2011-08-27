@include = ->
  view layout: ->
    doctype 5
    html ->
      head ->
        title 'collab coding'
        script src: '/socket.io/socket.io.js'
        script src: '/zappa/jquery.js'
        script src: '/zappa/zappa.js'
      body ->
        @body

