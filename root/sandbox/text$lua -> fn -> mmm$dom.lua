local d = require 'mmm.dom'
local u = require('mmm.mmmfs.util')(d)

return function(self)
  local children = {}
  for i, child in ipairs(self.children) do
    table.insert(
      children,
      d.li(u.link_to(child), ': ', (child:get('description: mmm/dom')))
    )
  end
  
  return d.div({
    d.h3(u.link_to(self)),
    self:gett('description: mmm/dom'),
    d.ul(children),
  })
end
