@include = ->
  get '/collab/:id': ->
    console.log "[TRACE] retrieve id #{@id}"
    render 'collab'

  client '/collab.js': ->
    $().ready ->
      @editor = ace.edit "editor"

  view collab: ->
    div id: 'panel', ->
      p @id
    div id: 'editor', ->
      'some text'

    script src: '/javascripts/ace/ace.js'  
    script src: '/collab.js'
          
