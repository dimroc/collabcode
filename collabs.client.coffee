@include = ->
  enable 'server jquery'
  logger = require('log4js').getLogger()
  client '/collab.js': ->
    connect()

    at 'current users update': ->
      logger.debug "updating current users list:"
      logger.debug @users
      _GLOBAL.users = @users
      $("#user_list").empty()
      for user in @users
        $("#user_list").append("<li>#{user}</li>")

    # TODO: Consolidate the bottom two functions.
    at 'editing locked': ->
      logger.debug "user <#{@locker}> locked the file for editing"
      $("#current_editor").empty()
      $("#current_editor").append("Current user: #{@locker}")

    at 'editing locked for me': ->
      logger.debug "user <#{@locker}> locked the file for editing"
      $("#current_editor").empty()
      $("#current_editor").append("Current user: #{@locker}")

      editor = $("#editor").data("editor_hook")
      startfunc = $("#editor").data("start_editing_hook")
      startfunc editor

    at 'release lock': ->
      logger.debug 'release lock'
      $("#current_editor").empty()
      editor = $("#editor").data("editor_hook")
      stopfunc = $("#editor").data("stop_editing_hook")
      stopfunc editor

    at 'collab updated': ->
      logger.debug 'received updated doc for code ' + @code
      mycode = $('#collab_code').text()
      if mycode == @code
        updatefunc = $("#editor").data("update_hook")
        updatefunc @lines
      else
        logger.debug '[ERROR] received information about the wrong code!'

    _GLOBAL = {
      isLocked: false
    }

    # Attach main properties to _GLOBAL
    if window?
      _GLOBAL.view = this
      window._GLOBAL = _GLOBAL
    else
      logger.debug "[ERROR] Couldn't attach _GLOBAL to window."

    stop_editing = (editor) ->
      logger.debug 'disabling editor'
      editor.setReadOnly(true)
      editor.setTheme("ace/theme/dawn")
      $("#lock_description").addClass("notice")
      $("#lock_description").removeClass("alert")
      $("#lock_icon").attr("src", "/images/open_lock.jpg")
      $("#lock_span").text("lock")
      window._GLOBAL.isLocked = false

    start_editing = (editor) ->
      logger.debug 'enabling editor'
      editor.setReadOnly(false)
      editor.setTheme("ace/theme/twilight")
      $("#lock_description").addClass("alert")
      $("#lock_description").removeClass("notice")
      $("#lock_icon").attr("src", "/images/closed_lock.png")
      $("#lock_span").text("unlock")
      window._GLOBAL.isLocked = true

    set_mode = (mode) =>
      logger.debug 'setting mode to ' + JSON.stringify(mode)
      @editor.getSession().setMode(new @ModeMap[mode])

    update_ace_document = (lines) =>
      editor = $("#editor").data("editor_hook")
      document = editor.getSession().getDocument()
      if document?
        if document.getLength() > 0
          logger.debug "remove #{document.getLength()} lines from doc"
          document.removeLines(0, document.getLength())
        document.insertLines(0, lines)

    periodical_update = (editor, code) =>
      setInterval ->
        if window._GLOBAL.isLocked
          logger.debug 'triggering periodical update push'
          lines = editor.getSession().getDocument().getAllLines()
          emit 'collab updated handler', code: code, lines: lines
      , 5000

    dispatch_toggle_lock_request = ->
      logger.debug 'toggling lock'
      emit 'toggle lock handler'

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

      $("#editor").data("editor_hook", @editor)
      $("#editor").data("update_hook", update_ace_document)
      $("#editor").data("stop_editing_hook", stop_editing)
      $("#editor").data("start_editing_hook", start_editing)
      $("#editor").attr("disabled", "disabled")

      window._GLOBAL.code = code
      window._GLOBAL.editor = @editor
      window._GLOBAL.username = prompt "Please enter a username."
      window._GLOBAL.users = [window._GLOBAL.username,]
      window._GLOBAL.dispatch_toggle_lock_request = dispatch_toggle_lock_request 

      logger.debug "attempting to join room with code #{code}"
      emit 'join_room_handler', username: window._GLOBAL.username, code: code

      periodical_update @editor, code


