=>
  assert MODE == 'CLIENT', '[nossr]'

  import add_tag, rmv_tag, Node, Hierarchy, Toggle, NamespacedToggle from @get 'tags: table'
  import ReactiveVar, tohtml, text, elements from require 'mmm.component'
  import article, div, form, span, h3, a, input, textarea, button from elements

  clone = (set) ->
    assert set and 'table' == (type set), 'not a set'
    { k,v for k,v in pairs set }

  set_append = (val) -> (set) ->
    with copy = clone set
      copy[val] = val

  set_remove = (val) -> (set) ->
    with copy = clone set
      copy[val] = nil

  set_join = (tbl, sep=' ') ->
    ret = ''
    for tag in pairs tbl
      ret ..= (tostring tag) .. sep
    ret

  entries = div!

  class ReactiveNode extends Node
    new: (...) =>
      super ...
      @tags = ReactiveVar @tags
      @_node = div {
          span @name, style: { 'font-weight': 'bold' },
          @tags\map (tags) -> with div!
              for tag,_ in pairs tags
                \append a (text tag), href: '#', style: {
                  display: 'inline-block',
                  margin: '0 5px',
                }
        }

      @node = tohtml @_node

    has: (tag) => @tags\get![tag]
    add: (tag) => @tags\transform set_append tag
    rmv: (tag) => @tags\transform set_remove tag

  rules = {
    Hierarchy 'home', 'sol'
    Hierarchy 'sol', 'desktop'
    Hierarchy 'desktop', 'vacation'
    Hierarchy 'desktop', 'documents'
    NamespacedToggle 'documents', 'work', 'personal'
    -- Toggle 'work', 'personal'
    -- Hierarchy 'documents', 'work'
    -- Hierarchy 'documents', 'personal'
  }

  pictures = for i=1,10
    with node = ReactiveNode "picture#{i}.jpg"
      entries\append node
      add_tag node, 'vacation'

  pers = ReactiveNode 'mypersonalfile.doc'
  entries\append pers

  article entries, div do
    yield = coroutine.yield
    step = coroutine.wrap ->
      yield "mark document"
      add_tag pers, 'documents'

      yield "mark personal"
      add_tag pers, 'personal'

      yield "mark work"
      add_tag pers, 'work'

      yield "unmark work"
      rmv_tag pers, 'work'

      yield "remove from documents"
      rmv_tag pers, 'documents'

      yield false

    next_step = ReactiveVar step!
    next_step\map (desc) ->
      if desc
        button (text desc), onclick: (e) => next_step\set step!
      else
        text ''
