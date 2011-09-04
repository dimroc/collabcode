@include = ->
  view layout: ->
    doctype 5
    html ->
      head ->
        title 'collab coding'

        link rel: 'stylesheet', href: '/stylesheets/screen.css', media: "screen, projection"
        link rel: 'stylesheet', href: '/stylesheets/print.css', media: "print"

        ie 'lt IE8', ->
          link rel: 'stylesheet', href: '/stylesheets/ie.css'

        link rel: 'stylesheet', href: '/stylesheets/style.css'

        script src: '/socket.io/socket.io.js'
        script src: '/zappa/jquery.js'
        script src: '/zappa/zappa.js'
      body class: 'bp', ->
        @body

