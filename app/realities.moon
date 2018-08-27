window = js.global
{ :document, :eval } = window

import asnode, h1, h2, p, a, i, div, ol, li, br, span, button, article from require './component.moon'
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
      \move (x + 1) * GRID_W, (y - 0.5) * -GRID_H - 11

  -- inout: (x=@width, y=@y) => @arrow '⇋', x, y      -- U+21CB
  -- inn:   (x=@width, y=@y) => @arrow '↼', x, y+0.25 -- U+21BC
  -- out:   (x=@width, y=@y) => @arrow '⇁', x, y-0.25 -- U+21C1
  inout: (x=@width, y=@y) => @arrow '⇆', x, y      -- U+21C6
  inn:   (x=@width, y=@y) => @arrow '←', x, y+0.25 -- U+2190
  out:   (x=@width, y=@y) => @arrow '→', x, y-0.25 -- U+2192

  mind: (label='mind', ...) => @block '#fac710', label, ...
  phys: (label='phys', ...) => @block '#8fd13f', label, ...
  digi: (label='digi', ...) => @block '#9510ac', label, ...

  next: =>
    @y = 0
    @width += 1

  finish: =>
    return if @node
    @svg\add @arrows

    @width += 1
    w, h = @width * GRID_W, @height * GRID_H

    l = GRID_W / 6.5
    @svg\add with @svg\line 0, -GRID_H, w, -GRID_H
      \stroke o width: 2, color: '#ffffff', dasharray: "#{l}, #{l}"

    @svg\size w, h
    @svg\viewbox 0, -h, w, h
    @node = @svg.node

addlabel = (label, diagram) ->
  with div style: { display: 'inline-block', margin: '20px', 'text-align': 'center' }
    \append diagram
    \append div label

figures = do
  style =
    display: 'flex'
    'align-items': 'flex-end'
    'justify-content': 'space-evenly'
  (...) -> div { :style, ... }


sources = do
  short = (id) => "#{id} #{@year}"
  long = => @names, " (#{@year}): ", (i @title), ", #{@published}"
  {
    Milgram: {
      title: 'Augmented Reality: A class of displays on the reality-virtuality continuum',
      published: 'in SPIE Vol. 2351',
      names: 'P. Milgram, H. Takemura, A. Utsumi, F. Kishino',
      year: 1994
      :long, :short,
    },
    Marsh: {
      title: 'Nested Immersion: Describing and Classifying Augmented Virtual Reality',
      published: 'IEEE Virtual Reality Conference 2015',
      names: 'W. Marsh, F. Mérienne',
      year: 2015
      :long, :short,
    },
    Billinghurst: {
      title: 'The MagicBook: a transitional AR interface',
      published: 'in Computer & Graphics 25',
      names: 'M. Billinghurst, H. Kato, I. Poupyrev',
      year: 2001,
      :long, :short,
    },
    Matrix: {
       title: 'The Matrix',
       year: 1999,
       names: 'L. Wachowski, A. Wachowski',
       long: => @names, " (#{@year}): ", (i @title)
       short: => tostring @year
    },
    Naam: {
      title: 'Nexus',
      published: 'Angry Robot',
      names: 'R. Naam',
      year: 2012,
      :long, :short,
    }
  }

ref = do
  fmt = (id) -> 
    a { (sources[id]\short id), href: "##{id}" }

  ref = (...) ->
    refs = { ... }
    with span "(", fmt refs[1]
      for i=2, #refs
        \append ", "
        \append fmt refs[i]
      \append ")"

references = ->
  with ol!
    for id, src in pairs sources
      \append li { :id, src\long! }

document.body\append asnode with article style: { margin: 'auto', 'max-width': '750px' }
  \append h1 "Reality Stacks"

  \append h2 "Abstract"

  \append p "With the development of mixed-reality experiences and the development of the corresponding interface
    devices multiple frameworks for classification of these experiences have been proposed. However these past
    attempts have mostly been developed alongside and with the intent of capturing specific projects ",
    (ref 'Marsh', 'Billinghurst'), " or are nevertheless very focused on existing methods and technologies ",
    (ref 'Milgram'), ". The existing taxonomies also all assume physical reality as a fixpoint and constant and are
    thereby not suited to describe many fictional mixed-reality environments and altered states of consciousness.
    In this paper we describe a new model for describing such experiences and examplify it's use with currently
    existing as well as idealized  technologies from popular culture."

