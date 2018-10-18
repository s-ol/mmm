window = js.global

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
    t = @
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

{
  :CanvasApp
}
