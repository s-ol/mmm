{ :document } = js.global

asnode = (val) ->
  if 'table' == type val
    assert val.node, "Table doesn't have .node"
    val = val.node
  if 'string' == type val
    val = document\createTextNode val
  if 'userdata' == type val
    assert (js.instanceof val, js.global.Node), "userdata is not a Node"
    val
  else
    error "not a Node: #{val}, #{type val}"

iscallback = (val) -> 'table' == (type val) and val.subscribe

class Callback
  new: (@value) =>
    @listeners = setmetatable {}, __mode: 'kv'

  set: (value) =>
    old = @value
    @value = value
    for k, callback in pairs @listeners
      callback @value, old

  get: => @value

  subscribe: (callback) =>
    with callback
      @listeners[callback] = callback

  unsubscribe: (callback) =>
    @listeners[callback] = nil

  chain: (transform) =>
    with Callback transform @value
      .upstream = @subscribe (...) -> \set transform ...

class CallbackElement
  new: (element, attributes, ...) =>
    @node = document\createElement element
    @_callbacks = {}

    children = { ... }

    if 'table' != (type attributes) or attributes.__class == @@ or attributes.__class == Callback
      table.insert children, 1, attributes
      attributes = {}

    for k,v in pairs attributes
      @set k, v if 'string' == type k
    for child in *children
      @append child

  set: (attr, value) =>
    if 'table' == (type value) and value.__class == Callback
      table.insert @_callbacks, value\subscribe (...) -> @set attr, ...
      value = value\get!

    if attr == 'style' and 'table' == type value
      for k,v in pairs value
        @node.style[k] = v
      return

    @node[attr] = value

  append: (child, last) =>
    if iscallback child
      table.insert @_callbacks, child\subscribe (...) -> @append ...
      child = child\get!

    child = asnode child
    ok, last = pcall asnode, last
    if ok
      @node\removeChild last
    @node\appendChild child

  remove: (child) =>
    @node\removeChild asnode child

text = (...) -> document\createTextNode table.concat { ... }, ' '

with exports = {
    :Callback,
    :CallbackElement,
    :text,
  }
  add = (e) -> exports[e] = (...) -> CallbackElement e, ...

  for e in *{'div', 'form', 'span', 'a', 'p', 'button', 'ul', 'li', 'i', 'b', 'u', 'tt'} do add e
  for e in *{'br', 'img', 'input', 'p', 'textarea'} do add e
  for i=1,8 do add "h" .. i
