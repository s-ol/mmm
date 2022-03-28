import Key from require 'mmm.mmmfs.fileder'
import converts from require 'mmm.mmmfs.builtins'
import get_conversions, apply_conversions from require 'mmm.mmmfs.conversion'
import ReactiveVar, get_or_create, text, elements, tohtml from require 'mmm.component'
import pre, div, nav, span, button, a, code, select, option from elements
import link_to from (require 'mmm.mmmfs.util') elements
import languages from require 'mmm.highlighting'

keep = (var) ->
  last = var\get!
  var\map (val) ->
    last = val or last
    last

combine = (...) ->
  res = {}
  lists = {...}
  for list in *lists
    for val in *list
      table.insert res, val

  res

casts = {
  {
    inp: 'URL.*'
    out: 'mmm/dom'
    cost: 0
    transform: (href) => span a (code href), :href
  }
}
get_casts = -> combine casts, converts

export BROWSER
class Browser
  new: (@root, path, facet, rehydrate=false) =>
    BROWSER = @

    -- root fileder
    assert @root, 'root fileder is nil'

    -- active path
    @path = ReactiveVar path or ''

    -- active fileder
    -- (re)set every time @path changes
    @fileder = @path\map @root\walk

    -- currently active facet
    -- (re)set to default when @fileder changes
    @facet = ReactiveVar Key facet, 'mmm/dom'
    if MODE == 'CLIENT'
      @fileder\subscribe (fileder) ->
        return unless fileder
        last = @facet and @facet\get!
        @facet\set Key if last then last.type else 'mmm/dom'

    -- update URL bar
    if MODE == 'CLIENT'
      logo = document\querySelector 'header h1 > a > svg'
      spin = ->
        logo.classList\add 'spin'
        logo.parentElement.offsetWidth
        logo.classList\remove 'spin'

      @facet\subscribe (facet) ->
        document.body.classList\add 'loading'
        spin!

        return if @skip

        path = @path\get!
        state = js.global\eval 'new Object()'
        state.path = path
        state.name = facet.name
        state.type = facet.type

        window.history\pushState state, '', "#{path}/#{(Key facet.name, 'text/html+interactive')\tostring true}"

      window.onpopstate = (_, event) ->
        state = event.state
        if state != js.null
          @skip = true
          @path\set state.path
          @facet\set Key state.name, state.type
          @skip = nil

    -- whether inspect tab is active
    @inspect = ReactiveVar (MODE == 'CLIENT' and window.location.hash == '#inspect')

    -- retrieve or create the wrapper and main elements
    main = get_or_create 'div', 'browser-root', class: 'main view'

    -- prepend the navbar
    if MODE == 'SERVER'
      main\append nav { id: 'browser-navbar', span 'please stand by... interactivity loading :)' }
    else
      main\prepend with get_or_create 'nav', 'browser-navbar'
        .node.innerHTML = ''
        \append span 'path: ', @path\map (path) -> with div class: 'path', style: { display: 'inline-block' }
          path_segment = (name, href) ->
            a name, href: "#{href}/", onclick: (_, e) ->
              e\preventDefault!
              @navigate href

          href = ''
          path = path\match '^/(.*)'

          \append path_segment 'root', ''

          while path
            name, rest = path\match '^([%w%-_%.]+)/(.*)'
            if not name
              name = path

            path = rest
            href = "#{href}/#{name}"

            \append '/'
            \append path_segment name, href

        \append span 'view facet:', style: { 'margin-right': '0' }
        \append @fileder\map (fileder) ->
          onchange = (_, e) ->
            { :type } = @facet\get!
            @facet\set Key name: e.target.value, :type

          current = @facet\get!
          current = current and current.name
          with elements.select :onchange, disabled: not fileder, value: @facet\map (f) -> f and f.name
            has_main = fileder and fileder\has_facet ''
            \append option '(main)', value: '', disabled: not has_main, selected: current == ''
            if fileder
              for i, value in ipairs fileder\get_facets!
                continue if value == ''
                \append option value, :value, selected: value == current
        \append @inspect\map (enabled) ->
          if not enabled
            button 'inspect', onclick: (_, e) -> @inspect\set true

    @error = ReactiveVar!
    main\append with get_or_create 'div', 'browser-error', class: @error\map (e) -> if e then 'error-wrap' else 'error-wrap empty'
      \append (span "an error occured while rendering this view:"), (rehydrate and .node.firstChild)
      \append @error

    -- append or patch #browser-content
    main\append with get_or_create 'div', 'browser-content', class: 'content'
      @content = ReactiveVar if rehydrate then .node.lastChild else @get_content @facet\get!
      \append keep @content
      if MODE == 'CLIENT'
        @facet\subscribe (p) ->
          window\setTimeout (-> @refresh p), 150

    if rehydrate
      -- force one rerender to set onclick handlers etc
      @facet\set @facet\get!

    inspector = @inspect\map (enabled) -> if enabled then @get_inspector!

    -- export mmm/component interface
    wrapper = get_or_create 'div', 'browser-wrapper', main, inspector, class: 'browser'
    @node = wrapper.node
    @render = wrapper\render

  err_and_trace = (msg) -> debug.traceback msg, 2
  default_convert = (key) => @get key.name, 'mmm/dom'

  -- rerender main content
  refresh: (facet=@facet\get!) =>
    if facet == true -- deep refresh
      @fileder\transform (i) -> i
    else
      @content\set @get_content facet

  -- render #browser-content
  get_content: (prop, err=@error, convert=default_convert) =>
    clear_error = ->
      err\set! if MODE == 'CLIENT'
    disp_error = (msg) ->
      if MODE == 'CLIENT'
        err\set pre msg
      warn "ERROR rendering content: #{msg}"
      div!

    active = @fileder\get!

    return disp_error "fileder not found!" unless active
    return disp_error "facet not found!" unless prop

    ok, res = xpcall convert, err_and_trace, active, prop

    document.body.classList\remove 'loading' if MODE == 'CLIENT'

    if ok and res
      clear_error!
      res
    elseif ok
      div "[no conversion path to #{prop.type}]"
    elseif res and res\match '%[nossr%]'
      div "[this page could not be pre-rendered on the server]"
    else
      disp_error res

  get_inspector: =>
    -- active facet in inspect tab
    -- (re)set to match when @facet changes
    @inspect_prop = @facet\map (prop) ->
      active = @fileder\get!
      key = active and active\find prop
      key = key.original if key and key.original
      key

    @inspect_err = ReactiveVar!

    with div class: 'view inspector'
      -- nav
      \append nav {
        span 'inspector'

        button 'close', onclick: (_, e) -> @inspect\set false
      }

      \append div {
        class: 'subnav'

        @inspect_prop\map (current) ->
          current = current and current\tostring!
          fileder = @fileder\get!

          onchange = (_, e) ->
            facet = e.target.value
            return if facet == ''
            @inspect_prop\set Key facet

          with select :onchange
            \append option '(none)', value: '', disabled: true, selected: not value
            if fileder
              for value in pairs fileder.facet_keys
                \append option value, :value, selected: value == current

        div style: flex: '1'
      }

      -- error / content
      \append with div class: @inspect_err\map (e) -> if e then 'error-wrap' else 'error-wrap empty'
        \append span "an error occured while rendering this view:"
        \append @inspect_err
      \append with pre class: 'content'
        \append keep @inspect_prop\map (prop, old) ->
          @get_content prop, @inspect_err, (fileder, facet) ->
            value, key = fileder\get facet
            assert key, "couldn't @get #{facet}"

            conversions = get_conversions fileder, 'mmm/dom', key.type, get_casts!
            assert conversions, "cannot cast '#{key.type}'"
            apply_conversions fileder, conversions, value, facet

      -- children
      \append nav {
        class: 'thing'

        span 'children'
        button 'add', onclick: (_, e) ->
          name = window\prompt "please enter the name of the child fileder:", 'unnamed_fileder'
          return if not name or name == '' or name == js.null
          child = @fileder\get!\add_child name
          @refresh true
      }
      \append @fileder\map (fileder) ->
        with div class: 'children'
          num = #fileder.children
          for i, child in ipairs fileder.children
            name = child\gett 'name: alpha'
            \append div {
              style:
                display: 'flex'
                'justify-content': 'space-between'

              span '- ', (link_to child, code name), style: flex: 1
            }


  default_convert = (key) => @get key.name, 'mmm/dom'

  navigate: (new) =>
    @path\set new

  todom: => tohtml @

{
  :Browser
}
