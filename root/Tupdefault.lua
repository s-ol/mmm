local LUA_PATH = lua_path()
bundle = LUA_PATH .. ' moon ' .. build .. '/bundle_fileder.moon'
render = LUA_PATH .. ' moon ' .. build .. '/render_fileder.moon'

local _facets, facets = {}, {}
for i, file in ipairs(tup.glob '*$*') do _facets[file] = true end
for i, file in ipairs(tup.glob '*:*') do _facets[file] = true end

for file in pairs(_facets) do facets += file end
table.sort(facets)

local inputs = ''
for i, file in ipairs(facets) do
  inputs = inputs .. " '" .. file .. "'"
end

facets += '<children>'
facets += root .. '/<modules>'

tup.rule(
  facets,
  '^ BNDL %d^ ' .. bundle .. ' ' .. root .. ' %d ' .. inputs .. ' -- %<children>',
  { '$bundle.lua', '../<children>' }
)

tup.rule(
  '$bundle.lua',
  '^ HTML %d^ ' .. render .. ' ' .. root,
  'index.html'
)
