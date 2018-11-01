-- convert anything to a DOM Node
-- val must be one of:
-- * DOM Node (instanceof window.Node)
-- * MMMElement (have a .node value that is instanceof window.Node)
-- * string
-- note that strings won't survive identity comparisons after tohtml
tohtml = (val) ->
  if 'string' == type val
    return document\createTextNode val
  if 'table' == type val
    assert val.node, "Table doesn't have .node"
    val = val.node
  if 'userdata' == type val
    assert (js.instanceof val, js.global.Node), "userdata is not a Node"
    val
  else
    error "not a Node: #{val}, #{type val}"

-- overloaded append
-- see tohtml for acceptable values
g_append = append
append = (value) -> g_append tohtml value

-- shorthand to form a text node from strings
text = (...) -> document\createTextNode table.concat { ... }, ' '

class ReactiveVar
  @isinstance: (val) -> 'table' == (type val) and val.subscribe

  new: (@value) =>
    @listeners = setmetatable {}, __mode: 'kv'

  set: (value) =>
    old = @value
    @value = value
    for k, callback in pairs @listeners
      callback @value, old

  get: => @value

  transform: (transform) => @set transform @get!

  subscribe: (callback) =>
    with -> @listeners[callback] = nil
      @listeners[callback] = callback

  map: (transform) =>
    with ReactiveVar transform @value
      .upstream = @subscribe (...) -> \set transform ...

-- join = do
--   update = (k, new) -> (old) ->
--     with copy = { k, v for k,v in pairs old }
--       copy[k] = new
-- 
--   (inputs) ->
--     values = {}
--     with ReactiveVar values
--       for k, input in pairs inputs
--         input = inputs[k]
--         values[i] = input\get!
--         input\subscribe (new) -> \transform update k, new

class ReactiveElement
  @isinstance: (val) -> 'table' == (type val) and val.node

  new: (element, ...) =>
    if 'userdata' == type element
      @node = element
    else
      @node = document\createElement element
    @_subscriptions = {}

    children = { ... }
    -- attributes are last arguments but mustn't be a ReactiveVar
    attributes = children[#children]
    if 'table' == (type attributes) and
        (not ReactiveElement.isinstance attributes) and
        (not ReactiveVar.isinstance attributes)
      table.remove children
    else
      attributes = {}

    for k,v in pairs attributes
      @set k, v if 'string' == type k

    -- if there is only one argument,
    -- children can be in attributes table too
    if #children == 0
      children = attributes

    for child in *children
      @append child

  destroy: =>
    for unsub in *@_subscriptions do unsub!

  set: (attr, value) =>
    attr = 'className' if attr == 'class'
    if 'table' == (type value) and ReactiveVar.isinstance value
      table.insert @_subscriptions, value\subscribe (...) -> @set attr, ...
      value = value\get!

    if attr == 'style' and 'table' == type value
      for k,v in pairs value
        @node.style[k] = v
      return

    @node[attr] = value

  prepend: (child, last) => @append child, last, 'prepend'
  append: (child, last, mode='append') =>
    if ReactiveVar.isinstance child
      table.insert @_subscriptions, child\subscribe (...) -> @append ...
      child = child\get!

    if 'string' == type last
      error 'cannot replace string node'

    if child == nil
      if last
        @remove last
      return

    child = tohtml child
    ok, last = pcall tohtml, last
    if ok
      @node\replaceChild child, last
    else
      switch mode
        when 'append' then @node\appendChild child
        when 'prepend' then @node\insertBefore child, @node.firstChild

  remove: (child) =>
    @node\removeChild tohtml child
    if 'table' == (type child) and child.destroy
      child\destroy!

get_or_create = (elem, id, ...) ->
  elem = (document\getElementById id) or elem

  with ReactiveElement elem, ...
    \set 'id', id

elements = setmetatable {}, __index: (name) =>
  with val = (...) -> ReactiveElement name, ...
    @[name] = val

{
  :ReactiveVar,
  :ReactiveElement,
  :get_or_create,
--  :join,
  :tohtml,
  :append,
  :text,
  :elements,
}
