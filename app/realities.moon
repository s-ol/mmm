import append, h1, h2, p, a, i, div, ol, li, br, hr, span, button, section, article from require 'lib.component'

if MODE == 'CLIENT'
  require 'svg.js'
else
  import compile from require 'duct_tape'

  append '<script src="https://cdnjs.cloudflare.com/ajax/libs/svg.js/2.6.6/svg.min.js"></script>'

  export ^
  class Diagram
    style = {
      display: 'inline-block',
      width: '150px',
      height: '80px',
      'line-height': '80px',
      color: '#fff',
      background: '#666',
    }

    @id = 1
    new: (@func) =>
      @id = "diagram-#{@@id}"
      @@id += 1

    render: =>
      rplc = with div id: @id, :style
        \append '(diagram goes here)'
        \append "<script type=\"application/lua\">
          local rplc = js.global.document:getElementById('#{@id}');
          local fn = #{compile @func}
          diag = Diagram(fn)
          rplc.parentNode:replaceChild(diag.node, rplc)
        </script>"
      rplc\render!

on_client ->
  export ^
  export o
  eval = js.global\eval
  GRID_W = 50
  GRID_H = 40

  SVG =
    doc: eval "(function() { return SVG(document.createElement('svg')); })",
    G: eval "(function() { return new SVG.G(); })",
  setmetatable SVG, __call: => @doc!

  o = do
    mkobj = eval "(function () { return {}; })"
    (tbl) ->
      with obj = mkobj!
        for k,v in pairs(tbl)
          obj[k] = v

  class Diagram
    new: (f) =>
      @svg = SVG!
      @arrows = SVG.G!
      @width, @height = 0, 0
      @y = 0

      f @

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
  short = => "#{@id} #{@year}"
  long = => @names, " (#{@year}): ", (i @title), ", #{@published}"
  {
    {
      id: 'Milgram',
      title: 'Augmented Reality: A class of displays on the reality-virtuality continuum',
      published: 'in SPIE Vol. 2351',
      names: 'P. Milgram, H. Takemura, A. Utsumi, F. Kishino',
      year: 1994
      :long, :short,
    },
    {
      id: 'Marsh',
      title: 'Nested Immersion: Describing and Classifying Augmented Virtual Reality',
      published: 'IEEE Virtual Reality Conference 2015',
      names: 'W. Marsh, F. Mérienne',
      year: 2015
      :long, :short,
    },
    {
      id: 'Billinghurst',
      title: 'The MagicBook: a transitional AR interface',
      published: 'in Computer & Graphics 25',
      names: 'M. Billinghurst, H. Kato, I. Poupyrev',
      year: 2001,
      :long, :short,
    },
    {
      id: 'Matrix',
       title: 'The Matrix',
       year: 1999,
       names: 'L. Wachowski, A. Wachowski',
       long: => @names, " (#{@year}): ", (i @title), " (movie)"
       short: => tostring @year
    },
    {
      id: 'Naam',
      title: 'Nexus',
      published: 'Angry Robot (novel)',
      names: 'R. Naam',
      year: 2012,
      :long, :short,
    }
  }

ref = do
  fmt = (id) ->

    local src
    for _src in *sources
      if _src.id == id
        src = _src
        break

    if src
      a { src\short!, href: "##{src.id}" }
    else
      span id

  ref = (...) ->
    refs = { ... }
    with span "(", fmt refs[1]
      for i=2, #refs
        \append ", "
        \append fmt refs[i]
      \append ")"

references = ->
  with ol!
    for src in *sources
      \append li { id: src.id, src\long! }

sect = (label) ->
  with section style: 'page-break-inside': 'avoid'
    \append h2 label

