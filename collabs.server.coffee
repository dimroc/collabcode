# TODO:
# 3) List users in the current channel.
# 4) Implement locking mechanism for users

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

  release_lock = ->
    logger.debug ' releasing the edit lock enabling anyone to edit file.'
    # Get code / room channel from socket.io user info
    socket.get 'code', (err, code) ->
      collab_docs.clear_locker code
      emit 'lock_released'

  at connection: ->
    logger.debug "CONNECTION"

  at disconnect: ->
    socket.get 'username', (err, name) ->
      logger.debug "#{name} disconnected."
    # Get code / room channel from socket.io user info
    socket.get 'code', (err, code) ->
      collab_docs.clear_locker code

  at join_room_handler: ->
    logger.debug "user <#{@username}> joining room #{@code}."
    socket.set 'username', @username
    socket.set 'code', @code
    socket.join @code

    # Updating everyone in room with the current users
    collab_docs.add_user @code, @username, (err, val) =>
      collab_docs.get_users @code, (err, users) =>
        logger.debug "broadcasting current users:"
        logger.debug users
        socket.broadcast.to(@code).emit 'current users update', users: users

    # Update connecting user with the current locker, if any
    collab_docs.get_locker @code, (err, val) =>
      if val.locker?
        emit 'editing locked', locker: val.locker

  at get_users_handler: ->
    logger.debug "retrieving the current users in the room."
    #TODO: return the users for the room @code.

  at collab_updated_handler: ->
    logger.debug "updating collab with code #{@code} with lines: #{@lines}"
    collab_docs.set_lines @code, @lines, (err, updated_doc) ->
      socket.broadcast.to(updated_doc.code).emit 'collab_updated', code: updated_doc.code, lines: updated_doc.lines

  at request_lock_handler: ->
    socket.get 'username', (err, name) ->
      if err?
        logger.debug "[ERROR] #{err}"
      else
        logger.debug "attempting to assign edit lock to user <#{name}>"
        #TODO: 1) check that no one already has lock. 2) map lock to this user. 3) emit 'lock_granted' call.

  at release_lock_handler: ->
    release_lock()

