assert MODE == 'CLIENT', '[nossr]'
Math = window.Math

import CanvasApp from require 'mmm.canvasapp'
import hsl from require 'mmm.color'

class KochDemo extends CanvasApp
  width: 500
  height: 400
  length: math.pi * 2

  new: (@iterations=3) =>
    super true
    hue = Math.random!
    @background = {1 - hue, .3, .3}

    @shades = setmetatable {}, __index: (tbl, key) ->
      with val = hsl { hue, .7, .9 - .5 * (key / @iterations)} do rawset tbl, key, val

  a_sixth = math.pi / 3
  a_third = 2 * a_sixth
  cossin = (a) -> (math.cos a), math.sin a
  triangle: (color) =>
    @ctx.fillStyle = color
    @ctx\beginPath!
    @ctx\moveTo cossin 0
    @ctx\lineTo cossin a_third
    @ctx\lineTo cossin 2*a_third
    @ctx\fill!

  update: (dt) =>
    super dt * 1.6

  draw: =>
    @ctx.fillStyle = hsl @background
    @ctx\fillRect 0, 0, @width, @height

    @ctx\translate @width/2, @height/2
    s = .3 * math.min @width, @height
    @ctx\scale s, s

    _scale = 0.8 + 0.2 * math.sin math.pi + @time

    ttime = @time - math.pi/2
    transfer, flipped = 0
    if ttime > 0 and ttime < math.pi
      transfer = .5 - .5 * math.cos ttime
      flipped = true

    draw = (i, pop) ->
      @triangle @shades[i]

      extra = not pop and flipped
      return unless i > (if extra then -1 else 0)

      scale = _scale
      if (pop and i < 1) or (not pop and i < 0)
        scale = transfer

      @ctx\save!
      @ctx\rotate -(a_sixth + a_third)
      @ctx\scale scale, scale

      for o=1,2
        @ctx\rotate a_third
        @ctx\save!
        @ctx\translate .5 + .5/scale, 0
        draw i - 1, pop
        @ctx\restore!

      @ctx\restore!

    @ctx\rotate a_sixth/2
    @ctx\translate -transfer, 0
    @ctx\rotate a_sixth * transfer

    @triangle @shades[3 - transfer]

    @ctx\save!
    @ctx\rotate a_sixth
    @ctx\scale _scale, _scale

    @ctx\save!
    @ctx\translate .5 + .5/_scale, 0
    draw 2 - transfer
    @ctx\restore!

    @ctx\rotate a_third

    @ctx\save!
    @ctx\translate .5 + .5/_scale, 0
    draw 2 - transfer
    @ctx\restore!

    @ctx\rotate a_third

    @ctx\save!
    @ctx\translate .5 + .5/_scale, 0
    draw 2 + transfer, true
    @ctx\restore!

    @ctx\restore!

KochDemo!
