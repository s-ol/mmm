on_client ->
  Math = window.Math

  import CanvasApp from require 'lib.canvasapp'
  import hsl from require 'lib.color'

  class TwistedDemo extends CanvasApp
    width: 500
    height: 400
    length: math.pi * 4
    new: =>
      super true
      @background = {Math.random!, Math.random!/3+.2, Math.random!/4}
      hue = Math.random!
      @shades = setmetatable {}, __index: (key) =>
        with val = { hue, .7, key * .3 + .1} do rawset @, key, val

    draw: =>
      @ctx.fillStyle = hsl @background
      @ctx\fillRect 0, 0, @width, @height
      @ctx\translate @width/2, @height/2 + 70

      draw = (i) ->
        @ctx\save!
        @ctx\translate 0, -120*i
        s = 1 - 0.1 * math.sin @time + i*2
        s *= 0.8 - i * .4 * math.cos @time
        @ctx\scale s, s/2
        @ctx\rotate @time/4 + i * .6 * math.cos @time
        @ctx.fillStyle = hsl table.unpack @shades[i]
        @ctx\fillRect -80, -80, 160, 160
        @ctx\restore!

      for i=0,1,1/(20 + 19 * math.sin(@time / 2))
        draw i
      draw 1

  document.body\appendChild TwistedDemo!.node