--  \append p "In this paper we compare various multi-reality approaches such as VR and AR with each other as well as
--    related idealized technologies from popular culture.", br!,
--    "To this end we propose a new type of diagram that allows visualizing the complex structures encompassing multiple
--    reality laters that are concurrently inhabitated by the subject of such an experience."

  \append h2 "Terminology"
  \append p "We propose the following terms and definitions that will be used extensively for the remainder of the paper:"
  for term, definition in pairs {
    "layer of reality": "a closed system consisting of a world model and a set of rules or dynamics operating on and
      constraining said model.",
    "world model": "describes a world state containing objects, agents and/or concepts on an arbitrary abstraction level.",
    break: 1,
    "reality stack": "structure consisting of all layers of reality encoding an agent's interaction with his environment
      in their world model at a given moment, as well as all layers supporting these respectively."
    next: 2,
    "physical reality": "layer of reality defined by physical matter and the physical laws acting upon it.
      While the emergent phenomena of micro- and macro physics as well as layers of social existence etc. may be seen
      as separate layers, for the purpose of this paper we will group these together under the term of physical reality."
    "mental reality": "layer of reality perceived and processed by the brain of a human agent.",
    "digital reality": "layer of reality created and simulated by a digital system, e.g. a virtual reality game."
    "phys, mind, digi": "abbreviations for physical, mental and digital reality respectively.",
  }
    if 'number' == type definition
      \append document\createElement 'hr'
      continue
    \append with div style: { 'margin-left': '2rem' }
      \append span term, style: {
        display: 'inline-block',
        'margin-left': '-2rem',
        'font-weight': 'bold',
        'min-width': '140px'
      }
      \append span definition

  \append h2 "Introduction"
  \append p "Reality stack diagrams provide a way to plot two main axes of a given stack against each other:", br!,
    "On the vertical axis ownership or nesting of layers of realities is shown; from the bottom upwards each block,
    representing a layer of reality, is contained within the one above; i.e. it exists within and can be represented
    fully by the parent layer’s world model and its rules emerge from the dynamics of the parent layer.", br!,
    "The horizontal axis arranges layers of reality based on their appearance with respect to subjects interacting
    with the model. In the bottom left corner the subject’s internal model and reality provides the origin of
    the diagram. The world models that the subject is aware of are placed in the opposing right corner."

  \append p "Information flows, as represented by the white arrows, in two directions;
    towards the left, corresponding to information received and perceived by the subject, as well as
    towards the right, corresponding to actions taken in the space of the world model.", br!,
    "In between the two poles additional layers may be traversed by the information flowing one or both ways."

  \append p "Before we take a look at some reality stacks corresponding to current VR and AR technology,
    we can take a look at waking life as a baseline stack. To illustrate the format of the diagram we will compare it
    to the stack corresponding to a dreaming state:"

  \append with figures!
    \append addlabel "Waking Life", with Diagram!
      \mind!
      \inout!
      \phys!

      \next!
      \phys '', 2
      \finish!

    \append addlabel "Dreaming", with Diagram!
      \mind!
      \phys!
      \finish!

  \append p "In both cases, the top of the diagram is fully occupied by the physical layer of reality, colored in green.
    This is due to the fact that, according to the materialistic theory of mind, human consciousness owes its existance
    to the physical and chemical dynamics of neurons in our brains. Therefore our mental reality must be considered
    fully embedded in the physical reality, and consequently it may only appear underneath it in the diagram."

  \append p "During waking life, we concern ourselves mostly with the physical reality surrounding us.
    For this reason the physical reality is placed in the lower right corner of the diagram as the layer holding the
    external world model relevant to the subject. Information flows in both directions between the physical world model
    and the subject's mental model, as denoted by the two white arrows: Information about the state of the world model
    enter the subjects mind via the senses (top arrow, pointing leftwards), and choices the subject makes inside of and
    based on his mental model can feed back into the physical layer through movements (lower arrow, pointing rightwards)."

  \append p "In the dreaming state on the other hand, the subject is unaware of the physical layer of reality, though
    the mind remains embedded inside it. When dreaming, subjects' mental models don't depend on external models, hence
    the mental layer of reality must be the only layer along the bottom of the diagram."

  \append h2 "Current Technologies"
  \append p "Since recent technological advancements have enabled the development of VR and AR consumer devices,
    AR and VR have been established as the potential next frontier of digital entertainment.", br!,
    "As the names imply, the notion of reality is at the core of both technologies.
    In the following section we will take a look at the respective stacks of both experience types:"

  \append with figures!
    \append addlabel "VR", with Diagram!
      \mind!
      \phys!
      \inout nil, 1

      \next!
      \phys '', 2
      \inout nil, 1

      \next!
      \digi!
      \phys ''
      \finish!


    \append addlabel "AR", with Diagram!
      \mind!
      \inout nil, 1.25
      \inn nil, 0.5
      \phys!

      \next!
      \phys '', 2
      \inn nil, .5

      \next!
      \digi nil, .5
      \phys '', 1.5
      \finish!

  \append p "In both cases we find the physical layer of reality as an intermediate between the mental and
    digital layers. Actions taken by the subject have to be acted out physically (corresponding to the
    information traversing the barrier between mental and physical reality) before they can be again digitized using
    the various tracking and input technologies (which in turn carry the information across the boundary of the physical
    and digital spaces)."

  \append p "The difference between AR and VR lies in the fact that in AR the subject experiences a mixture of the
    digital and physical world models. This can be seen in the diagram, where we find that right of the diagram origin
    and the mental model, the diagram splits and terminates in both layers: while information reaches the subject both
    from the digital reality through the physical one, as well as directly from the physical reality, the subject only
    directly manipulates state in the physical reality."

  \append p "The data conversions necessary at layer boundaries incur at the least losses in quality and accuracy of
    information for purely technical reasons. However intermediate layers come at a higher cost than just an extra step
    of conversion: For information to flow through a layer, it must be encodable within that layer’s world model.
    This means that, akin to the metaphor of the ‘weakest link’, the range of information that can flow between layers
    of reality, and thereby the upper bound of experiences possible with a given reality stack, depends on the layer
    least fit to encode a respective piece of information.", br!,
    "As a practical example we can consider creating an hypothetical VR application that allows users to traverse a
    large virtual space by flying. While the human mind is perfectly capable of imagining to fly and control the motion
    appropriately, it is extremely hard to devise and implement a satisfying setup and control scheme because the
    physical body of the user needs to be taken into account and it, unlike the corresponding representations in the
    mental and digital world models, cannot float around freely."

  \append h2 "Future Developments"
  \append p "In the previous section we found that the presence of the physical layer in the information path of
    VR and AR stacks limits the experience as a whole. It follows that the removal of that indirection should be
    an obvious goal for future developments:"

  \append figures addlabel "holy grail of VR: 'The Matrix'", with Diagram!
    \mind!
    \inout!
    \phys!

    \next!
    \digi!
    \phys ''
    \finish!

  \append p "In the action movie 'The Matrix' ", (ref 'Matrix'), ", users of the titular VR environment interface with it
    by plugging cables into implanted sockets that connect the simulation directly to their central nervous system.", br!,
    "While these cables and implanted devices are physical devices, they don't constitute the presence of the 
    physical layer of reality in the information path because while they do transmit information, the information
    remains in either the encoding of the mental model (neural firing patterns) or the encoding of the digital model
    (e.g. a numeric encoding of a player character's movement in digital space) and the conversion is made directly
    between those two - the data never assumes the native encoding of the physical layer (e.g. as a physical motion)."

  \append p "While we are currently far from being able to read arbitrary high-level information from the brain
    or to synthesize sensual input in human perception by bypassing the sensory organs, brain-computer interfaces (BCI)
    are a very active area of research with high hopes for comparable achievements in the near future."

  \append p "Applying this same step of removing the physical layer of reality from AR, we end up with something similar
    to the nano-particle drug in ", (i "Nexus"), " ", (ref 'Naam'), ".  However this does not grant the user a similar
    amount of control over his experience as the holy grail of VR does, since the user and the physical part of the
    environment remain bound by the physical layer of reality's laws.", br!,
    "Instead the holy grail of AR is reached with the creation of a god machine that can manipulate the state of the
    physical world according to the user's wishes. In this way the digital and physical realities become unified and
    fully 'augmented'."

  \append with figures!
    \append addlabel "'Nexus'", with Diagram!
      \mind!
      \inout nil, 0.75
      \inout nil, 1.25
      \phys!

      \next!
      \digi nil, .5
      \phys '', 1.5
      \finish!

    \append addlabel "holy grail of AR: 'Deus Machina'", with Diagram!
      col = '#92807c'

      \mind!
      \inout!
      \block col, ''

      \next!
      \block col, '', 2
      .svg\plain('phys + digi')\attr(o fill: 'white', 'font-size': '14px')\move 6, -2 * GRID_H
      \finish!

  \append h2 "Conclusions"
  \append p "Despite the similarities of VR and AR, the two can be considered polar opposites, as becomes evident when
    we compare their respective utopian implementations: they share the goal of allowing us to experience realities
    different from the one we naturally inhabit, but while VR seeks to accomplish this by creating a new, nested reality
    inside ours, thus giving us full control over it, AR is instead an attempt to retrofit our specific needs directly
    into the very reality we exist in."

  \append h2 "Relation to Theories of Mind"
  \append p "This paper starts from a deeply materialistic point of view and borders on microphysicalism.
    However it should be noted that the diagram style introduced above lends itself also to display other
    philosophical theories of mind. As an example, the following graphics show a typical VR stack as interpreted by
    Materialism, Cartesian Dualism and Solipsism respectively:"

  \append with figures!
    \append addlabel "VR in Materialism", with Diagram!
      \mind!
      \inout nil, 1
      \phys!

      \next!
      \phys '', 2
      \inout nil, 1

      \next!
      \digi!
      \phys ''

      \finish!

    \append addlabel "VR in Solipsism", with Diagram!
      \mind nil, 2
      \inout nil, 1

      \next!
      \digi!
      \mind ''
      \finish!

    \append addlabel "VR in Cartesian Dualism", with Diagram!
      \mind nil, 2
      \inout nil, 1
      \next!

      \phys nil, 2
      \inout nil, 1
      \next!

      \digi!
      \phys ''
      \finish!

  \append p "However these philosophical theories of minds also constitute reality stacks by themselves and as such can
    be compared directly:"

  \append with figures!
    \append addlabel "Materialism", with Diagram!
      \mind!
      \inout!
      \phys!

      \next!
      \phys '', 2
      \finish!

    \append addlabel "Solipsism", with Diagram!
      \mind!
      \finish!

    \append addlabel "Cartesian Dualism", with Diagram!
      \mind!
      \inout!
      \next!

      \phys!
      \finish!

  \append h2 'References'
  \append references!
