=>
  import UIDemo from @get '_base: table'

  arr = (args) ->
    with js.new js.global.Array
      for i in *args
        \push i

  class PerforateDemo extends UIDemo
    draw: =>
      @fit 16, 9

      @ctx.lineWidth = 0.15
      @ctx.strokeStyle = 'green'
      @strokeRect 0, -3.5, 16, 2
      @strokeRect 0,  3.5, 16, 2

      @ctx\setLineDash arr { 0.4 }
      @ctx\beginPath!
      @ctx\moveTo 0, -4.5
      @ctx\lineTo 0, -2.5
      @ctx\moveTo 0,  2.5
      @ctx\lineTo 0,  4.5
      @ctx\stroke!
      @ctx\setLineDash arr {}

      @ctx.strokeStyle = 'blue'
      @strokeRect 0, 0, 16, 5

      @ctx.font = '4px Arial'
      @ctx.textAlign = 'center'
      @ctx\fillText '16:5', 0, 1.5

  PerforateDemo!
