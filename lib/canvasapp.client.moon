window = js.global
js = require 'js'

import a, canvas, div, button, script from require 'lib.html'

class CanvasApp
  width: 500
  height: 400
  new: (show_menu=false, @paused) =>
    @canvas = canvas width: @width, height: @height

    @ctx = @canvas\getContext '2d'
    @time = 0

    @canvas.tabIndex = 0
    @canvas\addEventListener 'click', (_, e) -> @click and @click e.offsetX, e.offsetY, e.button
    @canvas\addEventListener 'keydown', (_, e) -> @keydown and @keydown e.key, e.code

    lastMillis = window.performance\now!

    animationFrame = (_, millis) ->
      if not @paused
        @update (millis - lastMillis) / 1000
        @ctx\resetTransform!
        @draw!
        window\setTimeout (->
          window\requestAnimationFrame animationFrame
        ), 0
      lastMillis = millis
    window\requestAnimationFrame animationFrame

    @node = if show_menu
      div {
        className: 'canvas_app'
        @canvas
        div {
          className: 'overlay',
          button 'render 30fps', onclick: -> @\render 30
          button 'render 60fps', onclick: -> @\render 60
        }
      }
    else
      @canvas


  update: (dt) =>
    @time += dt

    if @length and @time > @length
      @time -= @length
      true

  render: (fps=60) =>
    assert @length, 'cannot render CanvasApp without length set'
    @paused = true

    actual_render = ->
      writer = js.new window.Whammy.Video, fps

      doFrame = ->
        done = @update 1/fps
        @ctx\resetTransform!
        @draw!

        writer\add @canvas

        if done or @time >= @length
          blob = writer\compile!
          name = "#{@@__name}_#{fps}fps.webm"
          @node.lastChild\appendChild a name, download: name, href: window.URL\createObjectURL blob
        else
          window\setTimeout doFrame

      @time = 0
      doFrame!

    if window.Whammy
      actual_render!
    else
      window.global = window.global or window
      document.body\appendChild script
        onload: actual_render
        src: 'https://cdn.jsdelivr.net/npm/whammy@0.0.1/whammy.min.js'

{
  :CanvasApp
}
