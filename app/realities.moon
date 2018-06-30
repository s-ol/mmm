window = js.global
{ :document, :eval } = window

import div, button from require './component.moon'
require 'svg.js'

SVG =
  doc: window\eval "(function() { return SVG(document.createElement('svg')); })",
  G: window\eval "(function() { return new SVG.G(); })",
setmetatable SVG, __call: => @doc!

o = do
  mkobj = window\eval "(function () { return {}; })"
  (tbl) ->
    with obj = mkobj!
      for k,v in pairs(tbl)
        obj[k] = v

print = window.console\log

GRID_W = 50
GRID_H = 40

class Diagram
  new: =>
    @svg = SVG!
    @arrows = SVG.G!
    @width, @height = 0, 0
    @y = 0

  txtattr = o {
    fill: 'white',
    'font-size': '14px',
    'text-anchor': 'middle',
  }
  block: (color, label, h=1) =>
    @svg\add with SVG.G!
      with \rect GRID_W, h * GRID_H
        \attr o fill: color
      if label
        with \plain label
          \move GRID_W/2, 0
          \attr txtattr

      \move @width * GRID_W, (@y + h) * -GRID_H
    @y += h
    if @y > @height
      @height = @y

  arrattr = o {
    fill: 'white',
    'font-size': '18px',
    'text-anchor': 'middle',
  }
  arrow: (char, x, y) =>
    with @arrows\plain char
      \attr arrattr
      print 60
      \move (x + 1) * GRID_W, (y - 0.5) * -GRID_H - 9

  -- inout: (x=@width, y=@y) => @arrow '⇋', x, y      -- U+21CB
  -- inn:   (x=@width, y=@y) => @arrow '↼', x, y+0.25 -- U+21BC
  -- out:   (x=@width, y=@y) => @arrow '⇁', x, y-0.25 -- U+21C1
  inout: (x=@width, y=@y) => @arrow '⇆', x, y      -- U+21C6
  inn:   (x=@width, y=@y) => @arrow '←', x, y+0.25 -- U+2190
  out:   (x=@width, y=@y) => @arrow '→', x, y-0.25 -- U+2192

  mind: (label='mind', ...) => @block '#fac710', label, ...
  phys: (label='phys', ...) => @block '#8fd13f', label, ...
  tech: (label='tech', ...) => @block '#9510ac', label, ...

  next: =>
    @y = 0
    @width += 1

  getNode: =>
    return @node if @node
    @svg\add @arrows

    @width += 1
    w, h = @width * GRID_W, @height * GRID_H
    @svg\size w, h
    @svg\viewbox 0, -h, w, h
    @node = @svg.node
    @node

diagrams =
  'Solipsism': with Diagram!
    \mind!

  'Cartesian Dualism': with Diagram!
    \mind!
    \inout!
    \next!

    \phys!

  'Waking Life': with Diagram!
    \mind!
    \inout!
    \phys!

    \next!
    \phys '', 2

  dream: with Diagram!
    \mind!
    \phys!

  'VR2018': with Diagram!
    \mind!
    \phys!

    \next!
    \phys '', 2

    \next!
    \tech!
    \phys ''

    \inout 0, 1
    \inout 1, 1

  'Matrix': with Diagram!
    \mind!
    \inout!
    \phys!

    \next!
    \tech!
    \phys ''

  AR: with Diagram!
    \mind!
    \inn!
    \out!
    \out 1, 1
    \phys!

    \next!
    \phys '', 2

    \next!
    \tech nil, .5
    \phys '', 1.5

  magic: with Diagram!
    \mind!
    \inn!
    \out!
    \phys!

    \next!
    \tech nil, .5
    \phys '', .5
    \out 1, 1
    \phys ''

    \next!
    \phys '', 2

for name, diagram in pairs diagrams
  parent = div style: { display: 'inline-block', margin: '20px' }
  parent\append diagram\getNode!
  parent\append div name
  parent\append button 'export', onclick: => window\alert diagram.svg\svg!
  document.body\appendChild parent.node
