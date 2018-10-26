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
      if 'string' == type k
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

setmetatable {}, __index: (name) =>
  with val = element name
    @[name] = val
