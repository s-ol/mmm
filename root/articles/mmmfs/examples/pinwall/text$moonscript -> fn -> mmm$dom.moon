import article, div from require 'mmm.dom'
import convert from require 'mmm.mmmfs.conversion'

update_info = (fileder, x, y, w, h) ->
  info = (fileder\get 'pinwall_info: table') or x: 100, y: 100, w: 300, h: 300
  info.x = x if x
  info.y = y if y
  info.w = w if w
  info.h = h if h

  json = convert 'table', 'text/json', info, fileder, 'pinwall_info'
  fileder\set 'pinwall_info: text/json', json

CLIENT = MODE == 'CLIENT'

=>

  pending = {}
  observe = if CLIENT
    map = {}
    observer = js.new js.global.ResizeObserver, (_, entries) ->
      for entry in js.of entries
        if child = map[entry.target]
          rect = entry.contentRect
          pending[child] = -> update_info child, nil, nil, rect.width, rect.height

    (node, child) ->
      map[node] = child
      observer\observe node

  drag = nil
  
  children = for child in *@children
      info = (child\get 'pinwall_info: table') or x: 100, y: 100, w: 300, h: 300
      wrapper = div {
        style:
          position: 'absolute'
          padding: '10px'
          resize: 'both'
          overflow: 'hidden'
          background: 'var(--gray-dark)'
          border: '1px solid var(--gray-bright)'

          left: "#{info.x}px"
          top: "#{info.y}px"
          width: "#{info.w}px"
          height: "#{info.h}px"

        -- handle for moving the child
        div {
          style:
            top: '0'
            left: '0'
            right: '0'
            height: '10px'
            cursor: 'pointer'
            position: 'absolute'

          onmousedown: CLIENT and (_, e) ->
            node = e.target.parentElement
            drag = {
              :child
              :node

              startX: tonumber node.style.left\match '(%d+)px'
              startY: tonumber node.style.top\match '(%d+)px'
              startMouseX: e.clientX
              startMouseY: e.clientY
            }
        }

        -- child content
        div {
          style:
            width: '100%'
            height: '100%'
            background: 'var(--white)'

          (child\gett 'mmm/dom')
        }
      }

      -- listen for resize events
      observe wrapper, child if CLIENT
      wrapper

  children.style = {
    width: '1000px'
    height: '500px'
  }

  if CLIENT
    children.onmousemove = (_, e) ->
      return unless drag

      x = drag.startX + (e.clientX - drag.startMouseX)
      y = drag.startY + (e.clientY - drag.startMouseY)
      drag.node.style.left = "#{x}px"
      drag.node.style.top = "#{y}px"

    children.onmouseup = (_, e) ->
      for k, func in pairs pending
        func!
      pending = {}

      return unless drag

      x = drag.startX + (e.clientX - drag.startMouseX)
      y = drag.startY + (e.clientY - drag.startMouseY)
      update_info drag.child, x, y
      drag = nil

    children.onmouseleave = (_, e) ->
      return unless drag

      drag.node.style.left = "#{drag.startX}px"
      drag.node.style.top = "#{drag.startY}px"
      drag = nil

  article children
