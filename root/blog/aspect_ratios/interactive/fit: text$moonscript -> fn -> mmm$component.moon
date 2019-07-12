=>
  assert MODE == 'CLIENT', '[nossr]'

  import UIDemo from @get '_base: table'

  class FitDemo extends UIDemo
    draw: =>
      @fit 16, 9
      @ctx.fillStyle = 'red'
      @ctx\fillRect -8, -4.5, 16, 9

      @ctx.fillStyle = 'black'
      @ctx.font = '6px Arial'
      @ctx.textAlign = 'center'
      @ctx\fillText '16:9', 0, 2

  FitDemo!
