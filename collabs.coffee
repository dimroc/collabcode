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

  client '/collab.js': ->
    connect()

    at 'test_hook': ->
      console.log "HOOK"

    at 'bullshit': ->
      console.log "bullshit"

#    at 'lock_editor': ->
#      console.log 'locking editor'
#      editor = $("#editor").data("editor_hook")
#      stopfunc = $("#editor").data("stop_editing_hook")
#      stopfunc editor
#
#    at 'editing_granted': ->
#      console.log 'received socket.io request to enable editor'
#      editor = $("#editor").data("editor_hook")
#      startfunc = $("#editor").data("start_editing_hook")
#      startfunc editor
#
#    at collab_updated: ->
#     console.log 'received updated doc for code ' + @code
#      mycode = $('#collab_code').text()
#      if mycode == @code
#        updatefunc = $("#editor").data("update_hook")
#        updatefunc @lines
#      else
#        console.log '[ERROR] received information about the wrong code!'

    _GLOBAL = {
      isLocked: false
    }

    # Attach main properties to _GLOBAL
    if window?
      window._GLOBAL = _GLOBAL
    else
      console.log "[ERROR] Couldn't attach _GLOBAL to window."

    stop_editing = (editor) =>
      $("#editor").attr("disabled", "disabled")
      $("#editor").removeAttr("disabled")
      $("#lock").attr("src", "/images/closed_lock.png")

    start_editing = (editor) =>
      console.log 'enabling editor'
      $("#lock").attr("src", "/images/open_lock.jpg")

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

    periodical_update = (editor, code) =>
      setInterval ->
        if window._GLOBAL.isLocked
          console.log 'triggering periodical update'
          lines = editor.getSession().getDocument().getAllLines()
          emit 'collab_update', code: code, lines: lines
      , 5000

    $().ready =>
      code = $('#collab_code').text()

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
      #
      $("#lock").click(->
        if !@isLocked
          console.log 'requesting lock'
        else
          console.log 'release lock'
      )

      $("#editor").data("editor_hook", @editor)
      $("#editor").data("update_hook", update_ace_document)
      $("#editor").data("stop_editing_hook", stop_editing)
      $("#editor").data("start_editing_hook", start_editing)
      $("#editor").attr("disabled", "disabled")

      window._GLOBAL.code = code
      window._GLOBAL.editor = @editor
      window._GLOBAL.nickname = prompt "Please enter a nickname."

      periodical_update @editor, code

  # main page layout
  view collab: ->

    div class: 'container', ->
      div id: 'info_panel', class: 'span-24 header', ->
        div id: 'lock_info', ->
          h3 'Current Editor:'
          div ->
            span id: 'collab_code', ->
              text "#{@code}"
            br()
            span id: 'current_editor', ->
              text "bogus user"
          img id: 'lock', src: "/images/closed_lock.png", width: "50px"

        div style: '''float: left''', ->
          #h4 'Description:'
          div id: 'lock_description', class: 'alt', ->
            text 'Click to toggle the lock'
            br()
            text 'an open lock for you is a closed lock for everyone else'

        div id: 'user_panel', ->
          h3 'Viewers:'
          ol ->
            li 'some user1'
            li 'some user1'
            li 'some user1'
            li 'some user1'

      div id: 'content', class: 'span-24', ->
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

