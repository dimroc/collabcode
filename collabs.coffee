@include = ->
  requiring 'timer'
  enable 'serve jquery'
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

  at connection: ->
    console.log 'CONNECTED!!'

  at join_room: ->
    console.log "[TRACE] joining room #{@code}"
    socket.join @code

  at collab_update: ->
    console.log "[TRACE] updating collab with code #{@code} with lines: #{@lines}"
    collab_docs.set @code, @lines, (err, updated_doc) ->
      console.log "[TRACE] updated #{updated_doc.code} to #{updated_doc.lines}"
      socket.broadcast.to(updated_doc.code).emit 'collab_updated', code: updated_doc.code, lines: updated_doc.lines

  client '/collab.js': ->
    connect()

    set_mode = (mode) =>
      console.log 'setting mode to ' + JSON.stringify(mode)
      @editor.getSession().setMode(new @ModeMap[mode])
    
    update_ace_document = (lines) =>
      editor = $("#editor").data("editor_hook")
      document = editor.getSession().getDocument()
      if document?
        if document.getLength() > 0
          console.log "remove #{document.getLength()} lines from doc"
          document.removeLines(0, document.getLength())
        document.insertLines(0, lines)

    at collab_updated: ->
      console.log 'received updated doc for code ' + @code
      mycode = $('#collab_code').text()
      if mycode == @code
        updatefunc = $("#editor").data("update_hook")
        updatefunc @lines
      else
        console.log '[ERROR] received information about the wrong code!'

    periodical_update = (editor, code) ->
      setInterval ->
        console.log 'triggering periodical update'
        lines = editor.getSession().getDocument().getAllLines()
        console.log lines
        emit 'collab_update', code: code, lines: lines
      , 5000

    $().ready =>
      @editor = ace.edit "editor"
      @editor.setTheme "ace/theme/twilight"

      # Create all the modes available in the client editor.
      @TextileMode = require("ace/mode/text").Mode
      @JavascriptMode = require("ace/mode/javascript").Mode
      @CoffeescriptMode = require("ace/mode/coffee").Mode
      @CsharpMode = require("ace/mode/csharp").Mode
      @CMode = require("ace/mode/c_cpp").Mode
      @HtmlMode = require("ace/mode/html").Mode
      @PythonMode = require("ace/mode/python").Mode
      @RubyMode = require("ace/mode/ruby").Mode

      @ModeMap = {
        text: @TextileMode,
        javascript: @JavascriptMode,
        coffeescript: @CoffeescriptMode,
        csharp: @CsharpMode,
        c: @CMode,
        html: @HtmlMode,
        python: @PythonMode,
        ruby: @RubyMode
      }

      $('#mode_panel .button').click ->
        mode_name = $(this).text()
        $('.button').removeClass("positive")
        $('#' + mode_name + '_button').addClass("positive")
        set_mode(mode_name)

      $('.button').removeClass("positive")
      $('#text_button').addClass("positive")

      @editor.getSession().setMode(new @TextileMode())
      # bug in ace prevents this from working well.
      # @editor.getSession().setUseWrapMode(true)

      $("#editor").data("editor_hook", @editor)
      $("#editor").data("update_hook", update_ace_document)

      code = $('#collab_code').text()
      console.log "[ZAPPATEST] code: #{code}"
      emit 'join_room', code: code
      periodical_update @editor, code

  # main page layout
  view collab: ->
    div id: 'collab_info', ->
      span id: 'collab_code', ->
        text @code

    div id: 'mode_panel', class: 'header', ->
      for current_mode in @ace_modes
        partial 'mode_partial', mode: current_mode

    div id: 'editor', class: 'editor', ->
      for line in @lines[0...@lines.length-1]
        if line?
          text line + '''\r\n'''
      text @lines[@lines.length-1]

    # include page specific javascript, including the ace js files.
    script src: '/javascripts/ace/ace-uncompressed.js'
    script src: '/javascripts/ace/theme-twilight.js'

    for mode in @ace_modes
      if mode.src?
        script src: '/javascripts/ace/' + mode.src

    script src: '/collab.js'

  # define the partial used to render the button to toggle ace language mode.
  view mode_partial: ->
    button class: 'button', id: @mode.name + '_button',  ->
      @mode.name

