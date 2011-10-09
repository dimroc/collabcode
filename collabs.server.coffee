@include = ->
  get '/collabs': ->
    redirect '/'

  get '/collabs/:id': ->
    logger.debug "retrieve id #{@id}"

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
      logger.debug "callback from findOne: error: #{err}"
      logger.debug updated_doc

      if err?
        lines = [err,]
      else if updated_doc?
        code = updated_doc.code
        lines = updated_doc.lines

      if lines? || typeof lines == "undefined"
        lines = [
            'Start coding here!',
            'Select your language highlighting preference up top.',
            '',
            'Only one person can edit at a time.',
            'Click the lock symbol to the right lock editing to you.'
          ]

      render 'collab', {code, ace_modes, lines}

  at connection: ->
    logger.debug "CONNECTION"

  at disconnect: ->
    socket.get 'username', (err, name) ->
      logger.debug "#{name} disconnected."
      # Get code / room channel from socket.io user info
      socket.get 'code', (err, code) ->
        collab_docs.clear_locker code
        collab_docs.remove_user code, name
        collab_docs.get_users code, (err, val) =>
          if val? && val.users?
            socket.broadcast.to(code).emit 'current users update', users: val.users


  at join_room_handler: ->
    logger.debug "user <#{@username}> joining room #{@code}."
    socket.set 'username', @username
    socket.set 'code', @code
    socket.join @code

    # Updating everyone in room with the current users
    collab_docs.add_user @code, @username, (err, val) =>
      collab_docs.get_users @code, (err, val) =>
        users = val.users;
        logger.debug "broadcasting current users:"
        logger.debug users
        socket.broadcast.to(@code).emit 'current users update', users: users
        emit 'current users update', users: users

    # Update connecting user with the current locker, if any
    collab_docs.get_locker @code, (err, val) =>
      if val? && val.locker?
        emit 'editing locked', locker: val.locker

  at get_users_handler: ->
    logger.debug "retrieving the current users in the room."
    collab_docs.get_users @code, (err, users) =>
      socket.emit 'user update', users

  at 'collab updated handler': ->
    logger.debug "updating collab with code #{@code} with lines: #{@lines}"
    collab_docs.set_lines @code, @lines, (err, updated_doc) ->
      socket.broadcast.to(updated_doc.code).emit 'collab updated', code: updated_doc.code, lines: updated_doc.lines

  at 'toggle lock handler': ->
    socket.get 'username', (err, name) ->
      socket.get 'code', (err, code) ->
        collab_docs.get_locker code, (err, val) ->
          if err?
            logger.debug "[ERROR] #{err}"
          else
            if val? && val.locker?
              # A locker exists
              if val.locker == name
                logger.debug "Releasing the lock for room #{code} from user #{name}"
                collab_docs.clear_locker code
                #TODO: Figure out how to broadcast to everyone including myself
                socket.broadcast.to(code).emit 'release lock'
                emit 'release lock'
              else
                logger.debug "Cannot retrieve lock, already locked by #{val.locker}"
            else
              logger.debug "Assigning edit lock for room #{code} to user <#{name}>"
              collab_docs.set_locker code, name
              socket.broadcast.to(code).emit 'editing locked', locker: name
              emit 'editing locked for me', locker: name

