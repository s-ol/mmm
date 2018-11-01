import opairs from require 'lib.ordered'

void_tags = { 'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source', 'track', 'wbr' }
void_tags = { t,t for t in *void_tags }

element = (element) -> (...) ->
  children = { ... }

  -- attributes are last arguments but mustn't be a ReactiveVar
  attributes = children[#children]
  if 'table' == (type attributes) and not attributes.node
    table.remove children
  else
    attributes = {}

  b = "<#{element}"
  for k,v in opairs attributes
    if k == 'style' and 'table' == type v
      tmp = ''
      for kk, vv in opairs v
        tmp ..= "#{kk}: #{vv}; "
      v = tmp
    b ..= " #{k}=\"#{v}\""

  -- if there is only one argument,
  -- children can be in attributes table too
  if #children == 0
    children = attributes

  if void_tags[element]
    assert #children == 0, "void tag #{element} cannot have children!"
    b .. ">"
  else
    b ..= ">" ..  table.concat children, ''
    b ..= "</#{element}>"
    b

setmetatable {}, __index: (name) =>
  with val = element name
    @[name] = val
