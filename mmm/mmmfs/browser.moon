require = relative ..., 1
import Key from require '.fileder'
import converts, get_conversions, apply_conversions from require '.conversion'
import ReactiveVar, get_or_create, text, elements from require 'mmm.component'
import pre, code, div, nav, span, button, a, select, option from elements

code_cast = (lang) -> {
    inp: "text/#{lang}.*",
    out: 'mmm/dom',
    transform: (val) -> pre code val
  }

casts = {
  code_cast 'moonscript',
  code_cast 'lua',
  code_cast 'markdown',
  code_cast 'html',
}

for convert in *converts
  table.insert casts, convert

class Browser
  new: (@root, path='/', rehydrate=false) =>
    -- root fileder
    assert @root, 'root fileder is nil'

    -- active path
    @path = ReactiveVar path

    -- update URL bar
    if MODE == 'CLIENT'
      @path\subscribe (path) ->
        path ..= '/' unless '/' == path\sub -1
        window.history\pushState nil, '', path

    -- active fileder
    -- (re)set every time @path changes
    @active = @path\map @root\walk

    -- currently active property
    -- (re)set to default when @active changes
    @prop = @active\map (fileder) ->
      return unless fileder
      last = @prop and @prop\get!
      -- (fileder\find 'mmm/dom') or next fileder.props
      Key if last then last.type else 'mmm/dom'

    -- whether inspect tab is active
    @inspect = ReactiveVar false

    -- retrieve or create the wrapper and main elements
    main = get_or_create 'div', 'browser-root', class: 'main view'

    -- prepend the navbar
    if MODE == 'SERVER'
      main\append nav { id: 'browser-navbar', span 'please stand by... interactivity loading :)' }
    else
      main\prepend with get_or_create 'nav', 'browser-navbar'
        .node.innerHTML = ''
        \append span 'path: ', @path\map (path) -> with div style: { display: 'inline-block' }
          path_segment = (name, href) ->
            a name, :href, onclick: (_, e) ->
              e\preventDefault!
              @navigate href

          href = ''
          path = path\match '^/(.*)'

          \append path_segment 'root', '/'

          while path
            name, rest = path\match '^(%w+)/(.*)'
            if not name
              name = path

            path = rest
            href = "#{href}/#{name}"

            \append '/'
            \append path_segment name, href

        \append span 'view property:', style: { 'margin-right': '0' }
        \append @active\map (fileder) ->
            onchange = (_, e) ->
              { :type } = @prop\get!
              @prop\set Key name: e.target.value, :type

            current = @prop\get!
            current = current and current.name
            with select :onchange, disabled: not fileder
              if fileder
                for i, value in ipairs fileder\get_prop_names!
                  label = if value == '' then '(main)' else value
                  \append option label, :value, selected: value == current
        \append @inspect\map (enabled) ->
          if not enabled
            button 'inspect', onclick: (_, e) -> @inspect\set true

    -- append or patch #browser-content
    main\append with get_or_create 'div', 'browser-content', class: 'content'
      \append (@prop\map (p) -> @get_content p), (rehydrate and .node.lastChild)

    if rehydrate
      -- force one rerender to set onclick handlers etc
      @prop\set @prop\get!

    inspector = @inspect\map (enabled) -> if enabled then @get_inspector!

    -- export mmm/component interface
    wrapper = get_or_create 'div', 'browser-wrapper', main, inspector, class: 'browser'
    @node = wrapper.node
    @render = wrapper\render

  err_and_trace = (err) -> err, debug.traceback!
  default_convert = (key) => @get key.name, 'mmm/dom'

  -- render #browser-content
  get_content: (prop, convert=default_convert) =>
    disp_error = (msg) -> span msg, style: { color: '#f00' }
    active = @active\get!

    return disp_error "fileder not found!" unless active
    return disp_error "property not found!" unless prop

    ok, res, trace = xpcall convert, err_and_trace, active, prop

    if ok
      res or disp_error "[no conversion path to #{prop.type}]"
    elseif res\match '%[nossr%]$'
      warn '(SSR disabled)'
      div!
    else
      warn "error: #{res}", trace
      disp_error "error: #{res}"

  get_inspector: =>
    -- active property in inspect tab
    -- (re)set to match when @prop changes
    @inspect_prop = @prop\map (prop) ->
      active = @active\get!
      key = active\find prop
      key = key.original if key and key.original
      key

    with div class: 'view inspector'
      \append nav {
        span 'inspector'
        @inspect_prop\map (current) ->
          current = current and current\tostring!
          fileder = @active\get!

          onchange = (_, e) ->
            { :name } = @prop\get!
            @inspect_prop\set Key e.target.value

          with select :onchange
            if fileder
              for key, _ in pairs fileder.props
                value = key\tostring!
                \append option value, :value, selected: value == current
        @inspect\map (enabled) ->
          if enabled
            button 'close', onclick: (_, e) -> @inspect\set false
      }
      \append with div class: 'content'
        \append @inspect_prop\map (prop) ->
          @get_content prop, (prop) =>
            value, key = @get prop

            conversions = get_conversions 'mmm/dom', key.type, casts
            assert conversions, "cannot cast '#{key.type}'"
            apply_conversions conversions, value, @, prop

  default_convert = (key) => @get key.name, 'mmm/dom'

  navigate: (new) => @path\set new

{
  :Browser
}