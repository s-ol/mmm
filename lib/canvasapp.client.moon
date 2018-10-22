window = js.global
js = require 'js'

class CanvasApp
  width: 500
  height: 400
  new: =>
    @canvas = window.document\createElement 'canvas'
    @canvas.width, @canvas.height = @width, @height
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

  update: (dt) =>
    @time += dt

  render: (fps=15) =>
    assert @length, 'cannot render CanvasApp without length set'
    @paused = true

    script = window.document\createElement 'script'
    script.src = "https://github.com/thenickdude/webm-writer-js/releases/download/0.2.0/webm-writer-0.2.0.js"
    script.onload = ->
      writer = js.new window.WebMWriter, with js.new window.Object
        .quality = .9
        .frameRate = fps

      doFrame = ->
        @update 1/fps
        @ctx\resetTransform!
        @draw!

        writer\addFrame @canvas
        print 'added a frame'

        if @time >= @length
          promise = writer\complete!
          promise['then'] promise, (blob) =>
            document.body\appendChild with document\createElement 'a'
              .href = window.URL\createObjectURL blob
              .download = 'rendered.webm'
              .innerHTML = 'download'
        else
          window\setTimeout doFrame

      doFrame!

    document.body\append script

{
  :CanvasApp
}
