document = js.global.document

element = (element) -> (...) ->
  children = { ... }

  -- attributes are last arguments but mustn't be a ReactiveVar
  attributes = children[#children]
  if 'table' == (type attributes) and not attributes.node
    table.remove children
  else
    attributes = {}

  with e = document\createElement element
    for k,v in pairs attributes
      e[k] = v

    -- if there is only one argument,
    -- children can be in attributes table too
    if #children == 0
      children = attributes

    for child in *children
      if 'string' == type child
        e.innerHTML ..= child
      else
        e\appendChild child

elements = {}
add = (e) -> elements[e] = element e

for e in *{'div', 'span', 'a', 'p', 'pre', 'button', 'ul', 'li', 'i', 'b', 'u', 'tt'} do add e
for e in *{'br', 'img', 'input', 'p'} do add e
for i=1,8 do add "h" .. i

elements
