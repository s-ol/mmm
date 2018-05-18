window = js.global
document = window.document

import CanvasApp from require './canvasapp.moon'
import rgb from require './color.moon'
import h1, p, div, span, input, button from require './html.moon'

fast = true
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
  width: window.innerWidth - 8
  height: window.innerHeight * 0.6
  new: (@text, @font, @size) => super!

  keydown: (key) =>
    if key == "Backspace" or key == "Delete"
      @text = @text\sub 1, #@text - 1
    elseif string.len(key) == 1
      @text ..= key

  draw: =>
    @ctx\clearRect 0, 0, @width, @height

    @ctx.font = "#{@size}px #{@font}"
    @ctx.textBaseline = 'top'

    x, y = 0, @size/2
    for i=1, #@text
      char = @text\sub i, i
      cx, cy, w = center_char char, @font, @size

      if x + w > @width
        x = 0
        y += @size * 1.2

      @ctx\fillText char, x + w/2 - cx, y - cy
      x += w

document.body\appendChild h1 'Fonts aligned by Center-of-Mass'
document.body\appendChild p 'Click below and type away :)'

app = CenterOfMass "What's up", "Times New Roman", 40
document.body\appendChild app.canvas
app.canvas.style.backgroundColor = '#eee'

add = =>
  document.body\appendChild div {
    span 'font: ',
    with @font_input = input!
      .type = 'text'
      .value = 'Times New Roman'
    with button 'set'
      .onclick = (_, e) -> app.font = @font_input.value
  }

  document.body\appendChild div {
    span 'size: ',
    input type: 'range', min: 2, max: 120, value: 40, onchange: (_, e) ->
      size = e.target.value
      @size_label.innerText = size
      app.size = size
    with @size_label = span '40'
      ''
  }

  document.body\appendChild div {
    span 'optimize inner loop: ',
    input type: 'checkbox', checked: fast, onchange: (_, e) ->
      fast = e.target.checked
  }
add {}
