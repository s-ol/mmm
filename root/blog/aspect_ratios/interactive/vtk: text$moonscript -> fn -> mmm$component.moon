=>
  assert MODE == 'CLIENT', '[nossr]'

  import Box, Example from @get '_base: table'

  class VTK extends Example
    draw: =>
      margin_x, margin_y = @fit 16, 9
      if @naive
        margin_x, margin_y = 0, 0

      levelname = Box -4 - margin_x, -3.5 - margin_y, 8, 2
      settings  = Box  4 + margin_x, -3.5 - margin_y, 8, 2
      infobar   = Box -4 - margin_x,  3.5 + margin_y, 8, 2
      exit      = Box  4 + margin_x,  3.5 + margin_y, 8, 2

      main      = Box 0, 0, 16, 5

      @ctx.font = '1.5px Arial'
      @text levelname, 'levelname', 'left'
      @text infobar, 'info a b c', 'left'
      @text settings, 'settings', 'right'
      @text exit, 'exit', 'right'

      @ctx.lineWidth = 0.2
      @ctx.strokeStyle = 'black'
      @ctx\beginPath!
      @ctx\moveTo -8 - margin_x, -2.5 - margin_y
      @ctx\lineTo  8 + margin_x, -2.5 - margin_y
      @ctx\moveTo -8 - margin_x,  2.5 + margin_y
      @ctx\lineTo  8 + margin_x,  2.5 + margin_y
      @ctx\stroke!

      @ctx.lineWidth = 0.1
      @ctx.strokeStyle = 'gray'
      @ctx\beginPath!
      for x=-7.5, 7.5
        @ctx\moveTo x, -2.5
        @ctx\lineTo x,  2.5

      for y=-2, 2
        @ctx\moveTo -8, y
        @ctx\lineTo  8, y
      @ctx\stroke!

      if @show_boxes
        @ctx.lineWidth = 0.1
        @ctx.strokeStyle = 'green'
        @strokeRect levelname\rect!
        @strokeRect settings\rect!
        @strokeRect infobar\rect!
        @strokeRect exit\rect!

        @ctx.strokeStyle = 'blue'
        @strokeRect main\rect!

  VTK!
