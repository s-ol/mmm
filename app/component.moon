{ :document } = js.global

warn = warn or -> print

-- convert anything to a DOM Node
-- val must be one of:
-- * DOM Node (instanceof window.Node)
-- * MMMElement (have a .node value that is instanceof window.Node)
-- * string
-- note that strings won't survive identity comparisons after asnode
asnode = (val) ->
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

-- shorthand to append elements to body
-- see #asnode for permitted values
append = (val) -> document.body\appendChild asnode val

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

class ReactiveElement
  @isinstance: (val) -> 'table' == (type val) and val.node

  new: (element, ...) =>
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
    if 'table' == (type value) and ReactiveVar.isinstance value
      table.insert @_subscriptions, value\subscribe (...) -> @set attr, ...
      value = value\get!

    if attr == 'style' and 'table' == type value
      for k,v in pairs value
        @node.style[k] = v
      return

    @node[attr] = value

  append: (child, last) =>
    if ReactiveVar.isinstance child
      table.insert @_subscriptions, child\subscribe (...) -> @append ...
      child = child\get!
      if 'string' == type child
        warn 'string from ReactiveVar implicitly converted to TextNode, updating may fail'

    child = asnode child
    ok, last = pcall asnode, last
    if ok
      @node\replaceChild child, last
    else
      @node\appendChild child

  remove: (child) =>
    @node\removeChild asnode child
    if 'table' == (type child) and child.destroy
      child\destroy!

with exports = {
    :ReactiveVar,
    :ReactiveElement,
    :asnode,
    :append,
    :text,
  }
  add = (e) -> exports[e] = (...) -> ReactiveElement e, ...

  for e in *{'div', 'form', 'span', 'article', 'a', 'p', 'button', 'ul', 'li', 'i', 'b', 'u', 'tt'} do add e
  for e in *{'br', 'img', 'input', 'p', 'textarea'} do add e
  for i=1,8 do add "h" .. i
