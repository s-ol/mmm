import opairs from require 'lib.ordered'

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

-- overloaded append
-- see tohtml for acceptable values
g_append = append
append = (value) -> g_append tohtml value

-- shorthand to form a text node from strings
text = (...) -> table.concat { ... }, ' '

class ReactiveVar
  @isinstance: (val) -> 'table' == (type val) and val.subscribe

  new: (@value) =>

  set: (value) =>
    error "attempting to update ReactiveVar serverside"

  get: => @value

  subscribe: (callback) =>
    error "attempting to subscribe to ReactiveVar serverside"

  map: (transform) =>
    ReactiveVar transform @value

class ReactiveElement
  @isinstance: (val) -> 'table' == (type val) and val.render

  new: (element, ...) =>
    @element = element
    @attrs = { style: {} }
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
    if attr == 'style' and 'table' == type value
      for k,v in opairs value
        @attrs.style[k] = v
      return

    @attrs[attr] = value

  append: (child, last) =>
    assert not last, "last passed to append on server"
    if ReactiveVar.isinstance child
      child = child\get!

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
    b ..= ">" ..  table.concat @children, ''
    b ..= "</#{@element}>"
    b

with exports = {
    :ReactiveVar,
    :ReactiveElement,
    :tohtml,
    :flush,
    :append,
    :text,
  }
  add = (e) -> exports[e] = (...) -> ReactiveElement e, ...

  for e in *{'div', 'form', 'span', 'a', 'p', 'button', 'ul', 'ol', 'li', 'i', 'b', 'u', 'tt'} do add e
  for e in *{'article', 'section', 'header', 'footer', 'content'} do add e
  for e in *{'br', 'hr', 'img', 'input', 'p', 'textarea'} do add e
  for i=1,8 do add "h" .. i
