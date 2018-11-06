require = relative ..., 1
import Key from require '.fileder'
import get_conversions from require '.conversion'
import ReactiveVar, get_or_create, text, elements from require 'mmm.component'
import div, span, a, select, option from elements

class Browser
  new: (@root, path='/', rehydrate=false) =>
    -- root fileder
    assert @root, 'root fileder is nil'

    -- active path
    @path = ReactiveVar path

    if MODE == 'CLIENT'
      -- update URL bar
      @path\subscribe (path) ->
        path ..= '/' unless path\match '/$'
        window.history\pushState nil, '', path

    -- active fileder
    -- (re)set every time @path changes
    @active = @path\map @root\walk

    -- currently active property
    -- (re)set to default every time @active changes
    @prop = @active\map (fileder) ->
      return unless fileder
      last = @prop and @prop\get!
      -- (fileder\find 'mmm/dom') or next fileder.props
      Key if last then last.type else 'mmm/dom'

    -- retrieve or create the root
    @dom = get_or_create 'div', 'browser-root'

    -- prepend the navbar
    if MODE == 'SERVER'
      @dom\append div 'please stand by... interactivity loading :)', id: 'browser-navbar'
    else
      @dom\prepend with get_or_create 'div', 'browser-navbar'
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

        \append span {
          'view property: ',
          @active\map (fileder) ->
            onchange = (_, e) ->
              { :type } = @prop\get!
              @prop\set Key name: e.target.value, :type

            current = @prop\get!
            current = current and current.name
            with select :onchange, disabled: not fileder
              if fileder
                for key, _ in pairs {k,k for k in pairs fileder.props}
                  value = key.name
                  label = if value == '' then '(main)' else value
                  \append option label, :value, selected: value == current

          ' as ',
          @active\map (fileder) ->
            onchange = (_, e) ->
              { :name } = @prop\get!
              @prop\set Key :name, type: e.target.value

            current = @prop\get!
            curent = current and current.type
            with select :onchange
              opt = (value) -> option value, :value, selected: value == current
              \append opt 'mmm/dom'
              \append opt 'text/plain'
              -- if fileder
              --   for key, _ in pairs fileder.props
              --     value = key.type
              --     \append option value, :value, selected: value == current
        }

    -- append or patch #browser-content
    @dom\append with get_or_create 'div', 'browser-content'
      \append @get_content!, (rehydrate and .node.lastChild)

    if rehydrate
      -- force one rerender to set onclick handlers etc
      @prop\set @prop\get!

    -- export mmm/component interface
    @node = @dom.node
    @render = @dom\render

  -- render #browser-content
  get_content: () =>
    disp_error = (msg) -> span msg, style: { color: '#f00' }
    @prop\map (prop) ->
      active = @active\get!

      return disp_error "fileder not found!" unless active
      return disp_error "property not found!" unless prop

      convert = ->
        value = active\get prop

        return unless value

        conversions = get_conversions 'mmm/dom', prop.type

        for i=#conversions,1,-1
          { :inp, :out, :transform } = conversions[i]
          value = transform value, active

        value

      ok, res = if MODE == 'CLIENT'
        pcall convert
      else
        true, convert!

      if ok
        res or disp_error "[no conversion path to #{prop.type}]"
      else
        warn "error: ", res unless ok
        disp_error "[unknown error displaying]"

  navigate: (new) => @path\set new

{
  :Browser
}
