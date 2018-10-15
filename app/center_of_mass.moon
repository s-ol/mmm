window = js.global
document = window.document

import CanvasApp from require 'app.canvasapp'
import rgb from require 'app.color'
import h1, p, div, span, input, button from require 'app.html'

fast = true
center = true
center_char = do
  canvas = document\createElement 'canvas'
  ctx = canvas\getContext '2d'

  cache = {}

  (char, font, height) ->
    name = "#{char} #{height} #{font}"
    return table.unpack cache[name] if cache[name]

    ctx\resetTransform!
    ctx.font = "#{height}px #{font}"
    width = (ctx\measureText char).width
    canvas.width, canvas.height = width, height * 1.2

    ctx.font = "#{height}px #{font}"
    ctx.textBaseline = 'top'
    ctx.fillStyle = rgb 0, 0, 0
    ctx\fillText char, 0, 0

    data = ctx\getImageData 0, 0, width, height * 1.2

    local xx, yy
    if fast
      loop = window\eval '(function(data) {
        var xx = 0, yy = 0, n = 0;
        for (var x = 0; x < data.width - 1; x++) {
          for (var y = 0; y < data.height - 1; y++) {
            var i = y * (data.width * 4) + x * 4;
            var alpha = data.data[i + 3] / 255;
            xx += x * alpha;
            yy += y * alpha;
            n += alpha;
          }
        }

        xx /= n;
        yy /= n;
        return [xx, yy];
      })'
      res = loop nil, data
      xx, yy = res[0], res[1]
    else
      xx, yy, n = 0, 0, 0
      for x = 0, data.width - 1
        for y = 0, data.height - 1
           i = y * (data.width * 4) + x * 4
           alpha = data.data[i + 3] / 255
           xx += x * alpha
           yy += y * alpha
           n += alpha

      xx /= n
      yy /= n
    cache[name] = { xx, yy, width }
    xx, yy, width

class CenterOfMass extends CanvasApp
  width: window.innerWidth - 20
  height: 300
  new: (text, @font, @size) =>
    super!
    @text = {}
    for i = 1,#text
      @add text\sub i, i

  add: (char) =>
    rcx, rcy, w = center_char char, @font, @size
    cx, cy = w/2, @size/2
    vx, vy = 0, 0
    table.insert @text, {
      :char, :rcx, :rcy, :w
      :cx, :cy, :vx, :vy
    }

  refresh: =>
    for char in *@text
      char.rcx, char.rcy, char.w = center_char char.char, @font, @size

  keydown: (key) =>
    if key == "Backspace" or key == "Delete"
      table.remove @text
    elseif string.len(key) == 1
      @add key

  update: (dt) =>
    super dt

    ACCEL = 4 * dt
    DAMPING = 8 * dt

    for char in *@text
      { :rcx, :rcy, :cx, :cy, :w } = char
      if not center
        rcx, rcy = w/2, @size/2
      dx, dy = rcx - cx, rcy - cy
      char.vx += dx * ACCEL
      char.vy += dy * ACCEL
      char.cx += char.vx
      char.cy += char.vy
      char.vx *= DAMPING
      char.vy *= DAMPING

  draw: =>
    @ctx\clearRect 0, 0, @width, @height

    @ctx.font = "#{@size}px #{@font}"
    @ctx.textBaseline = 'top'

    x, y = @size * .1, @size
    for { :char, :cx, :cy, :w } in *@text
      if x + w > @width
        x = 0
        y += @size * 1.2

      @ctx\fillText char, x + w/2 - cx, y - cy
      x += w

append h1 'Fonts aligned by Center-of-Mass'
app = CenterOfMass "Click here and type Away!", "Times New Roman", 40
append app.canvas
app.canvas.style.backgroundColor = '#eee'

add = =>
  append div {
    span 'font: ',
    with @font_input = input!
      .type = 'text'
      .value = 'Times New Roman'
    with button 'set'
      .onclick = (_, e) ->
        app.font = @font_input.value
        app\refresh!
  }

  append div {
    span 'size: ',
    input type: 'range', min: 2, max: 120, value: 40, onchange: (_, e) ->
      size = e.target.value
      @size_label.innerText = size
      app.size = size
      app\refresh!
    with @size_label = span '40'
      ''
  }

  append div {
    span 'center characters by weight: ',
    input type: 'checkbox', checked: center, onchange: (_, e) ->
      center = e.target.checked
  }

  append div {
    span 'optimize inner loop: ',
    input type: 'checkbox', checked: fast, onchange: (_, e) ->
      fast = e.target.checked
  }
add {}
