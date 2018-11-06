import opairs from require 'mmm.ordered'

void_tags = { 'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source', 'track', 'wbr' }
void_tags = { t,t for t in *void_tags }

-- convert anything to HTML string
-- val must be one of:
-- * MMMElement (have a .render method that returns a string)
-- * string
tohtml = (val) ->
  if 'table' == type val
    assert val.render, "Table doesn't have .render"
    val = val\render!
  if 'string' == type val
    val
  else
    error "not a Node: #{val}, #{type val}"

-- shorthand to form a text node from strings
text = (...) -> table.concat { ... }, ' '

class ReactiveVar
  @isinstance: (val) -> 'table' == (type val) and val.subscribe

  new: (@value) =>

  set: (value) =>
    error "attempting to update ReactiveVar serverside"

  get: => @value

  subscribe: (callback) =>
    warn "attempting to subscribe to ReactiveVar serverside"

  map: (transform) =>
    ReactiveVar transform @value

class ReactiveElement
  @isinstance: (val) -> 'table' == (type val) and val.render

  new: (element, ...) =>
    @element = element
    @attrs = {}
    @children = {}

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

  set: (attr, value) =>
    if 'table' == (type value) and ReactiveVar.isinstance value
      value = value\get!

    @attrs[attr] = value

  append: (child, last) =>
    assert not last, "last passed to append on server"
    if ReactiveVar.isinstance child
      child = child\get!

    if child
      child = tohtml child
      table.insert @children, child

  remove: (child) =>
    error "remove called serverside"

  render: =>
    b = "<#{@element}"
    for k,v in opairs @attrs
      if 'table' == type v
        tmp = ''
        for kk, vv in opairs v
          tmp ..= "#{kk}: #{vv}; "
        v = tmp
      b ..= " #{k}=\"#{v}\""

    if void_tags[@element]
      assert #@children == 0, "void tag #{element} cannot have children!"
      b .. ">"
    else
      b .. ">"
      b ..= ">" ..  table.concat @children, ''
      b ..= "</#{@element}>"
      b

elements = setmetatable {}, __index: (name) =>
  with val = (...) -> ReactiveElement name, ...
    @[name] = val

get_or_create = (elem, id, ...) ->
  with ReactiveElement elem, ...
    \set 'id', id

{
  :ReactiveVar,
  :ReactiveElement,
  :get_or_create,
  :tohtml,
  :text,
  :elements,
}
