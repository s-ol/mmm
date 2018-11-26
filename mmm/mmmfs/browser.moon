require = relative ..., 1
import Key from require '.fileder'
import converts, get_conversions, apply_conversions from require '.conversion'
import ReactiveVar, get_or_create, text, elements from require 'mmm.component'
import pre, div, nav, span, button, a, select, option from elements
import languages from require 'mmm.highlighting'

code_cast = (lang) ->
  {
    inp: "text/#{lang}.*",
    out: 'mmm/dom',
    transform: (val) -> languages[lang] val
  }

casts = {
  code_cast 'javascript',
  code_cast 'moonscript',
  code_cast 'lua',
  code_cast 'markdown',
  code_cast 'html',
}

for convert in *converts
  table.insert casts, convert

class Browser
  new: (@root, path='', rehydrate=false) =>
    -- root fileder
    assert @root, 'root fileder is nil'

    -- active path
    @path = ReactiveVar path

    -- update URL bar
    if MODE == 'CLIENT'
      logo = document\querySelector 'header > h1 > svg'
      spin = ->
        logo.classList\add 'spin'
        logo.parentElement.offsetWidth
        logo.classList\remove 'spin'
      @path\subscribe (path) ->
        document.body.classList\add 'loading'
        spin!

        return if @skip
        vis_path = path .. (if '/' == path\sub -1 then '' else '/')
        window.history\pushState path, '', vis_path

      window.onpopstate = (_, event) ->
        if event.state
          @skip = true
          @path\set event.state
          @skip = nil

    -- active fileder
    -- (re)set every time @path changes
    @active = @path\map @root\walk

    -- currently active facet
    -- (re)set to default when @active changes
    @facet = @active\map (fileder) ->
      return unless fileder
      last = @facet and @facet\get!
      Key if last then last.type else 'mmm/dom'

    -- whether inspect tab is active
    @inspect = ReactiveVar (MODE == 'CLIENT' and window.location.search\match '[?&]inspect')

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
            a name, :href, onclick: (_, e) ->
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
        \append @active\map (fileder) ->
            onchange = (_, e) ->
              { :type } = @facet\get!
              @facet\set Key name: e.target.value, :type

            current = @facet\get!
            current = current and current.name
            with select :onchange, disabled: not fileder
              has_main = fileder and fileder\find current.name, '.*'
              \append option '(main)', value: '', disabled: not has_main, selected: current == ''
              if fileder
                for i, value in ipairs fileder\get_facets!
                  continue if value == ''
                  \append option value, :value, selected: value == current
        \append @inspect\map (enabled) ->
          if not enabled
            button 'inspect', onclick: (_, e) -> @inspect\set true

    -- append or patch #browser-content
    main\append with get_or_create 'div', 'browser-content', class: 'content'
      content = ReactiveVar @get_content @facet\get!
      if MODE == 'CLIENT'
        @facet\subscribe (p) ->
          window\setTimeout (-> content\set @get_content p), 150
      \append content, (rehydrate and .node.lastChild)

    if rehydrate
      -- force one rerender to set onclick handlers etc
      @facet\set @facet\get!

    inspector = @inspect\map (enabled) -> if enabled then @get_inspector!

    -- export mmm/component interface
    wrapper = get_or_create 'div', 'browser-wrapper', main, inspector, class: 'browser'
    @node = wrapper.node
    @render = wrapper\render

  err_and_trace = (err) -> err, debug.traceback!
  default_convert = (key) => @get key.name, 'mmm/dom'

  -- render #browser-content
  get_content: (prop, convert=default_convert) =>
    disp_error = (msg) -> pre msg, style: { color: '#f00' }
    active = @active\get!

    return disp_error "fileder not found!" unless active
    return disp_error "facet not found!" unless prop

    ok, res, trace = xpcall convert, err_and_trace, active, prop

    document.body.classList\remove 'loading' if MODE == 'CLIENT'

    if ok
      res or disp_error "[no conversion path to #{prop.type}]"
    elseif res and res.match and res\match '%[nossr%]$'
      warn '(SSR disabled)'
      div!
    else
      warn "error: #{res}", trace
      disp_error "error: #{res}\n#{trace}"

  get_inspector: =>
    -- active facet in inspect tab
    -- (re)set to match when @facet changes
    @inspect_prop = @facet\map (prop) ->
      active = @active\get!
      key = active and active\find prop
      key = key.original if key and key.original
      key

    with div class: 'view inspector'
      \append nav {
        span 'inspector'
        @inspect_prop\map (current) ->
          current = current and current\tostring!
          fileder = @active\get!

          onchange = (_, e) ->
            return if e.target.value == ''
            { :name } = @facet\get!
            @inspect_prop\set Key e.target.value

          with select :onchange
            \append option '(none)', value: '', disabled: true, selected: not value
            if fileder
              for key, _ in pairs fileder.facets
                value = key\tostring!
                \append option value, :value, selected: value == current
        @inspect\map (enabled) ->
          if enabled
            button 'close', onclick: (_, e) -> @inspect\set false
      }
      \append with pre class: 'content'
        \append @inspect_prop\map (prop) ->
          @get_content prop, (prop) =>
            value, key = @get prop

            conversions = get_conversions 'mmm/dom', key.type, casts
            assert conversions, "cannot cast '#{key.type}'"
            apply_conversions conversions, value, @, prop

  default_convert = (key) => @get key.name, 'mmm/dom'

  navigate: (new) =>
    @path\set new

{
  :Browser
}
