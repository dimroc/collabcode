@include = ->
  requiring 'emailjs', 'os', 'net'

  # I'm not happy with this, but node searches for modules relative
  # to where zappa launches which is deep in the node_modules dir.
  # TODO: find better way to require modules in project base dir.
  def murmurhash: require '../../../murmurhash3_gc.js'

  helper send_collab_email_helper: (email_address, collab_code) ->
    # send email
    username = process.env.SENDGRID_USERNAME || 'app820434@heroku.com'
    password = process.env.SENDGRID_PASSWORD || '69720811bbfb6510c7'

    console.log "[TRACE] mailer constructed. attempting to send to #{email_address} from #{username}"

    server = emailjs.server.connect({
      user: username,
      password: password,
      host: "smtp.sendgrid.net",
      ssl: true
    })

    server.send({
      from: "#{username}",
      to: "#{email_address}",
      subject: "[Collab][Code] Collab Site Created"
      text: "i hope this works #{collab_code}",
    }, (err, message) -> console.log(err || message))

  get '/': ->
    console.log '[TRACE] at root "/"'
    render 'index'

  at collab_requested: ->
    console.log '[TRACE] received collab request with email ' + @email
    if @email?
      collab_code = murmurhash.murmurhash(@email, new Date().getTime())
    else
      collab_code = murmurhash.murmurhash('collab_key' + new Date().getTime(), new Date().getTime())
    collab_code = collab_code.toString 16

    console.log '[TRACE] got code ' + collab_code
    collab_site = os.hostname() + ':' + app.address().port + "/collabs/#{collab_code}"
    console.log '[TRACE] got site ' + collab_site
    collab = { site: collab_site, code: collab_code }

    console.log '[TRACE] dispatching collab ' + JSON.stringify collab
    io.sockets.emit 'collab_created', collab: collab

    if @email?
      send_collab_email_helper @email, collab.code
      
  client '/root.js': ->
    connect()

    at collab_created: ->
      console.log 'client received collab site ' + JSON.stringify @collab
      $('#collab_info').append("<ul><li><a href='collabs/#{@collab.code}'>" + @collab.site + '</a></li></ul>')

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
