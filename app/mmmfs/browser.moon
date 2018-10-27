import ReactiveVar, text, elements from require 'lib.component'
import div, span, a, select, option from elements

append = (list, val) ->
  list = [x for x in *list]
  table.insert list, val
  list

class Browser
  new: (@root) =>
    @path = ReactiveVar {}
    @path\subscribe (path) -> window.location.hash = '/' .. table.concat path, '/'
    @prop = ReactiveVar next @root.props
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

    @active\subscribe (fileder) -> @prop\set next fileder.props

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
          link = {}
          for name in *path
            link = append link, name
            \append '/'
            \append a name, href: '#', onclick: (_, e) ->
              e\preventDefault!
              @navigate link

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
          val, key = active\get prop.name, prop.type

          res = CONVERT 'mmm/dom', val, key
          res or span "cannot display!", style: { color: '#f00' }
      }
    }

    @node = @tree.node

  navigate: (new) => @path\set new

{
  :Browser,
}
