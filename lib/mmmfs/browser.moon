require = relative ..., 1
import Key from require '.fileder'
import get_conversions from require '.conversion'
import ReactiveVar, ReactiveElement, text, elements from require 'lib.component'
import div, span, a, select, option from elements

limit = (list, num) -> [v for i,v in ipairs list when i <= num]

path2tbl = (path) ->
  switch type path
    when 'string'
      path
    when 'table'
      str = table.concat path, '/'
      if '/' != str\sub 1, 1
        str = '/' .. str
      str
    else
      error "path is of wrong type: #{type path}"

class Browser
  new: (@root, path={}, rehydrate=false) =>
    @path = ReactiveVar path2tbl path

    assert @root, 'root fileder is nil'

    @path\subscribe (path) ->
      path ..= '/' unless path\match '/$'
      window.history\pushState nil, '', path

    @active = @path\map @root\walk

    @prop = @active\map (fileder) ->
      return unless fileder
      (fileder\find 'mmm/dom') or next fileder.props

    -- retrieve or create the root
    root = 'div'
    root = document\getElementById 'browser-root' if rehydrate
    @dom = ReactiveElement root, {
      id: 'browser-root'
      style: {
        position: 'absolute',
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        display: 'flex',
        overflow: 'hidden',
        'flex-direction': 'column',
        'justify-content': 'space-between',
      }
    }

    -- add or prepend the navbar
    if MODE == 'CLIENT'
      @dom\prepend div {
        style: {
          padding: '1em',
          flex: '0 0 auto',
          display: 'flex',
          'justify-content': 'space-between',
          background: '#eeeeee',
        },
        span 'path: ', @path\map (path) -> with div style: { display: 'inline-block' }
          path_segment = (name, href) ->
            a name, :href, onclick: (_, e) ->
              e\preventDefault!
              @navigate href

          path = path\match '^/(.*)'
          href = ''

          \append path_segment 'root', '/'

          while path
            name, rest = path\match '^(%w+)/(.*)' -- or rest
            if not name
              name = path

            path = rest
            href = "#{href}/#{name}"

            \append '/'
            \append path_segment name, href

        span 'view property: ', @active\map (fileder) ->
          onchange = (_, e) ->
            @prop\set Key e.target.value

          current = @prop\get!
          current = current and current\tostring!
          with select :onchange, disabled: not fileder
            if fileder
              for key, _ in pairs fileder.props
                value = key\tostring!
                \append option value, :value, selected: value == current
      }

    -- append or patch #browser-content
    node = 'div'
    node = document\getElementById 'browser-content' if rehydrate
    @dom\append with ReactiveElement node, {
        id: 'browser-content',
        style: {
          flex: '1 0 0',
          overflow: 'auto',
          padding: '1em 2em',
        },
      }
      \append @get_content rehydrate and node

    if rehydrate
      -- force one update to update onclick handlers etc
      @prop\set @prop\get!

    @node = @dom.node
    @render = @dom\render

  get_content: (wrapper) =>
    disp_error = (msg) -> span msg, style: { color: '#f00' }
    var = @prop\map (prop) ->
      active = @active\get!

      if not active
        return disp_error "fileder not found!"

      if not prop
        return disp_error "property not found!"

      convert = ->
        conversions = get_conversions 'mmm/dom', prop.type
        value = assert (active\get prop), "value went missing?"

        return unless conversions

        for i=#conversions,1,-1
          { :inp, :out, :transform } = conversions[i]
          value = transform value, active

        value

      ok, res = if MODE == 'CLIENT'
        pcall convert
      else
        true, convert!

      if ok
        res or disp_error "[no conversion path to mmm/dom]"
      else
        warn "error: ", res unless ok
        disp_error "[unknown error displaying]"

    -- wrapper was built already so take over the old value
    if wrapper
      return var, wrapper.lastChild -- var\set wrapper.lastElementChild

    var

  navigate: (new) => @path\set path2tbl new

{
  :Browser,
}
