on_client ->
  Math = window.Math

  import CanvasApp from require 'lib.canvasapp'
  import hsl from require 'lib.color'

  class TwistedDemo extends CanvasApp
    width: 600
    height: 600
    length: math.pi * 2

    new: (@iterations=3, @scale=.5) =>
      super!
      hue = Math.random!
      @background = {1 - hue, .3, .3}

      @shades = setmetatable {}, __index: (tbl, key) ->
        with val = hsl { hue, .7, .9 - .5 * (key / @iterations)} do rawset tbl, key, val

    a_sixth = math.pi / 3
    cossin = (a) -> (math.cos a), math.sin a
    triangle: (color) =>
      @ctx.fillStyle = color
      @ctx\beginPath!
      @ctx\moveTo cossin 0
      @ctx\lineTo cossin 2*a_sixth
      @ctx\lineTo cossin 4*a_sixth
      @ctx\fill!

    update: (...) =>
      super ...

      @scale = 0.8 + 0.2 * math.cos @time

    draw: =>
      @ctx.fillStyle = hsl @background
      @ctx\fillRect 0, 0, @width, @height

      @ctx\translate @width/2, @height/2
      scale = .3 * math.min @width, @height
      @ctx\scale scale, scale

      draw = (i, e=1) ->
        @triangle @shades[i]

        return unless i > 0

        @ctx\save!
        @ctx\rotate -3*a_sixth
        @ctx\scale @scale, @scale

        for o=-1,e,2
          @ctx\save!
          @ctx\rotate o * 2 * a_sixth
          @ctx\translate .5 + .5/@scale, 0
          draw i - 1
          @ctx\restore!

        @ctx\restore!

      @ctx\rotate a_sixth/2
      draw @iterations, 3

  twisted = TwistedDemo!
  document.body\appendChild twisted.canvas
  -- window\setTimeout twisted\start, 500

  { :location } = window
  if location.search and location.search\find 'render'
    twisted\render!

