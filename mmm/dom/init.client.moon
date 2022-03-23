element = (element) -> (...) ->
  children = { ... }

  -- attributes are last arguments but mustn't be a ReactiveVar
  attributes = children[#children]
  if 'table' == (type attributes) and not attributes.node
    table.remove children
  else
    attributes = {}

  e = if element then document\createElement element else document\createDocumentFragment!

  for k,v in pairs attributes
    k = 'className' if k == 'class'
    if k == 'style' and 'table' == type v
      for kk,vv in pairs v
        e.style[kk] = vv
    elseif 'string' == type k
      e[k] = v

  -- if there is only one argument,
  -- children can be in attributes table too
  if #children == 0
    children, attributes = attributes, {}

  if not element
    assert not (next attributes), "_frag cannot take attributes"

  for child in *children
    if 'string' == type child
      child = document\createTextNode child

    e\appendChild child

  e

setmetatable { _frag: element! }, __index: (name) =>
  with val = element name
    @[name] = val
