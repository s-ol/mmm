local d = require 'mmm.dom'
local u = require('mmm.mmmfs.util')(d)

-- we need to return a function to get access to the current fileder
-- (thats why there is the '-> fn ->' in the type)
return function(self)
  local children = {}
  for i, child in ipairs(self.children) do
    table.insert(children, d.li {
      'child ' .. i .. ': ',
      u.link_to(child),
    })
  end
  
  return d.article {
    d.h1 'The Children are:',
    d.ul(children),
  }
end
