assert MODE == 'CLIENT', '[nossr]'

import CanvasApp from require 'mmm.canvasapp'
import div from require 'mmm.dom'

class UIDemo extends CanvasApp
  width: nil
  height: nil
  new: () =>
    super!

    @canvas.width = nil
    @canvas.height = nil
    @canvas.style.width = '100%'
    @canvas.style.height = '100%'
    @canvas.style.border = '2px solid var(--gray-dark)'

    @node = div @canvas, style: {
      position: 'relative'
      resize: 'horizontal'
      overflow: 'hidden'

      width: '576px'
      height: '324px'
      minWidth: '324px'
      maxWidth: '742px'

      margin: 'auto'
      padding: '10px'
      boxSizing: 'border-box'
    }

  -- match size of current parent element and return it (for interactive resizing in the demo)
  updateSize: =>
    { :clientWidth, :clientHeight } = @canvas.parentElement
    @canvas.width, @canvas.height = clientWidth, clientHeight
    @canvas.width, @canvas.height

  -- set up a coordinate system such that the virtual viewport
  -- of size (w, h) is centered on (0,0) and fills the canvas
  -- returns remaining margins on the two axes
  fit: (w, h) =>
    width, height = @updateSize!
    @ctx\translate width/2, height/2

    -- maximum scale without cropping either axis
    scale = math.min (width/w), (height/h)
    @ctx\scale scale, scale

    -- calculate remaining space on x/y axis
    rx = (width/scale) - w
    ry = (height/scale) - h

    -- margins are half of the remaining space
    rx / 2, ry / 2

  strokeRect: (cx, cy, w, h) =>
    lw = @ctx.lineWidth / 2
    @ctx\strokeRect cx - w/2 + lw, cy - h/2 + lw,
                    w - 2*lw,      h - 2*lw,

class Box
  new: (@cx, @cy, @w, @h) =>

  rect: =>
    @cx, @cy, @w, @h

class Example extends UIDemo
  click: =>
    if @naive
      @naive = false
    else
      if @show_boxes
        @naive = true
      @show_boxes = not @show_boxes

  text: (box, text, align='center', my=.5) =>
    mx = .1
    @ctx.textAlign = align

    if align == 'left'
      @ctx\fillText text, box.cx + mx - box.w/2, box.cy + my
    else if align == 'center'
      @ctx\fillText text, box.cx,                box.cy + my
    if align == 'right'
      @ctx\fillText text, box.cx - mx + box.w/2, box.cy + my

{
  :UIDemo
  :Example
  :Box
}
