=>
  import UIDemo from @get '_base: table'

  arr = (args) ->
    with js.new js.global.Array
      for i in *args
        \push i

  class TearDemo extends UIDemo
    draw: =>
      margin_x, margin_y = @fit 16, 9

      @ctx.lineWidth = 0.15
      @ctx.strokeStyle = 'green'
      @strokeRect -4 - margin_x, -3.5 - margin_y, 8, 2
      @strokeRect  4 + margin_x, -3.5 - margin_y, 8, 2

      @strokeRect -4 - margin_x,  3.5 + margin_y, 8, 2
      @strokeRect  4 + margin_x,  3.5 + margin_y, 8, 2

      @ctx.strokeStyle = 'blue'
      @strokeRect 0, 0, 16, 5

      @ctx.font = '4px Arial'
      @ctx.textAlign = 'center'
      @ctx\fillText '16:5', 0, 1.5

  TearDemo!
