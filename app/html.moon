document = js.global.document

element = (element) -> (attrs = {}, ...) ->
  if 'table' != type attrs
    attrs = { attrs, ... }
  with e = document\createElement element
    for k,v in pairs(attrs)
      continue unless 'string' == type k
      e[k] = v
    for child in *attrs
      if 'string' == type child
        e.innerHTML ..= child
      else
        e\appendChild child

elements = {}
add = (e) -> elements[e] = element e

for e in *{'div', 'span', 'a', 'p', 'button', 'ul', 'li', 'i', 'b', 'u', 'tt'} do add e
for e in *{'br', 'img', 'input', 'p'} do add e
for i=1,8 do add "h" .. i

elements
