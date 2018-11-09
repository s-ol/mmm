local d = require 'mmm.dom'

local lua = d.a { 'Lua', href = 'https://www.lua.org/' }
local fengari = d.a { 'fengari.io', href = 'https://fengari.io/' }

return d.article {
  d.h1 'Lua',
  d.p { lua, ' is fully supported using ', fengari, ' on the Client.' }
}
