@include = ->
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
