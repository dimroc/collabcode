@include = ->
  get '/collab/:id': ->
    console.log "[TRACE] retrieve id #{@id}"
    render 'collab', layout: no

  client '/collab.js': ->
    $().ready ->
      alert 'welcome'

  view collab: ->
    div id: 'panel', ->
      p @id
    script src: '/collab.js'
          
