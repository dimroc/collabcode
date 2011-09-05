# TODO:
# 1) Figure out a way to disable the ACE editor.
# 2) Discover a mechanism for real-time communication b/w server and client
# -  - It seems zappa has some bugs with the socket.io implementation.
# -  - Use NowJS?
# 3) List users in the current channel.
# 4) Implement locking mechanism for users


@include = ->
  enable 'serve now'
  enable 'serve socket.io'

  get '/collabs': ->
    redirect '/'

  get '/collabs/:id': ->
    console.log "[TRACE] retrieve id #{@id}"

    ace_modes = [
      {name: 'text'}
      {name: 'javascript', src: 'mode-javascript.js'}
      {name: 'coffeescript', src: 'mode-coffee.js'}
      {name: 'csharp', src: 'mode-csharp.js'}
      {name: 'c', src: 'mode-c_cpp.js'}
      {name: 'html', src: 'mode-html.js'}
      {name: 'python', src: 'mode-python.js'}
      {name: 'ruby', src: 'mode-ruby.js'}
    ]

    code = @id
    collab_docs.get @id, (err, updated_doc) ->
      console.log "[TRACE] callback from findOne: #{err} and #{updated_doc}"
      if err?
        lines = [err,]
      else if updated_doc?
        code = updated_doc.code
        lines = updated_doc.lines
      else
        lines = [
          'Start coding here!',
          'Select your language highlighting preference up top.',
          '',
          'Only one person can edit at a time.',
          'Click the lock symbol to the right lock editing to you.'
        ]

      render 'collab', {code, ace_modes, lines}

# NOTICE: The wrong event handler gets invoked when running this code!
  at connection: ->
    console.log "CONNECTION"
    emit 'test_hook'


