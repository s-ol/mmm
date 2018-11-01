import define_fileders from require 'lib.mmmfs'
Fileder = define_fileders ...

with Fileder {
    'name: alpha': 'twisted',
    'description: text/plain': "pseudo 3d",
  }

  if MODE == 'CLIENT'
    import CanvasApp from require 'lib.canvasapp'
    import hsl from require 'lib.color'

    Math = window.Math

    class TwistedDemo extends CanvasApp
      width: 500
      height: 400
      length: math.pi * 4
      new: (preview) =>
        if preview
          @width, @height = 120, 120
          super false, true
        else
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

    .props['preview: moon -> mmm/component'] = => TwistedDemo true
    .props['moon -> mmm/component'] = => TwistedDemo!