append with article style: { margin: 'auto', 'max-width': '750px' }
  \append div 'Sol Bekic', style: 'text-align': 'right'

  \append h1 {
    style: { 'text-align': 'center', 'font-size': '2em' },
    "Reality Stacks",
    div "a Taxonomy for Multi-Reality Experiences", style: 'font-size': '0.6em'
  }

  \append with sect "Abstract"
    \append p "With the development of mixed-reality experiences and the corresponding interface devices
      multiple frameworks for classification of these experiences have been proposed. However these past
      attempts have mostly been developed alongside and with the intent of capturing specific projects ",
      (ref 'Marsh', 'Billinghurst'), " or are nevertheless very focused on existing methods and technologies ",
      (ref 'Milgram'), ". The existing taxonomies also all assume physical reality as a fixpoint and constant and are
      thereby not suited to describe many fictional mixed-reality environments and altered states of consciousness.
      In this paper we describe a new model for describing such experiences and examplify it's use with currently
      existing as well as idealized  technologies from popular culture."

  \append with sect "Terminology"
    \append p "We propose the following terms and definitions that will be used extensively for the remainder of the paper:"
    for definition in *{
      { "layer of reality": "a closed system consisting of a world model and a set of rules or dynamics operating on and
        constraining said model." },
      { "world model": "describes a world state containing objects, agents and/or concepts on an arbitrary abstraction level." },
      '------',
      { "reality stack": "structure consisting of all layers of reality encoding an agent's interaction with his environment
        in their world model at a given moment, as well as all layers supporting these respectively." },
      '------',
      { "physical reality": "layer of reality defined by physical matter and the physical laws acting upon it.
        While the emergent phenomena of micro- and macro physics as well as layers of social existence etc. may be seen
        as separate layers, for the purpose of this paper we will group these together under the term of physical reality." },
      { "mental reality": "layer of reality perceived and processed by the brain of a human agent." },
      { "digital reality": "layer of reality created and simulated by a digital system, e.g. a virtual reality game." },
      { "phys, mind, digi": "abbreviations for physical, mental and digital reality respectively." },
    }
      if 'string' == type definition
        \append hr!
        continue
      \append with div style: { 'margin-left': '2rem' }
        term = next definition
        \append span term, style: {
          display: 'inline-block',
          'margin-left': '-2rem',
          'font-weight': 'bold',
          'min-width': '140px'
        }
        \append span definition[term]

  \append with sect "Introduction"
    \append p "We identify two different types of relationships between layers in multi-reality environments.
      The first is layer nesting. Layer nesting describes how some layers are contained in other layers; i.e. they exist
      within and can be represented fully by the parent layer's world model and the child layer's rules emerge natively from
      the parent layer's dynamics. Layer nesting is visualized on the vertical axis in the following diagrams.
      For each layer of reality on the bottom of the diagram the nested parent layers can be found by tracing a line upwards
      to the top of the diagram. Following a materialistic point of view, physical reality therefore must completely encompass
      the top of each diagram."

    \append p "The second type of relationship describes the information flow between a subject and the layers of reality
      the subject is immersed in. In a multi-reality experience the subject has access to multiple layers of reality and
      their corresponding world models simultaneously.", br!,
      "Depending on the specific experience, different types of and directions for information exchange
      can exist between these layers and the subject's internal representation of the experience.
      For the sake of this paper we distinguish only between ", (i "input"), " and ", (i "output"), " data flow (from the
      perspective of the subject); categorized loosely as information the subject receives from the environment
      (", (i "input"), ", e.g. visual stimuli) and actions the subject can take to influence the state of the world model
      (", (i "output"), ", e.g. motor actions) respectively."

    \append p "In the following diagrams, information flow is visualized horizontally, in the region below the dashed line
      at the bottom of the diagram. The subject's internal mental model and layer of reality are placed on the bottom left
      side of the diagram.
      The layers of reality that the subject experiences directly and that mirror it's internal representations are placed
      on the far right. There may be multiple layers of reality sharing this space, visualized as a vertical stack of
      layers. Since the subject must necessarily have a complete internal model of the multi-reality experience around
      him to feel immersed, the subject's mental layer of reality must span the full height of all the layers visible
      on the right side of the diagram.", br!,
      "Information flow itself is now visualized concretely using arrows that cross layer boundaries in the lower part of
      the diagram as described above. Arrows pointing leftwards denote ", (i "input"), " flow, whilst arrows pointing
      rightwards denote ", (i "output"), "-directed information flow. In some cases information doesn't flow directly
      between the layers the subject is directly aware of and the subject's internal representation and instead
      traverses ", (i "intermediate layers"), " first."

    \append p "Before we take a look at some reality stacks corresponding to current VR and AR technology,
      we can take a look at waking life as a baseline stack. To illustrate the format of the diagram we will compare it
      to the stack corresponding to a dreaming state:"

    \append with figures!
      \append addlabel "Waking Life", Diagram =>
        @mind!
        @inout!
        @phys!

        @next!
        @phys '', 2
        @finish!

      \append addlabel "Dreaming", Diagram =>
        @mind!
        @phys!
        @finish!

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

  \append with sect "Current Technologies"
    \append p "Since recent technological advancements have enabled the development of VR and AR consumer devices,
      AR and VR have been established as the potential next frontier of digital entertainment.", br!,
      "As the names imply, the notion of reality is at the core of both technologies.
      In the following section we will take a look at the respective stacks of both experience types:"

    \append with figures!
      \append addlabel "VR", Diagram =>
        @mind!
        @phys!
        @inout nil, 1

        @next!
        @phys '', 2
        @inout nil, 1

        @next!
        @digi!
        @phys ''
        @finish!


      \append addlabel "AR", Diagram =>
        @mind!
        @inout nil, 1.25
        @inn nil, 0.5
        @phys!

        @next!
        @phys '', 2
        @inn nil, .5

        @next!
        @digi nil, .5
        @phys '', 1.5
        @finish!

    \append p "In both cases we find the physical layer of reality as an ", (i "intermediate layer"), " between the mental
      and digital layers. Actions taken by the subject have to be acted out physically (corresponding to the
      information traversing the barrier between mental and physical reality) before they can be again digitized using
      the various tracking and input technologies (which in turn carry the information across the boundary of the physical
      and digital spaces)."

    \append p "The difference between AR and VR lies in the fact that in AR the subject experiences a mixture of the
      digital and physical world models. This can be seen in the diagram, where we find that right of the diagram origin
      and the mental model, the diagram splits and terminates in both layers: while information reaches the subject both
      from the digital reality through the physical one, as well as directly from the physical reality, the subject only
      directly manipulates state in the physical reality."

    \append p "The data conversions necessary at layer boundaries incur at the least losses in quality and accuracy of
      information for purely technical reasons. However ", (i "intermediate layers"), " come at a cost larger than just
      an additional step of conversion:
      For information to flow through a layer, it must be encodable within that layer’s world model.
      This means that the 'weakest link' in a given reality stack determines the upper bound of information possible to
      encode within said stack and thereby limits the overall expressivity of the stack.", br!,
      "As a practical example we can consider creating an hypothetical VR application that allows users to traverse a
      large virtual space by flying. While the human mind is perfectly capable of imagining to fly and control the motion
      appropriately, it is extremely hard to devise and implement a satisfying setup and control scheme because the
      physical body of the user needs to be taken into account and it, unlike the corresponding representations in the
      mental and digital world models, cannot float around freely."

  \append with sect "Future Developments"
    \append p "In the previous section we found that the presence of the physical layer in the information path of
      VR and AR stacks limits the experience as a whole. It follows that the removal of that indirection should be
      an obvious goal for future developments:"

    \append figures addlabel "holy grail of VR: 'The Matrix'", Diagram =>
      @mind!
      @inout!
      @phys!

      @next!
      @digi!
      @phys ''
      @finish!

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
      \append addlabel "'Nexus'", Diagram =>
        @mind!
        @inout nil, 0.75
        @inout nil, 1.25
        @phys!

        @next!
        @digi nil, .5
        @phys '', 1.5
        @finish!

      \append addlabel "holy grail of AR: 'Deus Machina'", Diagram =>
        col = '#92807c'

        @mind!
        @inout!
        @block col, ''

        @next!
        @block col, '', 2
        @svg\plain('phys + digi')\attr(o fill: 'white', 'font-size': '14px')\move 6, -2 * GRID_H
        @finish!

    \append p "Despite the similarities of VR and AR, the two can be considered polar opposites, as becomes evident when
      we compare their respective utopian implementations: they share the goal of allowing us to experience realities
      different from the one we naturally inhabit, but while VR seeks to accomplish this by creating a new, nested reality
      inside ours, thus giving us full control over it.
      AR, on the other hand, is instead an attempt to retrofit our specific needs directly into the very reality we exist
      in.", br!,
      "This is in direct contrast with the popular notion of the 'reality-virtuality continuum' ", (ref 'Milgram'), ":
      the reality-virtuality continuum places common reality and VR (virtuality) as the two extreme poles, while AR
      is represented as an intermediate state between the two. Here however we propose to view instead AR and VR as the
      respective poles and find instead reality at the centerpoint, where the two opposing influences 'cancel out'."

  \append with sect "Conclusion and Further Work"
    \append p "In this paper we have proposed a taxonomy and visualization style for multi-reality experiences, as well
      as demonstrated it's flexibility by applying them as examples. Through the application of the proposed theory,
      we have also gained a new and contrasting view on preceding work such as the reality-virtuality-continuum.
      We have also found that the taxonomy can be used outside the research field of media studies and its use may extend
      as far as philosophy of consciousness (see Appendix below)."

    \append p "Further research could enhance the proposed theory with better and more concrete definitions.
      In the future, the proposed taxonomy might be used to create a more extensive and complete classification
      of reality stacks and to analyse the relationships between them."

  \append with sect 'References'
    \append references!

  \append with sect "Appendix: Relation to Theories of Mind"
    \append p "This paper starts from a deeply materialistic point of view that borders on microphysicalism.
      However it should be noted that the diagram style introduced above lends itself also to display other
      philosophical theories of mind. As an example, the following graphics show a typical VR stack as interpreted by
      Materialism, Cartesian Dualism and Solipsism respectively:"

    \append with figures!
      \append addlabel "VR in Materialism", Diagram =>
        @mind!
        @inout nil, 1
        @phys!

        @next!
        @phys '', 2
        @inout nil, 1

        @next!
        @digi!
        @phys ''

        @finish!

      \append addlabel "VR in Solipsism", Diagram =>
        @mind nil, 2
        @inout nil, 1

        @next!
        @digi!
        @mind ''
        @finish!

      \append addlabel "VR in Cartesian Dualism", Diagram =>
        @mind nil, 2
        @inout nil, 1
        @next!

        @phys nil, 2
        @inout nil, 1
        @next!

        @digi!
        @phys ''
        @finish!

    \append p "However these philosophical theories of minds also constitute reality stacks by themselves and as such can
      be compared directly:"

    \append with figures!
      \append addlabel "Materialism", Diagram =>
        @mind!
        @inout!
        @phys!

        @next!
        @phys '', 2
        @finish!

      \append addlabel "Solipsism", Diagram =>
        @mind!
        @finish!

      \append addlabel "Cartesian Dualism", Diagram =>
        @mind!
        @inout!
        @next!

        @phys!
        @finish!
