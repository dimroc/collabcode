@include = ->
  get '/': ->
    console.log '[TRACE] at root "/"'
    render 'index'

  at collab_requested: ->
    console.log '[TRACE] received collab request with email ' + @email
    io.sockets.emit 'collab_created', collab_code: 'gibberish'

    if @email?
      # send email
      emailjs = require "emailjs"

      username = process.env.SENDGRID_USERNAME || 'app820434@heroku.com'
      password = process.env.SENDGRID_PASSWORD || '69720811bbfb6510c7'

      console.log "[TRACE] mailer constructed. attempting to send to #{@email} from #{username}"

      server = emailjs.server.connect({
        user: username,
        password: password,
        host: "smtp.sendgrid.net",
        ssl: true
      })

      server.send({
        from: "#{username}",
        to: "#{@email}",
        subject: "[Collab][Code] Collab Site Created"
        text: "i hope this works",
      }, (err, message) -> console.log(err || message))

  client '/root.js': ->
    connect()

    at collab_created: ->
      console.log 'client received new collab at ' + @collab_code
      $('#collab_info').append('<ul><li><a href="#">' + @collab_code + '</a></li></ul>')

    $().ready ->
      $('#collab_button').click ->
        # create a collab and send an email if the address was populated.
        emit 'collab_requested', email: $('#email').val()
        $('#collab_button').attr("disabled", "disabled")
        $('#collab_button').addClass("positive")
        $('#collab_button').text('Collab Site Created')

  view index: ->
    div id: 'root', ->
      h1 '[ Collab ][ Code ]'
      div ->
        p ->
          text 'Collaborate on code snippets remotely!'
          br()
          text 'Great for conducting short programming interviews.'
          br()
          text 'Inspired by '
          a href: 'http://i.seemikecode.com/', ->
            'i.See[Mike]Code.'
      div ->
        p ->
          b 'Email Address (Optional)'
          br()
          i 'If you want the URLs mailed to you. Never shared or sold.'
          br()
          input id: 'email', type: 'text'
          br()
          br()
          button id: 'collab_button', class: 'button', ->
            'Create Collab Site'

      div id: 'collab_info'
      
    script src: '/root.js'
