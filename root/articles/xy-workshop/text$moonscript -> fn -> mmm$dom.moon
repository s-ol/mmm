import ReactiveVar, tohtml, fromhtml, text, elements from require 'mmm.component'
import article, button, div, span from elements

=>
  index = ReactiveVar 1
  slide = index\map (index) -> @children[index]

  local view
  view = div {
    style:
      position: 'relative'
      'padding-top': '56.25%'

    div {
      style:
        position: 'absolute'
        display: 'flex'
        'flex-direction': 'column'
        top: 0
        left: 0
        right: 0
        bottom: 0
        padding: '1em'
        background: '#eeeeee'
        'box-sizing': 'border-box'

      slide\map => @get 'mmm/dom'
    }
  }

  local left, right, viewNode
  if MODE == 'CLIENT'
    left = (_, e) ->
      e\preventDefault!
      index\transform (a) -> math.max 1, a - 1

    right = (_, e) ->
      e\preventDefault!
      index\transform (a) -> math.min #@children, a + 1

    viewNode = tohtml view
    viewNode.tabIndex = 1
    viewNode\addEventListener 'keydown', (_, e) ->
      switch e.key
        when 'r'
          e\preventDefault!
          size = viewNode.offsetHeight / 15
          viewNode.style.fontSize = "#{size}px"

        when 'ArrowLeft'
          left _, e
        when 'ArrowRight'
          right _, e

  tohtml with article!
    \append div {
      style:
        display: 'flex'

      button '<', onclick: left
      ' '
      span index\map (t) -> text t
      ' '
      button '>', onclick: right
      div style: flex: '1'
      button 'fullscreen', onclick: (_, e) ->
        e\preventDefault!
        viewNode\requestFullscreen!
    }
    \append view
