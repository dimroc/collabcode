@include = ->
  get '/collab/:id': ->
    console.log "[TRACE] retrieve id #{@id}"

    @src_prefix = '/javascripts/ace/'
    @modes = [
      {name: 'text'}
      {name: 'javascript', src: 'mode-javascript.js'} 
      {name: 'coffeescript', src: 'mode-coffee.js'} 
      {name: 'csharp', src: 'mode-csharp.js'} 
      {name: 'c', src: 'mode-c_cpp.js'} 
      {name: 'html', src: 'mode-html.js'} 
      {name: 'python', src: 'mode-python.js'} 
      {name: 'ruby', src: 'mode-ruby.js'} 
    ]

    render 'collab', {@modes, @src_prefix}

  client '/collab.js': ->
    set_mode = (mode) =>
      console.log 'setting mode to ' + JSON.stringify(mode)
      @editor.getSession().setMode(new @ModeMap[mode])

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

  # main page layout
  view collab: ->
    div id: 'mode_panel', class: 'header', ->
      for current_mode in @modes
        partial 'mode_partial', mode: current_mode

    div id: 'editor', class: 'editor', ->
      'cout << "hello world"'

    # include page specific javascript, including the ace js files.
    script src: '/javascripts/ace/ace.js'
    script src: '/javascripts/ace/theme-twilight.js'

    for mode in @modes
      if mode.src?
        script src: @src_prefix + mode.src

    script src: '/collab.js'

  # define the partial used to render the button to toggle ace language mode.
  view mode_partial: ->
    button class: 'button', id: @mode.name + '_button',  ->
      @mode.name

