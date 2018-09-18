element = (element) -> (...) ->
  children = { ... }

  -- attributes are last arguments but mustn't be a ReactiveVar
  attributes = children[#children]
  if 'table' == (type attributes) and not attributes.node
    table.remove children
  else
    attributes = {}

  b = "<#{element}"
  for k,v in pairs attributes
    if 'table' == type v
      tmp = ''
      for kk, vv in pairs v
        tmp ..= "#{kk}: #{vv}; "
      v = tmp
    b ..= " #{k}=\"#{v}\""

  -- if there is only one argument,
  -- children can be in attributes table too
  if #children == 0
    children = attributes

  b ..= ">" ..  table.concat children, ''
  b ..= "</#{element}>"
  b

elements = {}
add = (e) -> elements[e] = element e

for e in *{'div', 'form', 'span', 'a', 'p', 'button', 'ul', 'ol', 'li', 'i', 'b', 'u', 'tt'} do add e
for e in *{'article', 'section', 'header', 'footer', 'content'} do add e
for e in *{'br', 'hr', 'img', 'input', 'p', 'textarea'} do add e
for i=1,8 do add "h" .. i

elements
