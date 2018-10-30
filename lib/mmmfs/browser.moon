require = relative ..., 1
import Key from require '.fileder'
import get_conversions from require '.conversion'
import ReactiveVar, text, elements from require 'lib.component'
import div, span, a, select, option from elements

limit = (list, num) -> [v for i,v in ipairs list when i <= num]

class Browser
  new: (@root) =>
    @path = ReactiveVar {}
    @path\subscribe (path) -> window.location.hash = '/' .. table.concat path, '/'
    @prop = ReactiveVar (@root\find 'mmm/dom') or next @root.props
    @active = @path\map (path) ->
      fileder = @root
      for name in *path
        local next
        for child in *fileder.children
          if name == child\get 'name', 'alpha'
            next = child
            break

        if not next
          return

        fileder = next

      fileder

    @active\subscribe (fileder) -> @prop\set (fileder\find 'mmm/dom') or next fileder.props

    @tree = div {
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
      },
      div {
        style: {
          padding: '1em',
          flex: '0 0 auto',
          display: 'flex',
          'justify-content': 'space-between',
          background: '#eeeeee',
        },
        span 'path: ', @path\map (path) -> with div style: { display: 'inline-block' }
          \append a 'root', href: '#', onclick: (_, e) ->
            e\preventDefault!
            @navigate {}

          for i,name in ipairs path
            \append '/'
            \append a name, href: '#', onclick: (_, e) ->
              e\preventDefault!
              @navigate limit path, i

        span 'view property: ', @active\map (fileder) ->
          onchange = (_, e) ->
            @prop\set Key e.target.value

          with select :onchange
            if fileder
              for key, _ in pairs fileder.props
                value = key\tostring!
                \append option value, :value
      }

      div {
        style: {
          flex: '1 0 0',
          overflow: 'auto',
          padding: '1em 2em',
        },
        @prop\map (prop) ->
          active = @active\get!

          ok, res = pcall ->
            conversions = assert (get_conversions 'mmm/dom', prop.type), "no conversion path"
            value = assert (active\get prop), "value went missing?"

            for i=#conversions,1,-1
              { :inp, :out, :transform } = conversions[i]
              value = transform value, active

            value

          if ok and res
            res
          else
            warn "error: ", res unless ok
            span "cannot display!", style: { color: '#f00' }
      }
    }

    @node = @tree.node

  navigate: (new) => @path\set new

{
  :Browser,
}
