=>
  import Box, Example from @get '_base: table'

  class Sidebar extends Example
    draw: =>
      margin_x, margin_y = @fit 16, 9
      if @naive
        margin_x, margin_y = 0, 0

      @ctx.font = '1.5px Arial'
      sidebar   = Box -7 - margin_x, -1, 2, 7
      @text sidebar, 'A', 'center', -1.8
      @text sidebar, 'B', 'center', -0.3
      @text sidebar, 'C', 'center',  1.2
      @text sidebar, 'D', 'center',  2.7

      bottom_l  = Box -4 - margin_x,  3.5 + margin_y, 8, 2
      bottom_r  = Box  4 + margin_x,  3.5 + margin_y, 8, 2

      @text bottom_l, 'levelname', 'left'
      @text bottom_r, 'info a b c', 'right'

      main      = Box 1, -1, 14, 7
      @ctx.lineWidth = 0.1
      @ctx.strokeStyle = 'black'
      @ctx\beginPath!
      for x=-5.5, 7.5
        @ctx\moveTo x, -4.5
        @ctx\lineTo x,  2.5

      for y=-4, 2
        @ctx\moveTo -6, y
        @ctx\lineTo  8, y
      @ctx\stroke!

      if @show_boxes
        @ctx.lineWidth = 0.1
        @ctx.strokeStyle = 'green'
        @strokeRect sidebar\rect!
        @strokeRect bottom_l\rect!
        @strokeRect bottom_r\rect!

        @ctx.strokeStyle = 'blue'
        @strokeRect main\rect!

  Sidebar!
