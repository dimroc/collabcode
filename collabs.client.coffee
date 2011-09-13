@include = ->
  client '/collab.js': ->
    connect()

    at 'test_hook': ->
      console.log "HOOK"

    at 'user_joined': ->
      console.log "new user <#{@newuser}> joined the room"
      _GLOBAL.users += @newuser
      console.log JSON.stringify _GLOBAL.users
      # _GLOBAL.users.each { |u| console.log u }

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
      _GLOBAL.view = this
      window._GLOBAL = _GLOBAL
    else
      console.log "[ERROR] Couldn't attach _GLOBAL to window."

    stop_editing = (editor) ->
      console.log 'disabling editor'
      editor.setReadOnly(true)
      editor.setTheme("ace/theme/dawn")
      $("#lock_description").addClass("notice")
      $("#lock_description").removeClass("alert")
      $("#lock").attr("src", "/images/closed_lock.png")

    start_editing = (editor) ->
      console.log 'enabling editor'
      editor.setReadOnly(true)
      editor.setTheme("ace/theme/dawn")
      $("#lock_description").addClass("alert")
      $("#lock_description").removeClass("notice")
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
      stop_editing @editor

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
      window._GLOBAL.username = prompt "Please enter a username."
      window._GLOBAL.users = [window._GLOBAL.username,]

      console.log "attempting to join room with code #{code}"
      emit 'join_room_handler', username: window._GLOBAL.username, code: code

      periodical_update @editor, code


