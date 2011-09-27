@include = ->
  requiring 'emailjs', 'os', 'net', 'url'
  def logger: require('log4js').getLogger()

  # I'm not happy with this, but node searches for modules relative
  # to where zappa launches which is deep in the node_modules dir.
  # TODO: find better way to require modules in project base dir.
  def murmurhash: require '../../../murmurhash3_gc.js'

  helper send_collab_email_helper: (email_address, collab) ->
    # send email
    username = process.env.SENDGRID_USERNAME
    password = process.env.SENDGRID_PASSWORD

    if username?
      logger.debug "mailer constructed. attempting to send to #{email_address} from #{username}"

      server = emailjs.server.connect({
        user: username,
        password: password,
        host: "smtp.sendgrid.net",
        ssl: true
      })

      text_to_send =
        '''Code collaborators, interviewers, job candidates, and whoever, share code here:

          '''
      text_to_send += "#{collab.site}"

      server.send({
        from: "#{username}",
        to: "#{email_address}",
        subject: "[Collab][Code] Collab Site Created",
        text: text_to_send
      }, (err, message) -> logger.debug(err || message))

  get '/': ->
    logger.debug 'request URL ' + request.url
    render 'index'

  at collab_requested: ->
    logger.debug 'received collab request with email ' + @email
    current_date = new Date()
    if @email?
      collab_code = murmurhash.murmurhash(@email, current_date.getTime())
    else
      collab_code = murmurhash.murmurhash('collab_key' + current_date.getTime(), current_date.getTime())
    collab_code = collab_code.toString 16

    logger.debug 'got code ' + collab_code
    base_address = process.env.DOMAIN || app.address().address + ':' + app.address().port

    collab_site = 'http://' + base_address + "/collabs/#{collab_code}"
    logger.debug ' got site ' + collab_site
    collab = { site: collab_site, code: collab_code }

    logger.debug 'dispatching collab ' + JSON.stringify collab
    emit 'collab_created', collab: collab

    if @email? and @email != ""
      send_collab_email_helper @email, collab
      
  client '/root.js': ->
    connect()

    at collab_created: ->
      logger.debug 'client received collab site ' + JSON.stringify @collab
      $('#collab_info').append(
        "<ul><li><a href='collabs/#{@collab.code}'>" +
        document.URL + "collabs/#{@collab.code}" +
        '</a></li><li>Now you can share the url and have multiple users collaborate on a piece of code.</li></ul>')

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

      div id: 'collab_info', style: '''clear:both''', ->
      
    script src: '/root.js'
